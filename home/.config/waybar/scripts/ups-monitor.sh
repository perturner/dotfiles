#!/bin/bash

# Configuration
UPS_PATH="/org/freedesktop/UPower/devices/ups_hiddev0"
LOG_FILE="$HOME/.cache/power_events.log"
STATE_FILE="/tmp/ups_last_state"
CRITICAL_PERCENT=10

# Get UPS Info
INFO=$(upower -i "$UPS_PATH")
STATUS=$(echo "$INFO" | grep "state:" | awk '{print $2}' | xargs)
PERCENT_STR=$(echo "$INFO" | grep "percentage:" | awk '{print $2}' | xargs)
PERCENT=${PERCENT_STR%\%}
TIME_LEFT=$(echo "$INFO" | grep "time to empty:" | awk '{print $4, $5}' | xargs)
MODEL=$(echo "$INFO" | grep "model:" | cut -d: -f2 | xargs)

# Initialize state file if missing
if [ ! -f "$STATE_FILE" ]; then
    echo "$STATUS" > "$STATE_FILE"
fi

LAST_STATUS=$(cat "$STATE_FILE")

# Logging Events
log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

if [ "$STATUS" != "$LAST_STATUS" ]; then
    log_event "Power state changed: $LAST_STATUS -> $STATUS ($PERCENT_STR)"
    echo "$STATUS" > "$STATE_FILE"
    
    if [ "$STATUS" == "discharging" ]; then
        notify-send -u critical "Power Failure" "UPS is discharging. Battery at $PERCENT_STR."
    elif [ "$STATUS" == "fully-charged" ] && [ "$LAST_STATUS" == "discharging" ]; then
         notify-send -u normal "Power Restored" "UPS is fully charged."
    elif [ "$STATUS" == "charging" ] && [ "$LAST_STATUS" == "discharging" ]; then
         notify-send -u normal "Power Restored" "UPS is charging."
    fi
fi

# Graceful Shutdown Check
if [ "$STATUS" == "discharging" ] && [ -n "$PERCENT" ] && [ "$PERCENT" -le "$CRITICAL_PERCENT" ]; then
    # Check if we already triggered shutdown to avoid loop
    if [ ! -f "/tmp/shutdown_triggered" ]; then
        log_event "CRITICAL: Battery at $PERCENT%. Initiating graceful shutdown."
        notify-send -u critical "CRITICAL BATTERY" "System will shutdown in 60 seconds!"
        touch "/tmp/shutdown_triggered"
        # Schedule shutdown
        shutdown -h +1 "UPS Battery Critical ($PERCENT%)" &
    fi
else
    # Remove trigger lock if we recover
    if [ -f "/tmp/shutdown_triggered" ] && [ "$STATUS" != "discharging" ]; then
        rm "/tmp/shutdown_triggered"
        shutdown -c
        log_event "Shutdown cancelled. Power restored."
        notify-send "Shutdown Cancelled" "Power restored."
    fi
fi

# Output JSON for Waybar
# Icon based on status
ICON="󰚥"
if [ "$STATUS" == "discharging" ]; then
    ICON=""
fi

# Sanitize tooltip content to ensure it's a single line with escaped newlines
TOOLTIP_CONTENT="Model: $MODEL\nState: $STATUS\nCharge: $PERCENT_STR\nTime Left: $TIME_LEFT"

echo "{\"text\": \"$ICON $PERCENT_STR\", \"tooltip\": \"$TOOLTIP_CONTENT\", \"class\": \"$STATUS\", \"percentage\": $PERCENT}"
