#!/bin/bash

# Check if a wallpaper path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/wallpaper"
    exit 1
fi

WALLPAPER="$1"

# 1. Set wallpaper using swww
swww img "$WALLPAPER" --transition-type any --transition-duration 1

# 2. Generate colors with Wal, skipping terminal setup (-n)
wal -i "$WALLPAPER" -n

# 3. Source the generated colors
source "${HOME}/.cache/wal/colors.sh"

# 4. Apply colors to Hyprland borders
hyprctl keyword general:col.active_border "rgb(${color4:1}) rgb(${color2:1}) 45deg"
hyprctl keyword general:col.inactive_border "rgb(${color8:1})"

# 5. Reload Waybar to apply new CSS
killall -SIGUSR2 waybar

# 6. (Optional) Reload Mako for notifications
# makoctl reload

echo "Theme and wallpaper updated."
