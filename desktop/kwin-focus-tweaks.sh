#!/usr/bin/env bash
# ==============================================================================
# KDE Desktop & App Tweaks
# 1. Shows titlebar & Minimize/Maximize/Close buttons ALWAYS
# 2. Disables Focus Stealing Prevention so links and new windows pop up immediately in front
# 3. Applies optimized Wayland flags for Microsoft Edge (no freezing)
# 4. Forces Picture-in-Picture (PiP) video windows to ALWAYS stay on top
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# KDE Window Management (Focus Follows Mouse - Hyprland style)
kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows false
kwriteconfig6 --file kwinrc --group Windows --key FocusStealingPreventionLevel 0
kwriteconfig6 --file kwinrc --group Windows --key FocusPolicy FocusFollowsMouse
kwriteconfig6 --file kwinrc --group Windows --key DelayFocusInterval 0
kwriteconfig6 --file kwinrc --group Windows --key FocusPolicyClickRaises true
kwriteconfig6 --file kwinrc --group Windows --key NextFocusPrefersMouse true

# Shortcut: Win + Q (Meta+Q) to Close/Quit Window (Hyprland style killactive)
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "manage activities" "none,none,Show Activity Switcher"
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" "Alt+F4\tMeta+Q,Alt+F4,Close Window"
busctl --user call org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel setForeignShortcutKeys "asa(ai)" 4 "plasmashell" "manage activities" "plasmashell" "Show Activity Switcher" 0 2>/dev/null || true
busctl --user call org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel setForeignShortcutKeys "asa(ai)" 4 "kwin" "Window Close" "KWin" "Close Window" 2 4 268435537 0 0 0 4 150994995 0 0 0 2>/dev/null || true

# Picture-in-Picture Always on Top Rule
mkdir -p "$HOME/.config"
cp "$SCRIPT_DIR/kwinrulesrc" "$HOME/.config/kwinrulesrc" 2>/dev/null || true

qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

# Microsoft Edge Wayland Flags
cp "$SCRIPT_DIR/microsoft-edge-stable-flags.conf" "$HOME/.config/microsoft-edge-stable-flags.conf" 2>/dev/null || true
cp "$SCRIPT_DIR/microsoft-edge-stable-flags.conf" "$HOME/.config/microsoft-edge-flags.conf" 2>/dev/null || true

# Install / update Workspace Dots plasmoid (Plasma 6 DBus desktop switcher)
if [ -d "$SCRIPT_DIR/plasmoids/org.garuda.hyprlandworkspaces" ]; then
    mkdir -p "$HOME/.local/share/plasma/plasmoids"
    cp -r "$SCRIPT_DIR/plasmoids/org.garuda.hyprlandworkspaces" "$HOME/.local/share/plasma/plasmoids/"
    echo "==> Workspace Dots (Desktop Switcher) plasmoid installed!"
fi

echo "==> KDE Window Pop-Up, Titlebar Buttons, PiP Always-on-Top, Workspace Dots & Edge flags applied!"
