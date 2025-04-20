#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Function to list available disks and prompt user to select one
select_disk() {
  echo "Available disks:"
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep 'disk'
  read -p "Enter the disk name (e.g., sda, nvme0n1): " DISK
  DEVICE="/dev/$DISK"
}

# Prompt user to select a disk
select_disk

# Variables
EFI_SIZE="200M"
REPO="https://mirrors.servercentral.com/voidlinux/current/"
ARCH="x86_64"
HOSTNAME="myhostname"
USERNAME="yourusername"
TIMEZONE="America/Chicago"
LOCALE="en_US.UTF-8"
BTRFS_OPTS="rw,noatime,compress=zstd,discard=async"

# Partition the device
fdisk "$DEVICE" <<EOF
g
n
1

+$EFI_SIZE
y
t
1
n
2

w
EOF

# Encrypt the root partition
cryptsetup luksFormat --type luks1 -y "${DEVICE}2"
cryptsetup open "${DEVICE}2" cryptvoid

# Format partitions
mkfs.fat -F32 -n EFI "${DEVICE}1"
mkfs.btrfs -L Void /dev/mapper/cryptvoid

# Create Btrfs subvolumes
mount -o "$BTRFS_OPTS" /dev/mapper/cryptvoid /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt

# Mount subvolumes and EFI partition
mount -o "$BTRFS_OPTS,subvol=@" /dev/mapper/cryptvoid /mnt
mkdir /mnt/{efi,home,.snapshots}
mount -o "$BTRFS_OPTS,subvol=@home" /dev/mapper/cryptvoid /mnt/home
mount -o "$BTRFS_OPTS,subvol=@snapshots" /dev/mapper/cryptvoid /mnt/.snapshots
mkdir -p /mnt/var/cache
btrfs subvolume create /mnt/var/cache/xbps
btrfs subvolume create /mnt/var/tmp
btrfs subvolume create /mnt/srv
mount -o rw,noatime "${DEVICE}1" /mnt/efi

# Verify mountpoints
df -h
lsblk

# Install base system
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
XBPS_ARCH="$ARCH" xbps-install -S -R "$REPO" -r /mnt base-system linux-mainline btrfs-progs cryptsetup vim

# Chroot preparation
for dir in dev proc sys run; do
  mount --rbind /$dir /mnt/$dir
  mount --make-rslave /mnt/$dir
done
cp /etc/resolv.conf /mnt/etc/

# Chroot into the system
cat << 'EOF' | chroot /mnt /bin/bash
# Set timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# Set locale
sed -i "s/#$LOCALE/$LOCALE/" /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

# Set hostname
echo "$HOSTNAME" > /etc/hostname

# Create /etc/hosts
cat <<EOF > /etc/hosts
127.0.0.1        localhost
::1              localhost
127.0.1.1        $HOSTNAME.localdomain $HOSTNAME
EOF

# User management
passwd
useradd $USERNAME
passwd $USERNAME
usermod -aG wheel $USERNAME
chsh -s /bin/bash root
EDITOR=vim visudo

# Sync repositories
xbps-install -S

# Create fstab
EFI_UUID=$(blkid -s UUID -o value "${DEVICE}1")
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptvoid)
LUKS_UUID=$(blkid -s UUID -o value "${DEVICE}2")

cat <<EOF > /etc/fstab
UUID=$ROOT_UUID / btrfs $BTRFS_OPTS,subvol=@ 0 1
UUID=$ROOT_UUID /home btrfs $BTRFS_OPTS,subvol=@home 0 2
UUID=$ROOT_UUID /.snapshots btrfs $BTRFS_OPTS,subvol=@snapshots 0 2
UUID=$EFI_UUID /efi vfat defaults,noatime 0 2
tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0
EOF

# Install and setup bootloader
xbps-install grub-x86_64-efi
echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.auto=1 rd.luks.allow-discards"/' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id="Void"

# Optional: Create a keyfile for LUKS
dd bs=512 count=4 if=/dev/urandom of=/boot/keyfile.bin
cryptsetup -v luksAddKey "${DEVICE}2" /boot/keyfile.bin
chmod 000 /boot/keyfile.bin
chmod -R g-rwx,o-rwx /boot
cat <<EOF >> /etc/crypttab
cryptvoid UUID=$LUKS_UUID /boot/keyfile.bin luks
EOF
echo 'install_items+=" /boot/keyfile.bin /etc/crypttab "' > /etc/dracut.conf.d/10-crypt.conf
ln -s /etc/sv/dhc /etc/runit/runsvdir/default

# Install additional software
xbps-install <list of desired programs>

# Link services
ln -s /etc/sv/dhcpcd-eth0 /var/service
ln -s /etc/sv/dhcpcd /var/service
xbps-install NetworkManager
ln -s /etc/sv/NetworkManager /var/service

# Verify installed programs
xbps-reconfigure -fa

# Exit chroot
exit
EOF

# Reboot the system
reboot
