#!/bin/bash

# --- This is your Creative AE-5 Card Name ---
CARD_NAME="alsa_card.pci-0000_04_00.0"
# ---

# Get the list of profiles, filtering out blank lines
PROFILE_LIST=$(pactl list cards | \
                 awk -v card="$CARD_NAME" -v RS= '/Name: / && $0 ~ card' | \
                 awk '/Profiles:/ {f=1; next} /Active Profile:/ {f=0} f' | \
                 sed 's/^\s*//' | \
                 grep -v '^\s*$') # Filter out blank lines

# Let the user choose a profile from Rofi
CHOSEN_PROFILE_LINE=$(echo -e "$PROFILE_LIST" | rofi -dmenu -p "Select Profile:")

# If the user cancelled, exit
if [ -z "$CHOSEN_PROFILE_LINE" ]; then
    exit 0
fi

# --- THIS IS THE FIX ---
# Extract the full technical name, which is everything before
# the colon that is followed by the description (which starts with a capital, or "Off").
CHOSEN_PROFILE_NAME=$(echo "$CHOSEN_PROFILE_LINE" | \
                      sed -E 's/^(.*): ([A-Z]|Off).*$/\1/' | \
                      xargs)
# --- END FIX ---

# Set the chosen profile for the card
pactl set-card-profile "$CARD_NAME" "$CHOSEN_PROFILE_NAME"
