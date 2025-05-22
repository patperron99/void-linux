#!/bin/bash
set -e

echo "Installing PipeWire and related packages..."

# Install required packages
sudo xbps-install -y pipewire wireplumber alsa-pipewire \
  xdg-desktop-portal xdg-desktop-portal-wlr

echo "Disabling PulseAudio if installed..."
# Optional: disable pulseaudio if it's running or present
if pgrep -x pulseaudio >/dev/null; then
  killall pulseaudio
fi
sudo rm -f /etc/sv/pulseaudio /var/service/pulseaudio
echo "PulseAudio disabled."

echo "Enabling ALSA to use PipeWire..."
# Set up ALSA to use pipewire
sudo mkdir -p /etc/alsa/conf.d/
sudo ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
sudo ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

echo "Setting up PipeWire and WirePlumber for user session..."

# Ensure pipewire and wireplumber start with the user session
mkdir -p ~/.config/pipewire

# If you're using `dbus-launch` or `sway` with dbus, add these to sway config:
echo "Add the following lines to your ~/.config/sway/config if not already present:"
echo "
exec dbus-launch --sh-syntax --exit-with-session sway
exec wireplumber
exec pipewire
exec pipewire-pulse
"

# Alternatively, launch from your sway config directly (no systemd):
mkdir -p ~/.config/sway
cat <<EOF >> ~/.config/sway/config

# PipeWire (audio)
exec wireplumber
exec pipewire
exec pipewire-pulse

# XDG Desktop Portal for screen sharing
exec xdg-desktop-portal-wlr
EOF

echo "Setup complete. Please reboot or restart your sway session."
