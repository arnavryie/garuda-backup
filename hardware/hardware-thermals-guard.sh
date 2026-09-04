#!/usr/bin/env bash
# ==============================================================================
# Lenovo LOQ 15IRX9 - Intelligent Dynamic Power & Thermal Management Guardian
#
# Enforces:
# 1. 🔵 LOW-POWER MODE ON BATTERY:
#    - NVIDIA dGPU powered OFF in D3cold (0.0W). Intel iGPU 100% active.
#    - CPU tuned for silky smooth responsiveness + maximum battery life:
#      - No turbo voltage spikes (intel_pstate/no_turbo = 1)
#      - Governor: powersave, EPP: balance_power
#      - RAPL PL1 = 20W, PL2 = 30W
#      - WiFi power save enabled
#    - Zero lag for browsing, IDE, coding, 4K video playback.
#
# 2. 🔵 LOW-POWER MODE ON CHARGER (AC):
#    - NVIDIA dGPU enabled in hybrid mode.
#    - CPU: Turbo enabled, EPP: balance_performance, RAPL PL1 = 45W, PL2 = 65W.
#    - Thermal caps active if dGPU used.
#
# 3. ⚪ BALANCED MODE (Fn + Q White LED):
#    - NVIDIA dGPU fully enabled.
#    - CPU: EPP balance_performance, RAPL PL1 = 65W (AC) / 45W (Bat), PL2 = 85W (AC) / 65W (Bat).
#    - Real-time GPU <= 77°C and CPU <= 87°C dynamic thermal regulation.
#
# 4. 🔴 PERFORMANCE MODE (Fn + Q Red LED):
#    - NVIDIA dGPU maximum performance with dynamic boost.
#    - CPU: EPP performance, RAPL PL1 = 95W, PL2 = 135W, HWP dynamic boost.
#    - Real-time GPU <= 77°C and CPU <= 87°C dynamic thermal regulation.
#
# 5. ALL MODES:
#    - Real-time CPU TjMax <= 87°C hard cap (Intel TCC Offset 13).
# ==============================================================================

PREV_STATE=""
WIFI_DEV=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -n 1)

# Helper function to configure CPU Power Limits & Energy Preference
apply_cpu_tuning() {
    local no_turbo="$1"
    local epp="$2"
    local hwp_boost="$3"
    local pl1_uw="$4"
    local pl2_uw="$5"

    # Turbo boost toggle
    if [ -w /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo "$no_turbo" > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    fi

    # HWP Dynamic Boost
    if [ -w /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost ]; then
        echo "$hwp_boost" > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost 2>/dev/null || true
    fi

    # Scaling Governor & EPP across all cores
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "powersave" > "$gov" 2>/dev/null || true
    done
    for epp_file in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo "$epp" > "$epp_file" 2>/dev/null || true
    done

    # Intel RAPL Power Limits (PL1 / PL2)
    if [ -w /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw ]; then
        echo "$pl1_uw" > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null || true
    fi
    if [ -w /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw ]; then
        echo "$pl2_uw" > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null || true
    fi
}

# Main dynamic regulation loop
while true; do
    # --------------------------------------------------------------------------
    # 1. Enforce CPU TjMax 87°C Hard Ceiling (Always Active)
    # --------------------------------------------------------------------------
    for tcc in /sys/class/thermal/cooling_device*; do
        if [ -f "$tcc/type" ] && [ "$(cat "$tcc/type" 2>/dev/null)" = "TCC Offset" ]; then
            CUR_TCC=$(cat "$tcc/cur_state" 2>/dev/null || echo "0")
            if [ "$CUR_TCC" != "13" ]; then
                echo 13 > "$tcc/cur_state" 2>/dev/null || true
            fi
        fi
    done
    if [ -w /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius ]; then
        CUR_TCC=$(cat /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || echo "0")
        if [ "$CUR_TCC" != "13" ]; then
            echo 13 > /sys/devices/pci0000:00/0000:00:04.0/tcc_offset_degree_celsius 2>/dev/null || true
        fi
    fi

    # --------------------------------------------------------------------------
    # 2. Read Current Power Source & Platform Profile
    # --------------------------------------------------------------------------
    AC_ONLINE=0
    for ac in /sys/class/power_supply/AC*/online /sys/class/power_supply/ACAD/online /sys/class/power_supply/ADP*/online; do
        if [ -f "$ac" ] && [ "$(cat "$ac" 2>/dev/null)" = "1" ]; then
            AC_ONLINE=1
            break
        fi
    done

    PROFILE="balanced"
    if [ -f /sys/firmware/acpi/platform_profile ]; then
        PROFILE=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo "balanced")
    fi

    # Determine State
    if [ "$PROFILE" = "low-power" ]; then
        if [ "$AC_ONLINE" -eq 0 ]; then
            CURRENT_STATE="BATTERY_LOW_POWER"
        else
            CURRENT_STATE="AC_LOW_POWER"
        fi
    elif [ "$PROFILE" = "performance" ]; then
        CURRENT_STATE="PERFORMANCE"
    else
        if [ "$AC_ONLINE" -eq 0 ]; then
            CURRENT_STATE="BATTERY_BALANCED"
        else
            CURRENT_STATE="AC_BALANCED"
        fi
    fi

    # --------------------------------------------------------------------------
    # 3. Handle State Transitions
    # --------------------------------------------------------------------------
    if [ "$CURRENT_STATE" != "$PREV_STATE" ]; then
        case "$CURRENT_STATE" in
            "BATTERY_LOW_POWER")
                # Power down NVIDIA GPU to D3cold (0.0W)
                nvidia-smi -pm 0 >/dev/null 2>&1 || true
                nvidia-smi -rgc >/dev/null 2>&1 || true
                echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null || true
                echo auto > /sys/bus/pci/devices/0000:01:00.1/power/control 2>/dev/null || true
                echo auto > /sys/bus/pci/devices/0000:00:01.0/power/control 2>/dev/null || true

                # CPU: Smooth 14-core base scaling, no turbo spikes, 20W PL1, 30W PL2
                apply_cpu_tuning 1 "balance_power" 0 20000000 30000000

                # WiFi power save
                [ -n "$WIFI_DEV" ] && iw dev "$WIFI_DEV" set power_save on 2>/dev/null || true
                ;;

            "AC_LOW_POWER")
                # Hybrid GPU on AC
                echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null || true
                echo auto > /sys/bus/pci/devices/0000:01:00.1/power/control 2>/dev/null || true
                nvidia-smi -rgc >/dev/null 2>&1 || true

                # CPU: Turbo enabled for snappy responsiveness on charger
                apply_cpu_tuning 0 "balance_performance" 0 45000000 65000000

                [ -n "$WIFI_DEV" ] && iw dev "$WIFI_DEV" set power_save off 2>/dev/null || true
                ;;

            "BATTERY_BALANCED")
                # Balanced mode on battery
                nvidia-smi -pm 0 >/dev/null 2>&1 || true
                echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null || true
                echo auto > /sys/bus/pci/devices/0000:01:00.1/power/control 2>/dev/null || true
                nvidia-smi -rgc >/dev/null 2>&1 || true

                apply_cpu_tuning 0 "balance_performance" 0 45000000 65000000
                [ -n "$WIFI_DEV" ] && iw dev "$WIFI_DEV" set power_save off 2>/dev/null || true
                ;;

            "AC_BALANCED")
                # Full Balanced Mode on AC
                nvidia-smi -pm 1 >/dev/null 2>&1 || true
                echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null || true
                echo auto > /sys/bus/pci/devices/0000:01:00.1/power/control 2>/dev/null || true
                nvidia-smi -lgc 210,2040 >/dev/null 2>&1 || true

                apply_cpu_tuning 0 "balance_performance" 1 65000000 85000000
                [ -n "$WIFI_DEV" ] && iw dev "$WIFI_DEV" set power_save off 2>/dev/null || true
                ;;

            "PERFORMANCE")
                # Maximum Performance Mode
                nvidia-smi -pm 1 >/dev/null 2>&1 || true
                echo on > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null || true
                nvidia-smi -lgc 210,2040 >/dev/null 2>&1 || true

                apply_cpu_tuning 0 "performance" 1 95000000 135000000
                [ -n "$WIFI_DEV" ] && iw dev "$WIFI_DEV" set power_save off 2>/dev/null || true
                ;;
        esac

        PREV_STATE="$CURRENT_STATE"
    fi

    # --------------------------------------------------------------------------
    # 4. Dynamic GPU Thermal Regulation (<= 77°C Target)
    # --------------------------------------------------------------------------
    # Only poll GPU when NOT in BATTERY_LOW_POWER (to keep dGPU asleep in D3cold)
    if [ "$CURRENT_STATE" != "BATTERY_LOW_POWER" ]; then
        GPU_STATUS=$(cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status 2>/dev/null || echo "active")
        if [ "$GPU_STATUS" = "active" ]; then
            GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
            if [[ "$GPU_TEMP" =~ ^[0-9]+$ ]] && [ "$GPU_TEMP" -gt 0 ]; then
                if [ "$GPU_TEMP" -ge 78 ]; then
                    # Heavy 100% load: trim to 1770 MHz
                    nvidia-smi -lgc 210,1770 >/dev/null 2>&1 || true
                elif [ "$GPU_TEMP" -ge 76 ]; then
                    # Near target: trim to 1860 MHz
                    nvidia-smi -lgc 210,1860 >/dev/null 2>&1 || true
                elif [ "$GPU_TEMP" -le 72 ]; then
                    # Safe headroom: allow up to 2040 MHz boost
                    nvidia-smi -lgc 210,2040 >/dev/null 2>&1 || true
                fi
            fi
        fi
    fi

    sleep 1
done
