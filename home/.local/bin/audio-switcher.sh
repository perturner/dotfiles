#!/bin/bash

# Get a clean list of "ID Description"
SINK_LIST=$(pactl list sinks | \
            grep -E '^\s*Sink #|^\s*Description:' | \
            sed 'N;s/\n\s*Description: / /' | \
            sed 's/Sink #//' | \
            sed 's/^\s*//')

CHOSEN_SINK=$(echo -e "$SINK_LIST" | rofi -dmenu -p "Select Audio Output:")

if [ -z "$CHOSEN_SINK" ]; then
    exit 0
fi

# Get just the ID
SINK_ID=$(echo "$CHOSEN_SINK" | awk '{print $1}')


# --- THIS IS THE FIX ---

# 1. Explicitly "wake up" the sink (set suspend to false)
# This is the crucial step for suspended devices like your headset.
pactl suspend-sink "$SINK_ID" 0

# 2. Add a tiny delay (50ms) to fix the race condition.
# This gives the server time to make the sink "ready".
sleep 0.05

# 3. Set the default sink for new streams (using pactl for consistency)
pactl set-default-sink "$SINK_ID"

# 4. Now, move all existing streams.
for INPUT_ID in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$INPUT_ID" "$SINK_ID"
done

# --- END FIX ---
