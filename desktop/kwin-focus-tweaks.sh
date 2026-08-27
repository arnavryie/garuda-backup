#!/usr/bin/env bash
# KDE Window Management Tweaks:
# 1. Shows titlebar & Minimize/Maximize/Close buttons ALWAYS (even when maximized)
# 2. Disables Focus Stealing Prevention so links and new windows pop up immediately in front
set -e

kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows false
kwriteconfig6 --file kwinrc --group Windows --key FocusStealingPreventionLevel 0
kwriteconfig6 --file kwinrc --group Windows --key FocusPolicyClickRaises true
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

echo "==> KDE Window Pop-Up & Titlebar Button settings applied!"
