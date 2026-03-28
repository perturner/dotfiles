#!/usr/bin/env bash

# 1. Show history picker using Rofi
# We use cliphist to list and rofi to pick
SELECTED=$(cliphist list | rofi -dmenu -p "Clipboard" -config ~/.config/rofi/config.rasi)

# 2. Exit if nothing selected
if [ -z "$SELECTED" ]; then
    exit 0
fi

# 3. Decode selection and copy to clipboard
echo "$SELECTED" | cliphist decode | wl-copy

# 4. Immediate Paste
# Wait a tiny bit for the rofi window to close and focus to return to the app
sleep 0.1
wtype -M ctrl v -m ctrl
