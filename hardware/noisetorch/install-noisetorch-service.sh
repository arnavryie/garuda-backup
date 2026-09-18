#!/usr/bin/env bash
set -e
mkdir -p ~/.config/systemd/user/pipewire-pulse.service.d/
cp "$(dirname "$0")/pipewire-pulse.service.d/override.conf" ~/.config/systemd/user/pipewire-pulse.service.d/
cp "$(dirname "$0")/noisetorch.service" ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user restart pipewire-pulse
systemctl --user enable --now noisetorch.service
echo "[✓] NoiseTorch autostart service installed and running!"
