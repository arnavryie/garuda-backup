#!/usr/bin/env bash
# ==============================================================================
# Real-Time Dynamic Hardware Thermal Guardian
# Enforces:
# - CPU <= 87°C (Intel TCC Offset 13)
# - GPU <= 77°C (Dynamic Clock Regulation based on real-time game load)
# ==============================================================================

# Enable persistence mode
nvidia-smi -pm 1 >/dev/null 2>&1 || true

while true; do
    # 1. Enforce CPU 87°C ceiling
    if [ -w /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
        CUR_TCC=$(cat /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || echo "0")
        if [ "$CUR_TCC" != "13" ]; then
            echo 13 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || true
        fi
    fi

    # 2. Enforce GPU 77°C target dynamically
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
    if [[ "$GPU_TEMP" =~ ^[0-9]+$ ]]; then
        if [ "$GPU_TEMP" -ge 78 ]; then
            # Under extreme 100% GPU load (e.g. Resident Evil Requiem), drop to 1770 MHz
            nvidia-smi -lgc 210,1770 >/dev/null 2>&1 || true
        elif [ "$GPU_TEMP" -ge 76 ]; then
            nvidia-smi -lgc 210,1860 >/dev/null 2>&1 || true
        elif [ "$GPU_TEMP" -le 72 ]; then
            # Under light/moderate load, allow boost up to 2040 MHz
            nvidia-smi -lgc 210,2040 >/dev/null 2>&1 || true
        fi
    fi

    sleep 1
done
