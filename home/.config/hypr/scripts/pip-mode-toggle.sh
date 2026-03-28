#!/usr/bin/env bash

# Define the monitor description
MONITOR="desc:Samsung Electric Company Odyssey G95NC HNTX800635"

# Get current resolution from hyprctl (Corrected jq)
CURRENT_RES=$(hyprctl monitors -j | jq -r '.[] | select(.description | contains("G95NC")) | "\(.width)x\(.height)"')

if [[ "$CURRENT_RES" == "7680x2160" ]]; then
    # Switch to PiP Optimized resolution (2.5K equivalent)
    # Adding cm, auto to match the config
    hyprctl keyword monitor "$MONITOR, 2560x1440@240, 0x0, 1, bitdepth, 10, cm, auto, vrr, 0"
    notify-send "Hyprland" "PiP Mode Enabled (2560x1440)"
else
    # Switch back to Native 8K
    hyprctl keyword monitor "$MONITOR, 7680x2160@240, 0x0, 1, bitdepth, 10, cm, auto, vrr, 0"
    notify-send "Hyprland" "Native Mode Enabled (7680x2160)"
fi
