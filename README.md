# void-linux install
> Boot on xfce live cd, configure network, open terminal and follow as root.
## Partitions
### Create
```bash
cfdisk /dev/nvme0n1
# nvme0n1p1 -> /efi (1G) [EFI]
# nvme0n1p2 -> /boot (1G) [Linux]
# nvme0n1p3 -> crypted root [Linux]
```
### Encrypt
```bash
cryptsetup luksFormat --type luks -y /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 cryptroot
```
### Format
```
mkfs.fat -F32 -n EFI /dev/nvme0n1p1
mkfs.ext2 -L grub /dev/nvme0n1p2
mkfs.btrfs -L Void /dev/mapper/cryptroot
```
### BTRFS Subvolumes
```
BTRFS_OPTS="rw,noatime,compress=zstd,discard=async"
mount -o $BTRFS_OPTS /dev/mapper/cryptvoid /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
umount /mnt
mount -o $BTRFS_OPTS,subvol=@ /dev/mapper/cryptroot /mnt
mkdir /mnt/{efi,home,.snapshots}
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mkdir -p /mnt/var/cache
btrfs su cr /mnt/var/cache/xbps
btrfs su cr /mnt/var/tmp
btrfs su cr /mnt/srv
mount -o rw,noatime /dev/nvme0n1p1 /mnt/efi
```
## Installation
```
REPO=https://mirrors.servercentral.com/voidlinux/current/
ARCH=x86_64
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
XBPS_ARCH=$ARCH xbps-install -S -R "$REPO" -r /mnt base-system linux-mainline btrfs-progs cryptsetup vim
```
## Chroot
```
for dir in dev proc sys run; do mount --rbind /$dir /mnt/$dir; mount --make-rslave /mnt/$dir; done
cp /etc/resolv.conf /mnt/etc/
BTRFS_OPTS=$BTRFS_OPTS PS1='(chroot) # ' chroot /mnt/ /bin/bash
ln -sf /usr/share/zoneinfo/America/Montreal /etc/localtime
# Set en_US.UTF-8
vim /etc/default/libc-locales
xbps-reconfigure -f glibc-locales
echo "VoidLinux" > /etc/hostname
# -----
cat <<EOF > /etc/hosts
#
# /etc/hosts: static lookup table for host names
#
127.0.0.1        localhost
::1              localhost
127.0.1.1        VoidLinux.localdomain VoidLinux
EOF
```
### Users
```
# root password
passwd
# Add your user
useradd sysadmin
passwd sysadmin
usermod -aG wheel,adm,dialout,cdrom,floppy,audio,video,plugdev,users sysadmin
# Sudoers
# Uncomment the line # %wheel ALL=(ALL:ALL) ALL
chsh -s /bin/bash root
EDITOR=vim visudo
```
### Repos
```
xbps-install -S
xbps-install void-repo-nonfree
xbps-install -S
xbps-install void-repo-multilib
xbps-install -Su intel-ucode
```
### fstab
```
EFI_UUID=$(blkid -s UUID -o value /dev/nvme0n1p1)
BOOT_UUID$(blkid -s UUID -o value /dev/nvme0n1p2)
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptvoid)

cat <<EOF > /etc/fstab
UUID=$ROOT_UUID / btrfs $BTRFS_OPTS,subvol=@ 0 1
UUID=$ROOT_UUID /home btrfs $BTRFS_OPTS,subvol=@home 0 2
UUID=$ROOT_UUID /.snapshots btrfs $BTRFS_OPTS,subvol=@snapshots 0 2
UUID=$BOOT_UUID /boot ext2 defaults,noatime 0 2
UUID=$EFI_UUID /efi vfat defaults,noatime 0 2
tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0
EOF
# Dracut
echo hostonly=yes >> /etc/dracut.conf
```
### GRUB
```
xbps-install grub-x86_64-efi
echo GRUB_ENABLE_CRYPTODISK=y >> /etc/default/grub
# Add GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.auto=1 rd.luks.allow-discards"
vim /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id="Void"
```
### Software, services, finsh and reboot
```
xbps-install git NetworkManager
ln -s /etc/sv/dhcpcd /var/service
ln -s /etc/sv/NetworkManager /var/service
xbps-reconfigure -fa
exit
reboot
```


