#!/usr/bin/env bash
# ==============================================================================
# 🚀 Garuda Linux 1-Click Master System Reincarnation Script
# Restores: Packages, Theme, Panels, Pinned Apps, Widgets, Mic Guard, Game Saves & Docs
# Author: arnavryie
# ==============================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "=================================================================="
echo "      Garuda Linux Full System Recovery & Reincarnation Suite     "
echo "=================================================================="
echo -e "${NC}"

echo -e "\n${CYAN}[1/5] Restoring Plasma Desktop Theme, Taskbars, Widgets & Pinned Apps...${NC}"
bash "$REPO_DIR/desktop/restore-desktop-theme.sh"

echo -e "\n${CYAN}[2/5] Restoring NoiseTorch Smart Mic Noise Cancellation & Power Guard...${NC}"
bash "$REPO_DIR/hardware/noisetorch/install-noisetorch-service.sh"

echo -e "\n${CYAN}[3/5] Restoring Secondary Storage Shortcuts & Dolphin Places...${NC}"
bash "$REPO_DIR/storage/install-dolphin.sh" 2>/dev/null || true

echo -e "\n${CYAN}[4/5] Restoring Game Saves, Documents & Icons from Secondary SSD...${NC}"
if [ -d "/mnt/Storage/Garuda-Full-Backup" ]; then
    bash "$REPO_DIR/storage/restore-from-storage.sh"
    echo -e "${GREEN}[✓] Game saves, documents & icons restored from /mnt/Storage!${NC}"
else
    echo -e "${YELLOW}[!] /mnt/Storage/Garuda-Full-Backup not found. Skipping offline save restoration.${NC}"
fi

echo -e "\n${CYAN}[5/5] Reinstalling Explicit Packages & Flatpaks...${NC}"
read -rp "Do you want to reinstall all packages and Flatpaks now? [y/N]: " pkg_choice
if [[ "$pkg_choice" =~ ^[Yy]$ ]]; then
    bash "$REPO_DIR/packages/restore-packages.sh"
fi

echo -e "\n${GREEN}${BOLD}==================================================================${NC}"
echo -e "${GREEN}${BOLD} [SUCCESS] Your Garuda Linux system has been fully restored!     ${NC}"
echo -e "${GREEN}${BOLD}==================================================================${NC}"
