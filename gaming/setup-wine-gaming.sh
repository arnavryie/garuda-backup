#!/usr/bin/env bash
# Configures Wine with DirectX 11 (DXVK) and DirectX 12 (VKD3D-Proton),
# maps D:\ drive to /mnt/Storage, and sets .exe file associations.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [1/4] Installing VKD3D-Proton and DXVK packages..."
if ! pacman -Qs vkd3d-proton-mingw-git >/dev/null 2>&1; then
    sudo pacman -S --noconfirm --needed vkd3d-proton-mingw-git
fi

echo "==> [2/4] Setting up DXVK & VKD3D in ~/.wine..."
setup_dxvk install || true
setup_vkd3d_proton install || true

echo "==> [3/4] Mapping D: drive in Wine to /mnt/Storage..."
mkdir -p "$HOME/.wine/dosdevices"
ln -sfn /mnt/Storage "$HOME/.wine/dosdevices/d:"

echo "==> [4/4] Setting Wine as default for .exe files..."
mkdir -p "$HOME/.config"
cp "$SCRIPT_DIR/mimeapps.list" "$HOME/.config/mimeapps.list" 2>/dev/null || true
xdg-mime default wine.desktop application/x-ms-dos-executable 2>/dev/null || true
xdg-mime default wine.desktop application/x-msdownload 2>/dev/null || true
xdg-mime default wine.desktop application/x-msi 2>/dev/null || true
xdg-mime default wine.desktop application/x-bat 2>/dev/null || true

# Apply Steam Wayland Fix
mkdir -p "$HOME/.local/share/applications"
cp "$SCRIPT_DIR/steam.desktop" "$HOME/.local/share/applications/steam.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "==> Wine Gaming and Steam Wayland fixes successfully applied!"
