#!/usr/bin/env bash
# ==============================================================================
# Garuda Linux + Lenovo LOQ Master Setup & Recovery Script
# Author: arnavryie
# ==============================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="$(whoami)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "=================================================================="
    echo "       Garuda Linux - Lenovo LOQ Auto-Setup & System Backup       "
    echo "=================================================================="
    echo -e "${NC}"
}

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[!] Sudo privileges required for system tweaks.${NC}"
        sudo -v || exit 1
    fi
}

install_storage() {
    echo -e "\n${CYAN}[1/4] Configuring Secondary Storage SSD & Dolphin...${NC}"
    check_sudo
    sudo bash "$REPO_DIR/storage/setup-storage.sh"
    bash "$REPO_DIR/storage/install-dolphin.sh"
    echo -e "${GREEN}[✓] Storage and Dolphin configuration complete!${NC}"
}

install_hardware() {
    echo -e "\n${CYAN}[2/4] Installing Lenovo LOQ Hardware & Touchpad Fixes...${NC}"
    check_sudo
    sudo bash "$REPO_DIR/hardware/install-touchpad.sh"
    echo -e "${GREEN}[✓] Hardware & Touchpad fixes applied!${NC}"
}

install_gaming() {
    echo -e "\n${CYAN}[3/4] Configuring Steam, Wine & DirectX 12 / DXVK Gaming...${NC}"
    check_sudo
    bash "$REPO_DIR/gaming/setup-wine-gaming.sh"
    sudo cp "$REPO_DIR/gaming/environment" /etc/environment 2>/dev/null || true
    echo -e "${GREEN}[✓] Gaming, Steam & Wine DX12 setup complete!${NC}"
}

install_gestures() {
    echo -e "\n${CYAN}[4/4] Setting Up Touchpad Gestures...${NC}"
    mkdir -p "$HOME/.config/autostart"
    cp "$REPO_DIR/gestures/libinput-gestures.desktop" "$HOME/.config/autostart/" 2>/dev/null || true
    systemctl --user restart libinput-gestures 2>/dev/null || true
    echo -e "${GREEN}[✓] Gestures configured!${NC}"
}

run_full_setup() {
    install_storage
    install_hardware
    install_gaming
    install_gestures
    echo -e "\n${GREEN}${BOLD}==================================================================${NC}"
    echo -e "${GREEN}${BOLD} [SUCCESS] All tweaks & configurations have been installed!      ${NC}"
    echo -e "${GREEN}${BOLD}==================================================================${NC}"
}

# Menu
print_header
echo -e "${BOLD}Select an option:${NC}"
echo -e " ${GREEN}[1]${NC} 🚀 ${BOLD}Full Automated Setup (Recommended on fresh install)${NC}"
echo -e " ${CYAN}[2]${NC} 💽 Configure Storage SSD & Dolphin Shortcuts"
echo -e " ${CYAN}[3]${NC} 💻 Install Lenovo Touchpad Fix (ELAN06FA i2c-hid)"
echo -e " ${CYAN}[4]${NC} 🎮 Setup Steam Wayland Fix & Wine DX12 / DXVK"
echo -e " ${CYAN}[5]${NC} 🖱️ Setup Touchpad Gestures"
echo -e " ${RED}[0]${NC} Exit"
echo ""
read -rp "Enter choice [1-5, or 0]: " choice

case "$choice" in
    1) run_full_setup ;;
    2) install_storage ;;
    3) install_hardware ;;
    4) install_gaming ;;
    5) install_gestures ;;
    0) echo "Exiting..."; exit 0 ;;
    *) echo -e "${RED}Invalid option.${NC}"; exit 1 ;;
esac
