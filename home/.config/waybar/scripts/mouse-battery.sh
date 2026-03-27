#!/bin/bash

BAT_PATH="/sys/class/power_supply/hidpp_battery_0"

if [ -d "$BAT_PATH" ]; then
    CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null)
    STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)
    
    if [ -n "$CAPACITY" ]; then
        # Determine CSS class based on status/level if needed, but simple text is fine
        # Output JSON
        # text: what is shown in the bar
        # tooltip: hover text
        echo "{\"text\": \"$CAPACITY%\", \"tooltip\": \"Mouse Battery: $CAPACITY% ($STATUS)\", \"class\": \"$STATUS\", \"percentage\": $CAPACITY}"
        exit 0
    fi
fi

# If we are here, device is missing or unreadable.
# Output empty JSON to hide the module
echo ""

