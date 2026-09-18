#!/usr/bin/env bash
# ==============================================================================
# 💽 Fast Snapshot Backup to Secondary SSD (/mnt/Storage)
# Preserves Game Saves, Documents, Heavy Icon Packs & Desktop Configs
# Author: arnavryie
# ==============================================================================

set -e

BACKUP_DEST="/mnt/Storage/Garuda-Full-Backup"

if [ ! -d "/mnt/Storage" ]; then
    echo "Error: /mnt/Storage is not mounted or accessible."
    exit 1
fi

mkdir -p "$BACKUP_DEST/game-saves/documents-saves"
mkdir -p "$BACKUP_DEST/game-saves/steam-userdata"
mkdir -p "$BACKUP_DEST/game-saves/wine-appdata/Roaming"
mkdir -p "$BACKUP_DEST/game-saves/wine-appdata/Local"
mkdir -p "$BACKUP_DEST/documents"
mkdir -p "$BACKUP_DEST/icons"
mkdir -p "$BACKUP_DEST/desktop"

echo "=== [1/6] Backing up Game Saves from ~/Documents ==="
for game in "Assassin's Creed Black Flag Resynced" "Assassin's Creed Shadows" "Ghost of Tsushima DIRECTOR'S CUT" "Marvel's Spider-Man Remastered"; do
    if [ -d "$HOME/Documents/$game" ]; then
        echo "Syncing $game save..."
        rsync -a --delete "$HOME/Documents/$game/" "$BACKUP_DEST/game-saves/documents-saves/$game/"
    fi
done

echo "=== [2/6] Backing up Steam Userdata Saves ==="
if [ -d "$HOME/.local/share/Steam/userdata" ]; then
    rsync -a --delete "$HOME/.local/share/Steam/userdata/" "$BACKUP_DEST/game-saves/steam-userdata/"
fi

echo "=== [3/6] Backing up Wine AppData Game Saves ==="
WINE_ROAMING="$HOME/.wine/drive_c/users/ryie/AppData/Roaming"
WINE_LOCAL="$HOME/.wine/drive_c/users/ryie/AppData/Local"

for folder in "Goldberg UplayEmu Saves" "GSE Saves" "Insomniac Games" "IO Interactive" "Sucker Punch Productions" "Ubisoft"; do
    if [ -d "$WINE_ROAMING/$folder" ]; then
        echo "Syncing Wine Roaming: $folder..."
        rsync -a --delete "$WINE_ROAMING/$folder/" "$BACKUP_DEST/game-saves/wine-appdata/Roaming/$folder/"
    fi
done

for folder in "Project_Plague" "Ubisoft"; do
    if [ -d "$WINE_LOCAL/$folder" ]; then
        echo "Syncing Wine Local: $folder..."
        rsync -a --delete "$WINE_LOCAL/$folder/" "$BACKUP_DEST/game-saves/wine-appdata/Local/$folder/"
    fi
done

echo "=== [4/6] Backing up Personal Documents, Books & Obsidian Vault ==="
for doc in "Obsidian" "Reading_Books_Collection" "Simple_English_Editions" "ED" "JAVA" "JOB"; do
    if [ -d "$HOME/Documents/$doc" ]; then
        echo "Syncing $doc..."
        rsync -a --delete "$HOME/Documents/$doc/" "$BACKUP_DEST/documents/$doc/"
    fi
done

# Copy standalone book files & notes
cp -p "$HOME/Documents/"The\ Dhammapada* "$BACKUP_DEST/documents/" 2>/dev/null || true
[ -f "$HOME/Documents/ryie_context.md" ] && cp -p "$HOME/Documents/ryie_context.md" "$BACKUP_DEST/documents/" 2>/dev/null || true

echo "=== [5/6] Backing up Complete Icon Themes (candy-icons, Colloid, Tela, etc.) ==="
if [ -d "$HOME/.local/share/icons" ]; then
    echo "Syncing icon themes to secondary SSD..."
    rsync -a --delete "$HOME/.local/share/icons/" "$BACKUP_DEST/icons/"
fi

echo "=== [6/6] Backing up Desktop Launchers ==="
rsync -a --delete "$HOME/Desktop/" "$BACKUP_DEST/desktop/"

# Create Offline Restore Script on the Backup Drive itself
cat << "RESTORE_EOF" > "$BACKUP_DEST/restore-offline.sh"
#!/usr/bin/env bash
# ==============================================================================
# 🚀 Offline 1-Click Restore from Secondary SSD (/mnt/Storage)
# ==============================================================================
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Restoring Game Saves ==="
mkdir -p "$HOME/Documents"
rsync -a "$DIR/game-saves/documents-saves/" "$HOME/Documents/"

if [ -d "$DIR/game-saves/steam-userdata" ]; then
    mkdir -p "$HOME/.local/share/Steam/userdata"
    rsync -a "$DIR/game-saves/steam-userdata/" "$HOME/.local/share/Steam/userdata/"
fi

mkdir -p "$HOME/.wine/drive_c/users/$(whoami)/AppData/Roaming"
mkdir -p "$HOME/.wine/drive_c/users/$(whoami)/AppData/Local"
rsync -a "$DIR/game-saves/wine-appdata/Roaming/" "$HOME/.wine/drive_c/users/$(whoami)/AppData/Roaming/"
rsync -a "$DIR/game-saves/wine-appdata/Local/" "$HOME/.wine/drive_c/users/$(whoami)/AppData/Local/"

echo "=== Restoring Documents, Books & Notes ==="
rsync -a "$DIR/documents/" "$HOME/Documents/"

echo "=== Restoring Icon Packs ==="
mkdir -p "$HOME/.local/share/icons"
rsync -a "$DIR/icons/" "$HOME/.local/share/icons/"

echo "=== Restoring Desktop Items ==="
mkdir -p "$HOME/Desktop"
rsync -a "$DIR/desktop/" "$HOME/Desktop/"

echo "[✓] Offline snapshot successfully restored to home directory!"
RESTORE_EOF
chmod +x "$BACKUP_DEST/restore-offline.sh"

echo ""
echo "[✓] Full secondary SSD snapshot complete at: $BACKUP_DEST"
echo "[✓] Offline 1-click restore script created at: $BACKUP_DEST/restore-offline.sh"
