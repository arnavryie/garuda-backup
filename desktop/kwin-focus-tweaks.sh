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

# KDE Window Management
kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows false
kwriteconfig6 --file kwinrc --group Windows --key FocusStealingPreventionLevel 0
kwriteconfig6 --file kwinrc --group Windows --key FocusPolicyClickRaises true

# Picture-in-Picture Always on Top Rule
mkdir -p "$HOME/.config"
cp "$SCRIPT_DIR/kwinrulesrc" "$HOME/.config/kwinrulesrc" 2>/dev/null || true

qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

# Microsoft Edge Wayland Flags
cp "$SCRIPT_DIR/microsoft-edge-stable-flags.conf" "$HOME/.config/microsoft-edge-stable-flags.conf" 2>/dev/null || true
cp "$SCRIPT_DIR/microsoft-edge-stable-flags.conf" "$HOME/.config/microsoft-edge-flags.conf" 2>/dev/null || true

echo "==> KDE Window Pop-Up, Titlebar Buttons, PiP Always-on-Top & Edge flags applied!"
