#!/bin/bash

# --- Config ---
CARD_NAME="alsa_card.pci-0000_04_00.0"
PROFILE_HEADPHONES="output:analog-stereo+input:analog-stereo"
PROFILE_SPEAKERS="output:analog-surround-51+input:analog-stereo"
# ---

# Get the *current* active profile name
CURRENT_PROFILE=$(pactl list cards | \
                    awk -v card="$CARD_NAME" -v RS= '/Name: / && $0 ~ card' | \
                    grep "Active Profile:" | \
                    awk '{print $3}')

# Toggle between the two
if [ "$CURRENT_PROFILE" == "$PROFILE_HEADPHONES" ]; then
    # Currently on Headphones, switch to Speakers
    pactl set-card-profile "$CARD_NAME" "$PROFILE_SPEAKERS"
else
    # Currently on Speakers (or any other profile), switch to Headphones
    pactl set-card-profile "$CARD_NAME" "$PROFILE_HEADPHONES"
fi
