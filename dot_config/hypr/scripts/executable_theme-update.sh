#!/bin/bash

# 1. Generate Colors & Update Wallpaper (if image provided)
if [ -n "$1" ]; then
    WALLPAPER="$1"

    # Generate colors with pywal (skip setting wallpaper with -n)
    if ! wal -i "$WALLPAPER" -n; then
        echo "Error: wal failed to generate colors."
        exit 1
    fi

    # Update Hyprpaper using modern IPC
    # Note: hyprpaper now auto-preloads the image if not already loaded
    if pgrep hyprpaper >/dev/null; then
         echo "Updating Hyprpaper..."
         # Get all connected monitor names
         MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
         
         # Set the wallpaper for each monitor
         for monitor in $MONITORS; do
             hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
         done
    else
         echo "Warning: hyprpaper not running. Wallpaper not updated."
    fi
else
    if ! wal -R; then
        echo "Error: wal failed to reload colors."
        exit 1
    fi
fi

# 2. Update Pywalfox (Firefox)
pywalfox update

# 3. Force Kitty Color Reload (Robustness)
for socket in /tmp/kitty-*; do
    if [ -S "$socket" ]; then
        kitty @ --to "unix:$socket" set-colors --all --configured ~/.cache/wal/colors-kitty.conf
    fi
done

# 4. Reload Waybar to pick up new colors
pkill -SIGUSR2 waybar

# 4. Reload SwayNC Style
if pgrep -x swaync >/dev/null; then
    swaync-client -rs
fi

# 5. Reload Hyprland (updates borders)
hyprctl reload
