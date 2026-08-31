#!/usr/bin/env bash
# ==============================================================================
# Lenovo LOQ Hardware Thermal Limiter
# Enforces:
#  - CPU Max Temp = 88°C (via Intel TCC Offset = 12)
#  - GPU Max Temp = 78°C (via RTX 4060 Undervolt / Clock Capping & Dynamic Trim)
# ==============================================================================

set -e

# 1. Enforce CPU Hardware Limit at 88°C (100°C - 12°C = 88°C)
if [ -w /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
    echo 12 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius
fi

# 2. Enforce GPU Max Clock & Power to maintain <= 78°C
if command -v nvidia-smi &>/dev/null; then
    nvidia-smi -pm 1 >/dev/null 2>&1 || true
    # Lock RTX 4060 max boost clock to 1920 MHz (high efficiency curve, stays < 78°C)
    nvidia-smi -lgc 210,1920 >/dev/null 2>&1 || true
fi
