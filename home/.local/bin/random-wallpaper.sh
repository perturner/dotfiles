#!/bin/bash

# The directory where your wallpapers are stored
WALLPAPER_DIR="$HOME/Wallpapers"

# Find all files in the directory and pick one randomly
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Check if a wallpaper was found
if [ -z "$RANDOM_WALLPAPER" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Tell hyprpaper to preload the new wallpaper
hyprctl hyprpaper preload "$RANDOM_WALLPAPER"

# Tell hyprpaper to set the wallpaper
hyprctl hyprpaper wallpaper ",$RANDOM_WALLPAPER"

echo "Wallpaper changed to $RANDOM_WALLPAPER"
