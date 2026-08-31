#!/usr/bin/env bash
# ==============================================================================
# Lenovo LOQ Dynamic Profile & Hardware Thermal Manager
# ------------------------------------------------------------------------------
# 🔵 BLUE (low-power):
#   - On Battery: iGPU only (dGPU suspended), Stock Lenovo Quiet limits, No temp cap
#   - On Charger: Hybrid mode, Stock Lenovo Quiet limits, No temp cap
#
# ⚪ WHITE (balanced / Gaming Mode):
#   - CPU: PL1=55W, PL2=80W, Max Temp = 87°C (TCC Offset = 13)
#   - GPU: TGP=~90W, Max Temp = 78°C (Clock Cap 1920MHz + Dynamic Trim)
#   - GPU Mode: Hybrid
#
# 🔴 RED (performance):
#   - 100% Stock Lenovo Performance Mode (No temp caps, No power caps, Max 115W TGP)
# ==============================================================================

set -e

LAST_MODE=""
LAST_AC=""

apply_profile() {
    local mode="$1"
    local ac="$2"

    echo "[ProfileManager] Applying mode: $mode (AC: $ac)"

    case "$mode" in
        low-power)
            # 🔵 BLUE MODE (Quiet / Low Power)
            # 1. Reset CPU Temperature cap to stock default
            if [ -w /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
                echo 3 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || true
            fi

            if [ "$ac" -eq 1 ]; then
                # On Charger: Turbo enabled, smooth EPP, stock quiet limits
                echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
                if [ -w /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw ]; then
                    echo 35000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null || true
                fi
                if [ -w /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw ]; then
                    echo 45000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null || true
                fi
                nvidia-smi -pm 1 >/dev/null 2>&1 || true
                nvidia-smi -rgc >/dev/null 2>&1 || true
                for g in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
                    echo balance_performance > "$g" 2>/dev/null || true
                done
            else
                # On Battery: Ultra-Cool ~45°C Cap (Disable Turbo + 15W PL1 + Min GPU Clock + EPP power)
                echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
                if [ -w /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw ]; then
                    echo 15000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null || true
                fi
                if [ -w /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw ]; then
                    echo 20000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null || true
                fi
                # Cap GPU clock if woken up so it cannot exceed 45°C
                nvidia-smi -lgc 210,1050 >/dev/null 2>&1 || true
                for g in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
                    echo power > "$g" 2>/dev/null || true
                done
            fi
            ;;

        balanced)
            # ⚪ WHITE MODE (Custom Gaming Mode: 55W/80W CPU @ 87°C | 90W GPU @ 78°C)
            echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true

            # 1. Enforce CPU Temperature Limit = 87°C (100°C - 13°C = 87°C)
            if [ -w /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
                echo 13 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || true
            fi

            # 2. Enforce CPU Power Limits: PL1 = 55W (55M uW), PL2 = 80W (80M uW)
            if [ -w /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw ]; then
                echo 55000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null || true
            fi
            if [ -w /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw ]; then
                echo 80000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null || true
            fi

            # 3. CPU Governor
            for g in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
                echo balance_performance > "$g" 2>/dev/null || true
            done

            # 4. GPU Tuning: Lock to ~90W high-efficiency boost curve (1920 MHz) & ensure <= 78°C
            nvidia-smi -pm 1 >/dev/null 2>&1 || true
            nvidia-smi -lgc 210,1920 >/dev/null 2>&1 || true
            ;;

        performance)
            # 🔴 RED MODE (100% Stock Lenovo Factory Performance)
            echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true

            # 1. Remove CPU Temperature cap (TCC offset = 0 -> full 100°C)
            if [ -w /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
                echo 0 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || true
            fi

            # 2. Reset CPU Power limits to stock Lenovo Performance limits (PL1=65W, PL2=80W+)
            if [ -w /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw ]; then
                echo 65000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null || true
            fi
            if [ -w /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw ]; then
                echo 80000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null || true
            fi

            # 3. CPU Governor -> Full Performance
            for g in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
                echo performance > "$g" 2>/dev/null || true
            done

            # 4. Remove all GPU clock caps -> Full 115W TGP stock boost!
            nvidia-smi -pm 1 >/dev/null 2>&1 || true
            nvidia-smi -rgc >/dev/null 2>&1 || true

            # 5. Keep fans limited to Quiet Mode levels (whisper quiet)
            if [ -f /usr/share/legion_linux/quiet-ac.yaml ]; then
                legion_cli --donotexpecthwmon fancurve-write-file-to-hw /usr/share/legion_linux/quiet-ac.yaml >/dev/null 2>&1 || true
            fi
            ;;

        custom)
            # 🟣 PURPLE MODE (Untouched - user managed)
            echo "[ProfileManager] Custom mode active - leaving controls untouched."
            ;;
    esac
}

# Main event loop (checks every 2 seconds)
while true; do
    # Get current ACPI mode (low-power, balanced, performance, custom)
    CURRENT_MODE=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo "balanced")
    
    # Get AC power status (1 = plugged in, 0 = battery)
    CURRENT_AC=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || cat /sys/class/power_supply/AC*/online 2>/dev/null || echo "1")

    # If mode or power source changed, apply profile settings
    if [ "$CURRENT_MODE" != "$LAST_MODE" ] || [ "$CURRENT_AC" != "$LAST_AC" ]; then
        apply_profile "$CURRENT_MODE" "$CURRENT_AC"
        LAST_MODE="$CURRENT_MODE"
        LAST_AC="$CURRENT_AC"
    fi

    # In Balanced / Gaming mode only: actively guard the 78°C GPU limit
    if [ "$CURRENT_MODE" = "balanced" ]; then
        GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
        if [[ "$GPU_TEMP" =~ ^[0-9]+$ ]]; then
            if [ "$GPU_TEMP" -ge 78 ]; then
                nvidia-smi -lgc 210,1770 >/dev/null 2>&1 || true
            elif [ "$GPU_TEMP" -le 74 ]; then
                nvidia-smi -lgc 210,1920 >/dev/null 2>&1 || true
            fi
        fi
    fi

    sleep 2
done
