#!/bin/bash
# This script installs a set of packages on a Void Linux system.
set -e
# Update the system
xbps-install -Syu

# Install repos
xbps-install -y void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree

# Packages List
packages=(
  NetworkManager
  NetworkManager-openvpn
  Thunar
  Waybar
  alsa-ucm-conf
  alsa-utils
  ansible
  autotiling
  base-devel
  base-system
  bash-completion
  bat
  blueman
  brightnessctl
  btop
  chromium
  curl
  dbus
  docker
  dunst
  elogind
  fastfetch
  flatpak
  foot
  fwupd
  fzf
  ghostty
  git
  glxinfo
  gnome-calculator
  gnome-disk-utility
  grim
  grub-x86_64-efi
  gvfs
  kitty
  lazygit
  light
  lightdm
  lightdm-webkit2-greeter
  lshw-B.02.20_1
  lxappearance
  mesa-demos
  mesa-dri
  neovim
  nerd-fonts
  network-manager-applet
  nodejs
  pavucontrol
  pipewire
  polkit
  psmisc
  pulseaudio
  pulseaudio-utils
  qt5-graphicaleffects
  qt5-quickcontrols2
  qt5ct
  qt6-svg
  ripgrep
  rofi
  sddm
  slurp
  sof-firmware
  stow
  swappy
  swayfx
  swaylock
  udisks2
  vivaldi
  void-repo-multilib
  void-repo-multilib-nonfree
  void-repo-nonfree
  wget
  wireplumber
  wl-clipboard
  wlogout
  wlr-randr
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  xdg-user-dirs
  xf86-video-nouveau
  xfce4-power-manager
  xorg-minimal
  xorg-server-xephyr
)

failed_packages=()

# Install Packages
for package in "${packages[@]}"; do
  xbps-install -y "$package"
  if [ $? -ne 0 ]; then
    echo "Failed to install $package"
    failed_packages+=("$package")
  else
    echo "Successfully installed $package"
  fi
done

# Show failed failed_packages
if [ ${#failed_packages[@]} -ne 0 ]; then
  echo "The following packages failed to install:"
  for failed in "${failed_packages[@]}"; do
    echo "- $failed"
  done
else
  echo "All packages installed successfully."
fi




