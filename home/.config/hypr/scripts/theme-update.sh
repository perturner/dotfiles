#!/bin/bash

# Path to the file that stores the last used wallpaper
LAST_WALL_FILE="$HOME/.cache/current_wallpaper_path.txt"

# 1. Generate Colors & Update Wallpaper (if image provided or last exists)
if [ -n "$1" ]; then
    # New wallpaper provided as argument
    WALLPAPER="$1"
    # Ensure it's absolute for persistence
    ABS_WALLPAPER=$(realpath "$WALLPAPER")
    echo "$ABS_WALLPAPER" > "$LAST_WALL_FILE"
else
    # Reload mode - check for the last used wallpaper path
    if [ -f "$LAST_WALL_FILE" ]; then
        WALLPAPER=$(cat "$LAST_WALL_FILE")
    else
        echo "Error: No wallpaper provided and no last_wallpaper found."
        exit 1
    fi
fi

# Generate colors with wallust
# wallust run: generates colors and applies templates
if ! wallust run "$WALLPAPER"; then
    echo "Error: wallust failed to generate colors from $WALLPAPER"
    exit 1
fi

# Update Hyprpaper using modern IPC
if pgrep hyprpaper >/dev/null; then
     echo "Updating Hyprpaper..."
     MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
     
     for monitor in $MONITORS; do
         hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
     done
else
     echo "Warning: hyprpaper not running. Wallpaper not updated."
fi

# 2. Update Pywalfox (Firefox)
if command -v pywalfox &> /dev/null; then
    pywalfox update
fi

# 3. Force Kitty Color Reload
for socket in /tmp/kitty-*; do
    if [ -S "$socket" ]; then
        kitty @ --to "unix:$socket" set-colors --all --configured ~/.cache/wal/colors-kitty.conf
    fi
done

# 4. Reload Waybar
pkill -SIGUSR2 waybar

# 5. Reload SwayNC Style
if pgrep -x swaync >/dev/null; then
    swaync-client -rs
fi

# 6. Reload Hyprland
hyprctl reload
