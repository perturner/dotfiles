#!/usr/bin/env bash

# Match the G9 57" specifically
MONITOR_NAME="DP-4"

# Get info for this specific monitor
WIDTH=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR_NAME\") | .width")

# Debug log (optional, you can see this in your notification)
# notify-send "Debug" "Current Width: $WIDTH"

if [ "$WIDTH" -eq 7680 ]; then
    # Switch to PiP Mode (1440p 16:9)
    # Using @auto to ensure the handshake succeeds
    hyprctl keyword monitor "$MONITOR_NAME, 2560x1440@auto, 0x0, 1, bitdepth, 10"
    notify-send "Hyprland" "PiP Mode Enabled (1440p 16:9)"
else
    # Switch back to Native 8K
    hyprctl keyword monitor "$MONITOR_NAME, 7680x2160@auto, 0x0, 1, bitdepth, 10"
    notify-send "Hyprland" "Native Mode Enabled (8K 32:9)"
fi
