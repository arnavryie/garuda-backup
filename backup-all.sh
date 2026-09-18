#!/usr/bin/env bash
# ==============================================================================
# 🔄 Garuda Linux Master System Backup & Snapshot Script
# Takes a full snapshot to GitHub (configs/themes/packages) + Secondary SSD (game saves/docs/icons)
# Author: arnavryie
# ==============================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== [1/5] Updating Package Manifests ==="
mkdir -p "$REPO_DIR/packages"
pacman -Qqe | sort > "$REPO_DIR/packages/pacman-explicit.txt"
pacman -Qqm | sort > "$REPO_DIR/packages/aur-packages.txt"
flatpak list --app --columns=application > "$REPO_DIR/packages/flatpak-packages.txt" 2>/dev/null || true

echo "=== [2/5] Updating Plasma Theme, Panels, Taskbars & Shortcut Configs ==="
mkdir -p "$REPO_DIR/desktop/plasma-config"
cp -p ~/.config/plasma-org.kde.plasma.desktop-appletsrc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/plasmashellrc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/kdeglobals "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/kwinrc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/kwinrulesrc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/kglobalshortcutsrc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/kcminputrc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/plasmarc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/powermanagementprofilesrc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/konsolerc "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
cp -p ~/.config/starship.toml "$REPO_DIR/desktop/plasma-config/" 2>/dev/null || true
mkdir -p "$REPO_DIR/desktop/plasma-config/fish"
cp -p ~/.config/fish/config.fish "$REPO_DIR/desktop/plasma-config/fish/" 2>/dev/null || true
mkdir -p "$REPO_DIR/desktop/plasma-config/konsole"
cp -r ~/.local/share/konsole/* "$REPO_DIR/desktop/plasma-config/konsole/" 2>/dev/null || true

echo "=== [3/5] Updating Pinned Apps, Custom Plasmoids & Desktop Launchers ==="
mkdir -p "$REPO_DIR/desktop/applications" "$REPO_DIR/desktop/desktop-items" "$REPO_DIR/desktop/plasmoids" "$REPO_DIR/desktop/life-os"
cp -p ~/.local/share/applications/*.desktop "$REPO_DIR/desktop/applications/" 2>/dev/null || true
cp -p ~/Desktop/*.desktop "$REPO_DIR/desktop/desktop-items/" 2>/dev/null || true
cp -r ~/.local/share/plasma/plasmoids/* "$REPO_DIR/desktop/plasmoids/" 2>/dev/null || true
cp -r ~/.config/life-os* "$REPO_DIR/desktop/life-os/" 2>/dev/null || true
cp -p ~/.config/autostart/life-os.desktop "$REPO_DIR/desktop/life-os/" 2>/dev/null || true

echo "=== [4/5] Syncing Game Saves, Documents & Icons to Secondary SSD ==="
bash "$REPO_DIR/storage/backup-to-storage.sh"

echo "=== [5/5] Git Syncing to Remote Repository ==="
cd "$REPO_DIR"
git add .
if ! git diff --cached --quiet; then
    git commit -m "chore(backup): automated system snapshot [$(date '+%Y-%m-%d %H:%M')]"
    git push origin main
    echo "[✓] Git changes pushed to remote!"
else
    echo "[✓] Git working tree already up-to-date."
fi

echo ""
echo "🎉 Master backup successfully completed!"
echo "• Cloud (GitHub): Configs, Plasmoids, Themes, Pinned Apps, Packages, and NoiseTorch Guard."
echo "• Offline (Secondary SSD /mnt/Storage): Full Game Saves, Documents, Notes & Icon Packs."
