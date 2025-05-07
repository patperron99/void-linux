#!/bin/bash

# Void Linux AMD GPU + Steam Setup Script
# For: RX 5700 XT + i3wm + glibc (x86_64)

set -e

echo "🔧 Updating system..."
sudo xbps-install -Syu

echo "🎮 Installing AMD GPU Drivers & Vulkan..."
sudo xbps-install -y \
    mesa-dri \
    mesa-vulkan-radeon \
    vulkan-loader \
    linux-firmware-amd \
    linux-firmware

echo "🧱 Installing 32-bit Vulkan support for Steam (multilib)..."
sudo xbps-install -y \
    mesa-32bit \
    vulkan-loader-32bit \
    mesa-vulkan-radeon-32bit \
    libgcc-32bit \
    libstdc++-32bit \
    glibc-32bit

echo "🔥 Enabling amdgpu driver..."
# Usually done automatically, but just to be safe
echo "blacklist radeon" | sudo tee /etc/modprobe.d/disable-radeon.conf

echo "🛒 Installing Steam..."
sudo xbps-install -y steam

echo "✅ Done! Reboot to finish setup."
echo "👉 After reboot, run Steam from your launcher or terminal: steam"
