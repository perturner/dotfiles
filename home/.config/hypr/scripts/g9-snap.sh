#!/bin/bash
# G9 Precise Snap Script - Center-Aware
HYPRCTL=/usr/bin/hyprctl
JQ=/usr/bin/jq
BC=/usr/bin/bc

TARGET_PCT=$1
if [[ -z "$TARGET_PCT" ]]; then exit 1; fi

# Get monitor and window info
MONITOR_WIDTH=$($HYPRCTL monitors -j | $JQ '.[] | select(.focused == true) | .width')
WINDOW_INFO=$($HYPRCTL activewindow -j)
ACTIVE_WIDTH=$(echo "$WINDOW_INFO" | $JQ '.size[0]')
ACTIVE_X=$(echo "$WINDOW_INFO" | $JQ '.at[0]')

# Calculate target pixel width
TARGET_WIDTH=$(echo "($MONITOR_WIDTH * $TARGET_PCT) / 100" | $BC)
DIFF=$(echo "$TARGET_WIDTH - $ACTIVE_WIDTH" | $BC)

# If DIFF is 0, nothing to do
if [ "$DIFF" -eq 0 ]; then exit 0; fi

# Center-Aware Logic:
# If window center is in the left half, resize right.
# If window center is in the right half, we need to push the left handle.
WINDOW_CENTER=$(echo "$ACTIVE_X + ($ACTIVE_WIDTH / 2)" | $BC)
HALFWAY=$(echo "$MONITOR_WIDTH / 2" | $BC)

if [ $(echo "$WINDOW_CENTER < $HALFWAY" | $BC) -eq 1 ]; then
    # Left side: Standard resize (affects right handle)
    $HYPRCTL dispatch resizeactive "$DIFF" 0
else
    # Right side: To move the left handle, we must move the split of the PREVIOUS window.
    # We use 'm' (move focus) to the left, resize, then move back.
    $HYPRCTL dispatch movefocus l
    # Note: Growing the left neighbor by DIFF (if positive) shrinks us by DIFF.
    # So we need to grow the left neighbor by NEGATIVE DIFF.
    INVERSE_DIFF=$(echo "-1 * $DIFF" | $BC)
    $HYPRCTL dispatch resizeactive "$INVERSE_DIFF" 0
    $HYPRCTL dispatch movefocus r
fi
