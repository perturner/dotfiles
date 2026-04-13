#!/bin/bash

# Path to the file that stores the last used wallpaper
LAST_WALL_FILE="$HOME/.cache/current_wallpaper_path.txt"
DEFAULT_THEME="Kanagawa-Wave"

# 1. Handle Wallpaper (if image provided or last exists)
if [ -n "$1" ]; then
    WALLPAPER="$1"
    ABS_WALLPAPER=$(realpath "$WALLPAPER")
    echo "$ABS_WALLPAPER" > "$LAST_WALL_FILE"
else
    if [ -f "$LAST_WALL_FILE" ]; then
        WALLPAPER=$(cat "$LAST_WALL_FILE")
    else
        echo "Error: No wallpaper provided."
        exit 1
    fi
fi

# 2. Handle Theme Selection
# Argument 2 is the theme. If not provided, use default.
THEME_SELECTION="${2:-$DEFAULT_THEME}"

if [ "$THEME_SELECTION" = "wallpaper" ]; then
    # Dynamic: generate from image
    echo "Applying dynamic theme from wallpaper..."
    if ! wallust run "$WALLPAPER"; then
        echo "Error: wallust failed to generate colors."
        exit 1
    fi
else
    # Static: apply specific wallust theme
    echo "Applying consistent theme: $THEME_SELECTION..."
    if ! wallust theme "$THEME_SELECTION"; then
        echo "Error: wallust failed to apply theme $THEME_SELECTION. Falling back to $DEFAULT_THEME."
        wallust theme "$DEFAULT_THEME"
    fi
fi

# 3. Update Hyprpaper
if pgrep hyprpaper >/dev/null; then
     MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
     for monitor in $MONITORS; do
         hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
     done
fi

# 4. Update Pywalfox (Firefox)
if command -v pywalfox &> /dev/null; then
    sleep 0.2
    pywalfox update
fi

# 5. Force Kitty Color Reload
for socket in /tmp/kitty-*; do
    if [ -S "$socket" ]; then
        kitty @ --to "unix:$socket" set-colors --all --configured ~/.cache/wal/colors-kitty.conf
    fi
done

# 6. Reload System UI
pkill -SIGUSR2 waybar
if pgrep -x swaync >/dev/null; then
    swaync-client -rs
fi
hyprctl reload
