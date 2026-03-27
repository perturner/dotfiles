#!/bin/bash

# Configuration
LAYOUT="$HOME/.config/wlogout/layout"
STYLE="$HOME/.config/wlogout/style.css"

# Check if jq is available
if ! command -v jq &> /dev/null;
    then
    exit 1
fi

# Get the focused monitor info
MONITOR_INFO=$(hyprctl monitors -j)
FOCUSED_MONITOR=$(echo "$MONITOR_INFO" | jq -r '.[] | select(.focused == true)')

WIDTH=$(echo "$FOCUSED_MONITOR" | jq -r '.width')
HEIGHT=$(echo "$FOCUSED_MONITOR" | jq -r '.height')

# Fallback defaults if detection fails
if [ -z "$WIDTH" ] || [ "$WIDTH" == "null" ]; then
    WIDTH=2560
    HEIGHT=1440
fi

# Define target window size (approximate)
TARGET_WIDTH=800
TARGET_HEIGHT=500

# Calculate margins
MARGIN_LEFT=$(( (WIDTH - TARGET_WIDTH) / 2 ))
MARGIN_RIGHT=$(( (WIDTH - TARGET_WIDTH) / 2 ))
MARGIN_TOP=$(( (HEIGHT - TARGET_HEIGHT) / 2 ))
MARGIN_BOTTOM=$(( (HEIGHT - TARGET_HEIGHT) / 2 ))

# Ensure positive margins
[ "$MARGIN_LEFT" -lt 0 ] && MARGIN_LEFT=0
[ "$MARGIN_RIGHT" -lt 0 ] && MARGIN_RIGHT=0
[ "$MARGIN_TOP" -lt 0 ] && MARGIN_TOP=0
[ "$MARGIN_BOTTOM" -lt 0 ] && MARGIN_BOTTOM=0

# Execute wlogout with calculated margins
wlogout \
    --layout "$LAYOUT" \
    --css "$STYLE" \
    --margin-left "$MARGIN_LEFT" \
    --margin-right "$MARGIN_RIGHT" \
    --margin-top "$MARGIN_TOP" \
    --margin-bottom "$MARGIN_BOTTOM" \
    --protocol layer-shell
