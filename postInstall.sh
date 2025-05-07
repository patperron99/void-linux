#!/bin/bash

# List of packages to install
packages=(
    openssh
    runit
    bash-completion
    git
    i3
    dunst
    kitty
    alacritty
    picom
    neovim
    curl
    wget
    blueman
    pulseaudio
    pavucontrol
    acpi
    xclip
    arandr
    lightdm
    ripgrep
    psmisc
    lxappearance
    lxsession
    rofi
    stow
    polybar
    feh
    tmux
    gnome-disk-utility
    gnome-calculator
    flatpak
    shellcheck
    xfce4-power-manager
    flameshot
    fwupd
    nerd-fonts
    gcc
    fastfetch
    btop
    xorg
    tar
    coreutils
    binutils
    util-linux
    lightdm-webkit2-greeter
    dbus
    elogind
    cmake
    cmatrix
    betterlockscreen
    network-manager-applet
    tumbler
    tumbler-plugins-extra
    slurp
    swappy
    grim
    wlogout
    autotiling
    swayfx
    Waybar
)

# Update the package database
sudo xbps-install -S

# Install each package
for package in "${packages[@]}"; do
    sudo xbps-install -y "$package"
done

# Adding flat pack repos
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Zen Browser
sudo flatpak install -y flathub app.zen_browser.zen

# Activating runit services
sudo ln -s /etc/sv/lightdm /var/service
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/elogind /var/service
sudo ln -s /etc/sv/bluetoothd/ /var/service

echo "Post-installation script completed. All packages have been installed."
