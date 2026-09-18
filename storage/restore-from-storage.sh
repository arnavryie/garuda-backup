#!/usr/bin/env bash
# ==============================================================================
# 🔄 Restore Game Saves, Documents & Icons from Secondary SSD
# Author: arnavryie
# ==============================================================================

set -e

BACKUP_DEST="/mnt/Storage/Garuda-Full-Backup"

if [ ! -d "$BACKUP_DEST" ]; then
    echo "Error: Backup directory $BACKUP_DEST not found on /mnt/Storage."
    echo "Make sure the secondary SSD is mounted."
    exit 1
fi

if [ -f "$BACKUP_DEST/restore-offline.sh" ]; then
    bash "$BACKUP_DEST/restore-offline.sh"
else
    echo "Error: $BACKUP_DEST/restore-offline.sh not found."
    exit 1
fi
