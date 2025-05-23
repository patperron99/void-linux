#!/bin/bash
# Repository packags.
repos=(
  void-repo-multilib
  void-repo-nonfree
  void-repo-nonfree-multilib
)

# List of packages to install
packages=(
  NetworkManager
  NetworkManager-openvpn
  Thunar
  Waybar
  acpi
  alacritty
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
  libgcc-32bit
  libstdc++-32bit
  linux-firmware
  linux-mainline
  lshw
  lxappearance
  lxsession
  make
  neovim
  nerd-fonts
  nodejs-lts
  pavucontrol
  plymouth
  psmisc
  pulseaudio
  python3-PyQt5-devel
  python3-PyQt5-devel-tools
  python3-pip
  qt6-multimedia
  qt6-virtualkeyboard
  ripgrep
  rofi
  sddm
  seatd
  shellcheck
  slurp
  stow
  swappy
  swayfx
  timeshift
  tldr
  tmux
  tumbler
  tumbler-plugins-extra
  vivaldi
  wdisplays
  wget
  wlogout
  wlr-randr
  wlroots
  xclip
  xdg-desktop-portal
  xdg-desktop-portal-wlr
  xdg-desktop-portal-gtk
  xdg-user-dirs
  xdg-utils
  xfce4-power-manager
  xorg-server-xephyr
  yazi
)

extra_packages=(
  Signal-Desktop
  steam
  libvirt
  krita
  qemu
  podman
  virt-manager
  ansible
)

video_packages=(
  mesa-32bit
  mesa-vulkan-radeon
  mesa-vulkan-radeon-32bit
  vulkan-loader-32bit
)

failed_packages=()

# Add the Repositories
for repo in "${repos[@]}"; do
  if sudo xbps-install -y "$repo"; then
    echo "Successfully added ${repo} repository"
  else
    echo "Failed to add ${repo} repository"
    failed_packages+=("${repo}")
  fi
done

# Update the package database
sudo xbps-install -Su

# Install each package
for package in "${packages[@]}"; do
  if sudo xbps-install -y "$package"; then
    echo "Successfully install ${package}"
  else
    echo "Failed to install ${package}"
    failed_packages+=("${package}")
  fi
done

# ask to install extra packages.
read -p "Do you want to install extra packages? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  for package in "${extra_packages[@]}"; do
    if sudo xbps-install -y "$package"; then
      echo "Successfully install ${package}"
    else
      echo "Failed to install ${package}"
      failed_packages+=("${package}")
    fi
  done
fi

# ask to install video packages.
read -p "Do you want to install video packages? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  for package in "${video_packages[@]}"; do
    if sudo xbps-install -y "$package"; then
      echo "Successfully install ${package}"
    else
      echo "Failed to install ${package}"
      failed_packages+=("${package}")
    fi
  done
fi

# Adding flat pack repos
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Activating runit services
sudo ln -s /etc/sv/lightdm /var/service/
sudo ln -s /etc/sv/dbus /var/service/
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
