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

# Apply Persistent 100GB NVIDIA Shader Cache (Anti-wipe across reboots)
if [ -f "$SCRIPT_DIR/environment" ]; then
    sudo cp "$SCRIPT_DIR/environment" /etc/environment
fi
if [ -f "$SCRIPT_DIR/99-nvidia-shadercache.conf" ]; then
    sudo mkdir -p /etc/environment.d
    sudo cp "$SCRIPT_DIR/99-nvidia-shadercache.conf" /etc/environment.d/
fi
if [ -f "$SCRIPT_DIR/nvidia-shadercache.sh" ]; then
    sudo cp "$SCRIPT_DIR/nvidia-shadercache.sh" /etc/profile.d/
fi
if [ -f "$SCRIPT_DIR/10-gaming-optimizations.conf" ]; then
    mkdir -p "$HOME/.config/environment.d"
    cp "$SCRIPT_DIR/10-gaming-optimizations.conf" "$HOME/.config/environment.d/"
fi

# Apply Gaming Low-Latency & Anti-Bufferbloat Network Stack
if [ -f "$SCRIPT_DIR/99-gaming-network.conf" ]; then
    sudo cp "$SCRIPT_DIR/99-gaming-network.conf" /etc/sysctl.d/
    sudo sysctl -p /etc/sysctl.d/99-gaming-network.conf 2>/dev/null || true
fi
if [ -f "$SCRIPT_DIR/default-wifi-powersave-off.conf" ]; then
    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo cp "$SCRIPT_DIR/default-wifi-powersave-off.conf" /etc/NetworkManager/conf.d/
fi

echo "==> Wine Gaming, Steam Wayland, 100GB Shader Cache & Low-Latency Network fixes successfully applied!"
