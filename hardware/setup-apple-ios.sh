#!/usr/bin/env bash
# ==============================================================================
# Apple iPhone USB Tethering & Dolphin File Manager (AFC) Integration
# Author: arnavryie
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==> [Apple iOS] Installing USB Tethering & File Manager Integration...${NC}"

# 1. Install required Apple device & filesystem packages
echo -e "${CYAN}==> [1/4] Installing ifuse, gvfs-afc, gvfs-gphoto2, and libimobiledevice...${NC}"
sudo pacman -S --noconfirm --needed usbmuxd libimobiledevice ifuse gvfs-afc gvfs-gphoto2

# 2. Autoload ipheth (Apple iPhone USB Ethernet) kernel module on boot
echo -e "${CYAN}==> [2/4] Configuring ipheth kernel module autoloading...${NC}"
echo "ipheth" | sudo tee /etc/modules-load.d/ipheth.conf > /dev/null
sudo modprobe ipheth 2>/dev/null || true

# 3. Enable and start usbmuxd socket daemon
echo -e "${CYAN}==> [3/4] Enabling usbmuxd service...${NC}"
sudo systemctl enable --now usbmuxd.service

# 4. Restart GVFS so Dolphin immediately picks up Apple devices
echo -e "${CYAN}==> [4/4] Refreshing GVFS for Dolphin...${NC}"
killall -q gvfsd || true

echo -e "${GREEN}[✓] Apple iPhone USB Tethering and Dolphin File Access are fully installed!${NC}"
echo -e "${CYAN}Tip: Keep your iPhone unlocked when plugging in, toggle 'Personal Hotspot' ON, and tap 'Trust This Computer'.${NC}"
