#!/usr/bin/env bash
# Injects System SSD and Storage SSD bookmarks into Dolphin's Places
set -e

DEST="$HOME/.local/share/user-places.xbel"
mkdir -p "$HOME/.local/share"

# If user-places.xbel doesn't exist, copy our complete template
if [ ! -f "$DEST" ]; then
    cp "$(dirname "${BASH_SOURCE[0]}")/user-places.xbel" "$DEST"
else
    # Ensure Storage and System bookmarks are present
    if ! grep -q "Storage SSD" "$DEST"; then
        sed -i '/<\/xbel>/i \
 <bookmark href="file:///">\
  <title>System SSD (Crucial 500GB)</title>\
  <info>\
   <metadata owner="http://freedesktop.org">\
    <bookmark:icon name="drive-harddisk-root"/>\
   </metadata>\
   <metadata owner="http://www.kde.org">\
    <ID>1787746943/11</ID>\
    <isSystemItem>false</isSystemItem>\
   </metadata>\
  </info>\
 </bookmark>\
 <bookmark href="file:///mnt/Storage">\
  <title>Storage SSD (Micron 512GB)</title>\
  <info>\
   <metadata owner="http://freedesktop.org">\
    <bookmark:icon name="drive-harddisk-solidstate"/>\
   </metadata>\
   <metadata owner="http://www.kde.org">\
    <ID>1787746943/12</ID>\
    <isSystemItem>false</isSystemItem>\
   </metadata>\
  </info>\
 </bookmark>' "$DEST"
    fi
fi

# Refresh Dolphin
killall dolphin 2>/dev/null || true
echo "==> Dolphin sidebar updated with SSD shortcuts!"
