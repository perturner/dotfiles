#!/usr/bin/env bash

# Get monitor info in JSON
MONITORS=$(hyprctl monitors -j)

# Extract the refresh rate of the focused monitor
# We use jq to find the element where "focused" is true
REFRESH=$(echo "$MONITORS" | jq -r '.[] | select(.focused == true) | .refreshRate')

# Round to nearest integer
if [ -z "$REFRESH" ] || [ "$REFRESH" == "null" ]; then
    REFRESH_INT="0"
    REFRESH="0"
else
    REFRESH_INT=$(printf "%.0f" "$REFRESH")
fi

# Output JSON for Waybar
echo "{\"text\": \"${REFRESH_INT}Hz\", \"tooltip\": \"Refresh Rate: ${REFRESH}Hz\", \"class\": \"refresh\"}"