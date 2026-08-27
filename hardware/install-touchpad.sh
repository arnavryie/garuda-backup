#!/usr/bin/env bash
# Installs and enables the Lenovo ELAN06FA Touchpad Fix service
set -e

if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run with sudo."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing Lenovo Touchpad Fix service..."
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

echo "==> Touchpad service installed and active!"
