#!/usr/bin/env bash
# ==============================================================================
# Lenovo LOQ Thermal & Power Daemon
# - Keeps CPU capped at 88°C max (Intel TCC offset = 12)
# - Keeps GPU capped at 78°C max (Dynamic clock management)
# - Runs across all power modes (Quiet, Balanced, Performance)
# ==============================================================================

set -e

apply_limits() {
    # 1. CPU hardware max temperature = 88°C
    if [ -w /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
        echo 12 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || true
    fi

    # 2. CPU Governor optimization
    for g in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo balance_performance > "$g" 2>/dev/null || true
    done

    # 3. GPU Persistence & baseline clock cap
    nvidia-smi -pm 1 >/dev/null 2>&1 || true
    nvidia-smi -lgc 210,1920 >/dev/null 2>&1 || true
}

# Initial apply on startup
apply_limits

# Monitor loop (every 5 seconds) to enforce limits and dynamically trim if GPU reaches 78°C
while true; do
    # Ensure CPU TCC offset remains at 12
    if [ -f /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
        CURRENT_TCC=$(cat /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || echo "0")
        if [ "$CURRENT_TCC" -ne 12 ]; then
            echo 12 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || true
        fi
    fi

    # Check GPU temperature
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
    if [[ "$GPU_TEMP" =~ ^[0-9]+$ ]]; then
        if [ "$GPU_TEMP" -ge 78 ]; then
            # Trim top boost clock to quickly cool under 78°C
            nvidia-smi -lgc 210,1770 >/dev/null 2>&1 || true
        elif [ "$GPU_TEMP" -le 74 ]; then
            # Restore optimal boost clock
            nvidia-smi -lgc 210,1920 >/dev/null 2>&1 || true
        fi
    fi

    sleep 5
done
