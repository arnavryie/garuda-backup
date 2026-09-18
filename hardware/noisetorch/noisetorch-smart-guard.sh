#!/usr/bin/env bash
# ==============================================================================
# NoiseTorch Smart Battery & Hardware Power Guard
# - Only activates NoiseTorch when Fifine Mic is plugged in AND on AC Power.
# - When on Battery OR when Fifine Mic is unplugged, NoiseTorch is completely
#   unloaded (0% CPU, 0 RAM, ZERO battery drain).
# ==============================================================================

FIFINE_ID="3142:5060"
FIFINE_SOURCE="alsa_input.usb-3142_Fifine_Microphone-00.mono-fallback"
THRESHOLD=95

is_ac_connected() {
    # Check if AC adapter is plugged in
    if [ -f /sys/class/power_supply/ACAD/online ]; then
        [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" = "1" ] && return 0
    fi
    for ac in /sys/class/power_supply/*/online; do
        if [ -f "$ac" ] && [ "$(cat "$ac" 2>/dev/null)" = "1" ]; then
            type=$(cat "$(dirname "$ac")/type" 2>/dev/null || true)
            if [ "$type" = "Mains" ]; then
                return 0
            fi
        fi
    done
    return 1
}

is_fifine_connected() {
    lsusb -d "$FIFINE_ID" >/dev/null 2>&1
}

is_noisetorch_active() {
    pactl list short sources 2>/dev/null | grep -q "NoiseTorch Microphone"
}

if is_ac_connected && is_fifine_connected; then
    # Both AC and Fifine connected -> Ensure NoiseTorch is active
    if ! is_noisetorch_active; then
        # Wait up to 5 seconds if Fifine is still registering in PipeWire
        for i in {1..10}; do
            if pactl list short sources 2>/dev/null | grep -q "Fifine_Microphone"; then
                break
            fi
            sleep 0.5
        done

        /home/ryie/.local/bin/noisetorch -i -s "$FIFINE_SOURCE" -t "$THRESHOLD" >/dev/null 2>&1 || true
        sleep 0.5
        pactl set-default-source "NoiseTorch Microphone for Fifine Microphone" 2>/dev/null || true
    fi
else
    # On Battery OR Fifine mic disconnected -> Completely unload NoiseTorch for zero battery drain
    while is_noisetorch_active; do
        /home/ryie/.local/bin/noisetorch -u >/dev/null 2>&1 || break
        sleep 0.3
    done
fi
