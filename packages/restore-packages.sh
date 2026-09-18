#!/usr/bin/env bash
# ==============================================================================
# 📦 Package Restoration Script for Garuda Linux
# Author: arnavryie
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== [1/3] Restoring Native Pacman Packages ==="
if [ -f "$DIR/pacman-explicit.txt" ]; then
    sudo pacman -S --needed --noconfirm - < "$DIR/pacman-explicit.txt" || true
fi

echo "=== [2/3] Restoring AUR Packages ==="
AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
fi

if [ -n "$AUR_HELPER" ] && [ -f "$DIR/aur-packages.txt" ]; then
    "$AUR_HELPER" -S --needed --noconfirm - < "$DIR/aur-packages.txt" || true
else
    echo "Warning: Neither paru nor yay found to install AUR packages."
fi

echo "=== [3/3] Restoring Flatpak Packages ==="
if command -v flatpak >/dev/null 2>&1 && [ -f "$DIR/flatpak-packages.txt" ]; then
    while IFS= read -r app; do
        [ -z "$app" ] && continue
        echo "Installing flatpak: $app..."
        flatpak install -y --user flathub "$app" || true
    done < "$DIR/flatpak-packages.txt"
fi

echo "[✓] All packages, AUR utilities, and Flatpaks restored successfully!"
