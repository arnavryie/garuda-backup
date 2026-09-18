#!/usr/bin/env bash
# ==============================================================================
# 🎨 Garuda Linux KDE Desktop, Theme, Taskbar & Widgets Restoration Script
# Author: arnavryie
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== [1/7] Restoring Themes, Window Decorations & Color Schemes ==="
mkdir -p ~/.local/share/plasma/desktoptheme/ ~/.local/share/color-schemes/ ~/.local/share/aurorae/themes/
cp -rn "$DIR/desktoptheme/"* ~/.local/share/plasma/desktoptheme/ 2>/dev/null || true
cp -rn "$DIR/color-schemes/"* ~/.local/share/color-schemes/ 2>/dev/null || true
cp -rn "$DIR/aurorae/"* ~/.local/share/aurorae/themes/ 2>/dev/null || true

echo "=== [2/7] Restoring Custom Plasmoids (Life OS, Workspace Dots, etc.) ==="
mkdir -p ~/.local/share/plasma/plasmoids/
cp -r "$DIR/plasmoids/"* ~/.local/share/plasma/plasmoids/ 2>/dev/null || true

echo "=== [3/7] Restoring Pinned Applications, Web Apps & Desktop Launchers ==="
mkdir -p ~/.local/share/applications/ ~/Desktop/ ~/.local/share/icons/hicolor/
cp -p "$DIR/applications/"*.desktop ~/.local/share/applications/ 2>/dev/null || true
cp -p "$DIR/desktop-items/"*.desktop ~/Desktop/ 2>/dev/null || true
cp -r "$DIR/hicolor-icons/"* ~/.local/share/icons/hicolor/ 2>/dev/null || true
[ -f "$DIR/hicolor-icons/life-os.png" ] && cp -p "$DIR/hicolor-icons/life-os.png" ~/.local/share/icons/ 2>/dev/null || true

echo "=== [4/7] Restoring Life OS Configurations & Autostart ==="
mkdir -p ~/.config/autostart/
cp -r "$DIR/life-os/"life-os* ~/.config/ 2>/dev/null || true
cp -p "$DIR/life-os/life-os.desktop" ~/.config/autostart/ 2>/dev/null || true

echo "=== [5/7] Restoring Terminal, Shell & Konsole Configs ==="
mkdir -p ~/.config/fish/ ~/.local/share/konsole/
[ -f "$DIR/plasma-config/starship.toml" ] && cp -p "$DIR/plasma-config/starship.toml" ~/.config/
[ -f "$DIR/plasma-config/fish/config.fish" ] && cp -p "$DIR/plasma-config/fish/config.fish" ~/.config/fish/
cp -r "$DIR/plasma-config/konsole/"* ~/.local/share/konsole/ 2>/dev/null || true

echo "=== [6/7] Restoring Plasma Panel, Taskbar, Widgets & Hotkeys Configs ==="
mkdir -p ~/.config/
cp -p "$DIR/plasma-config/plasma-org.kde.plasma.desktop-appletsrc" ~/.config/
cp -p "$DIR/plasma-config/plasmashellrc" ~/.config/
cp -p "$DIR/plasma-config/kdeglobals" ~/.config/
cp -p "$DIR/plasma-config/kwinrc" ~/.config/
cp -p "$DIR/plasma-config/kwinrulesrc" ~/.config/
cp -p "$DIR/plasma-config/kglobalshortcutsrc" ~/.config/
cp -p "$DIR/plasma-config/kcminputrc" ~/.config/
cp -p "$DIR/plasma-config/plasmarc" ~/.config/
[ -f "$DIR/plasma-config/powermanagementprofilesrc" ] && cp -p "$DIR/plasma-config/powermanagementprofilesrc" ~/.config/
[ -f "$DIR/plasma-config/konsolerc" ] && cp -p "$DIR/plasma-config/konsolerc" ~/.config/

echo "=== [7/7] Applying Desktop & Window Manager Changes ==="
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    echo "Reloading Plasmashell..."
    systemctl --user restart plasma-plasmashell.service 2>/dev/null || true
fi

echo "[✓] Plasma theme, panels, taskbars, thermal sensors, pinned apps & shortcuts fully restored!"
