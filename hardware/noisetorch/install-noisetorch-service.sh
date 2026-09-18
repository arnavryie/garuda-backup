#!/usr/bin/env bash
# ==============================================================================
# NoiseTorch Smart Battery & Fifine Hardware Auto-Start Installer
# Author: arnavryie
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing NoiseTorch Smart Battery & Fifine Auto-Start Service ==="

# 1. User local script and systemd services
mkdir -p ~/.local/bin ~/.config/systemd/user/pipewire-pulse.service.d/
cp "$DIR/noisetorch-smart-guard.sh" ~/.local/bin/noisetorch-smart-guard.sh
chmod +x ~/.local/bin/noisetorch-smart-guard.sh

cp "$DIR/pipewire-pulse.service.d/override.conf" ~/.config/systemd/user/pipewire-pulse.service.d/
cp "$DIR/noisetorch.service" ~/.config/systemd/user/

# 2. System udev rules and hotplug triggers (requires sudo)
if [ "$EUID" -eq 0 ]; then
    cp "$DIR/noisetorch-power-guard-trigger.sh" /usr/local/bin/
    chmod +x /usr/local/bin/noisetorch-power-guard-trigger.sh
    cp "$DIR/99-noisetorch-power-guard.rules" /etc/udev/rules.d/
    udevadm control --reload-rules
    udevadm trigger -s power_supply 2>/dev/null || true
else
    if command -v sudo >/dev/null 2>&1; then
        sudo cp "$DIR/noisetorch-power-guard-trigger.sh" /usr/local/bin/
        sudo chmod +x /usr/local/bin/noisetorch-power-guard-trigger.sh
        sudo cp "$DIR/99-noisetorch-power-guard.rules" /etc/udev/rules.d/
        sudo udevadm control --reload-rules
        sudo udevadm trigger -s power_supply 2>/dev/null || true
    fi
fi

# 3. Reload and enable systemd user services
systemctl --user daemon-reload
systemctl --user restart pipewire-pulse 2>/dev/null || true
systemctl --user enable --now noisetorch.service

echo "[✓] NoiseTorch Smart Guard and Dynamic Battery/Hardware Service successfully installed!"
