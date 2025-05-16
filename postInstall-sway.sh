#!/bin/bash

# List of packages to install
packages=(
  void-repo-multilib
  void-repo-nonfree
  NetworkManager
  NetworkManager-openvpn
  Signal-Desktop
  Thunar
  Waybar
  acpi
  alacritty
  ansible
  autotiling
  base-devel
  base-system
  bash-completion
  bat
  blueman
  btop
  btrfs-progs
  cmake
  cryptsetup
  curl
  dunst
  elogind
  fastfetch
  flatpak
  fwupd
  gcc
  git
  glibc-32bit
  gnome-calculator
  gnome-disk-utility
  grim
  grub-customizer
  grub-x86_64-efi
  kitty
  krita
  libgcc-32bit
  libstdc++-32bit
  libvirt
  lightdm
  lightdm-gtk-greeter-settings
  lightdm-webkit2-greeter
  linux-firmware
  linux-mainline
  lshw
  lxappearance
  lxsession
  make
  mesa-32bit
  mesa-vulkan-radeon
  mesa-vulkan-radeon-32bit
  neovim
  nerd-fonts
  nodejs-lts
  pavucontrol
  plymouth
  podman
  psmisc
  pulseaudio
  python3-PyQt5-devel
  python3-PyQt5-devel-tools
  python3-pip
  qemu
  qt6-multimedia
  qt6-virtualkeyboard
  ripgrep
  shellcheck
  slurp
  steam
  stow
  swappy
  swayfx
  timeshift
  tldr
  tmux
  tumbler
  tumbler-plugins-extra
  vim
  virt-manager
  vivaldi
  vulkan-loader-32bit
  wdisplays
  wget
  wlogout
  wlr-randr
  xclip
  xdg-desktop-portal-wlr
  xdg-user-dirs
  xdg-utils
  xfce4-power-manager
  xorg-server-xephyr
  yazi
)

failed_packages=()

# Update the package database
sudo xbps-install -S

# Install each package
for package in "${packages[@]}"; do
    if sudo xbps-install -y "$package"; then
      echo "Successfully install ${package}"
    else
      echo "Failed to install ${package}"
      failed_packages+=("${package}")
done


# Adding flat pack repos
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


# Activating runit services
sudo ln -s /etc/sv/lightdm /var/service/
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
sudo ln -s /etc/sv/bluetoothd /var/service/


# Notify about failed packages
if [ ${#failed_packages[@]} -ne 0 ]; then
    echo "The following packages failed to install:"
    for pkg in "${failed_packages[@]}"; do
        echo "$pkg"
    done
else
    echo "All packages installed successfully."
fi
