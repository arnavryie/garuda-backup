#!/usr/bin/env bash
# Installs and enables the Lenovo ELAN06FA Touchpad Fix, Lenovo Legion Linux tools, and Gaming Power Tuning
set -e

if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run with sudo."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [1/3] Installing Lenovo Touchpad Fix service..."
cp "$SCRIPT_DIR/touchpad-fix.service" /etc/systemd/system/touchpad-fix.service
chmod 644 /etc/systemd/system/touchpad-fix.service

systemctl daemon-reload
systemctl enable --now touchpad-fix.service

# Trigger immediate rebind if needed
if [ -e /sys/bus/i2c/drivers/i2c_hid_acpi/unbind ]; then
    echo -n "i2c-ELAN06FA:00" > /sys/bus/i2c/drivers/i2c_hid_acpi/unbind 2>/dev/null || true
    sleep 1
    echo -n "i2c-ELAN06FA:00" > /sys/bus/i2c/drivers/i2c_hid_acpi/bind 2>/dev/null || true
fi

echo "==> [2/3] Installing Lenovo Legion Linux (Toolkit equivalent for Linux)..."
if ! pacman -Qs lenovolegionlinux-git >/dev/null 2>&1; then
    pacman -S --noconfirm --needed lenovolegionlinux-dkms-git lenovolegionlinux-git
fi
echo "legion-laptop" > /etc/modules-load.d/legion-laptop.conf
modprobe legion-laptop 2>/dev/null || true
systemctl enable --now legiond.service 2>/dev/null || true

echo "==> [3/3] Installing Power & Gaming Optimizer (Prevents Quiet Mode Stutter)..."
cp "$SCRIPT_DIR/lenovo-gaming-tuning.service" /etc/systemd/system/lenovo-gaming-tuning.service
chmod 644 /etc/systemd/system/lenovo-gaming-tuning.service
systemctl daemon-reload
systemctl enable --now lenovo-gaming-tuning.service

echo "==> Lenovo Hardware, Touchpad, and Power Optimization complete!"
