#!/usr/bin/env bash
# Configure Secondary Storage SSD
set -e

if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run with sudo."
    exit 1
fi

DISK="/dev/nvme0n1"
PART1="/dev/nvme0n1p1"
PART2="/dev/nvme0n1p2"
MOUNT_POINT="/mnt/Storage"
USER_NAME="${SUDO_USER:-ryie}"

echo "==> Configuring Secondary Storage SSD ($DISK)..."

# 1. Unmount if currently mounted
umount "$PART1" 2>/dev/null || true

# 2. Remove orphaned swap partition if present
if [ -b "$PART2" ]; then
    echo "==> Removing leftover swap partition ($PART2)..."
    swapoff "$PART2" 2>/dev/null || true
    wipefs -a "$PART2" 2>/dev/null || true
    parted -s "$DISK" rm 2
    sleep 1
    partprobe "$DISK" || true
fi

# 3. Expand partition & ext4 filesystem to 100%
if [ -b "$PART1" ]; then
    echo "==> Expanding $PART1 to full capacity..."
    parted -s "$DISK" resizepart 1 100% 2>/dev/null || true
    sleep 1
    partprobe "$DISK" || true
    e2fsck -f -p "$PART1" || true
    resize2fs "$PART1" || true
fi

# 4. Permanent mount point & fstab
mkdir -p "$MOUNT_POINT"
UUID=$(blkid -s UUID -o value "$PART1" || true)

if [ -n "$UUID" ]; then
    if ! grep -q "$UUID" /etc/fstab; then
        echo "UUID=$UUID $MOUNT_POINT ext4 defaults,noatime 0 2" >> /etc/fstab
        echo "==> Added $MOUNT_POINT to /etc/fstab"
    fi
fi

mount -a 2>/dev/null || true
chown -R "$USER_NAME:$USER_NAME" "$MOUNT_POINT"
chmod 775 "$MOUNT_POINT"

# 5. Create user convenience shortcuts
ln -sfn "$MOUNT_POINT" "/home/$USER_NAME/Storage"
chown -h "$USER_NAME:$USER_NAME" "/home/$USER_NAME/Storage"

mkdir -p "/run/media/$USER_NAME"
ln -sfn "$MOUNT_POINT" "/run/media/$USER_NAME/Storage" 2>/dev/null || true

echo "==> Secondary SSD setup complete! Mounted at $MOUNT_POINT"
