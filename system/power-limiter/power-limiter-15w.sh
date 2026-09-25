#!/usr/bin/env bash
# ==============================================================================
# Hard 15W - 20W Power Limiter (Intel RAPL & DVFS Silicon Enforcement)
# - Sustained PL1 (Package Limit): 15 Watts (15,000,000 uW)
# - Burst PL2 (Peak Limit):       20 Watts (20,000,000 uW)
# - Energy Performance Preference: balance_power (dynamic bursting without lag)
# ==============================================================================

RAPL_DIR="/sys/class/powercap/intel-rapl/intel-rapl:0"

if [ -d "$RAPL_DIR" ]; then
    # Enable RAPL constraint
    [ -f "$RAPL_DIR/enabled" ] && echo 1 > "$RAPL_DIR/enabled" 2>/dev/null || true

    # PL1 (Sustained limit) = 15 Watts
    if [ -f "$RAPL_DIR/constraint_0_power_limit_uw" ]; then
        echo 15000000 > "$RAPL_DIR/constraint_0_power_limit_uw" 2>/dev/null || true
    fi

    # PL2 (Short-term peak burst limit) = 20 Watts max
    if [ -f "$RAPL_DIR/constraint_1_power_limit_uw" ]; then
        echo 20000000 > "$RAPL_DIR/constraint_1_power_limit_uw" 2>/dev/null || true
    fi
fi

# Set EPP to balance_power so CPU doesn't choke or freeze at 800MHz
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    if [ -f "$epp" ]; then
        echo balance_power > "$epp" 2>/dev/null || true
    fi
done

exit 0
