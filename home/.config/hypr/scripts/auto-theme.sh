#!/bin/bash

# Source Configuration
CONFIG_FILE="$HOME/.config/hypr/theme.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Parse Arguments
# Usage: auto-theme.sh [--theme <theme_name>]
THEME_OVERRIDE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--theme)
            THEME_OVERRIDE="$2"
            shift 2
            ;;
            *)
            shift
            ;;
    esac
done

# Final theme choice (Override > Config > Default)
FINAL_THEME="${THEME_OVERRIDE:-${WALLUST_THEME:-Kanagawa-Wave}}"

log_message() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log_message "Starting theme automation (Theme: $FINAL_THEME)..."

MAX_ATTEMPTS=3
SUCCESS=false

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
    log_message "Attempt $attempt of $MAX_ATTEMPTS..."

    SELECTED_WALLPAPER=""

    if [ "$WALLPAPER_SOURCE" = "wallhaven" ]; then
        log_message "Fetching wallpaper list from Wallhaven..."
        JSON_RESPONSE=$(curl -s "$WALLPAPER_URL")
        WALLPAPER_DATA=$(echo "$JSON_RESPONSE" | jq -r '.data[] | .id + " " + .path')
        
        if [ -n "$WALLPAPER_DATA" ]; then
            IFS=$'\n' read -r -d '' -a WALLPAPERS <<< "$WALLPAPER_DATA"
            RANDOM_IDX=$((RANDOM % ${#WALLPAPERS[@]}))
            IFS=' ' read -r WP_ID WP_PATH <<< "${WALLPAPERS[$RANDOM_IDX]}"
            
            EXT="${WP_PATH##*.}"
            DEST="$HOME/.cache/current_wallpaper.$EXT"
            
            log_message "Selected fresh wallpaper: $WP_ID"
            log_message "Found Wallhaven image: $WP_PATH"
            log_message "Downloading to $DEST..."
            
            if curl -s -o "$DEST" "$WP_PATH"; then
                log_message "Download successful."
                SELECTED_WALLPAPER="$DEST"
            fi
        fi
    else
        log_message "Selecting random local wallpaper..."
        if [ -d "$WALLPAPER_DIR" ]; then
            SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
        fi
    fi

    if [ -n "$SELECTED_WALLPAPER" ]; then
        # Save absolute path
        echo "$(realpath "$SELECTED_WALLPAPER")" > "$HOME/.cache/current_wallpaper_path.txt"

        # Apply Theme using theme-update.sh
        SCRIPT_DIR="$(dirname "$0")"
        UPDATE_SCRIPT="$SCRIPT_DIR/theme-update.sh"

        if [ -x "$UPDATE_SCRIPT" ]; then
            log_message "Applying theme with wallpaper..."
            if "$UPDATE_SCRIPT" "$SELECTED_WALLPAPER" "$FINAL_THEME"; then
                log_message "Theme update script executed successfully."
                SUCCESS=true
                break
            else
                log_message "Error: Theme update script failed. Retrying..."
            fi
        else
            log_message "Error: Update script not found or not executable at $UPDATE_SCRIPT"
            exit 1
        fi
    else
        log_message "Error: Failed to select or download wallpaper. Retrying..."
    fi
    
    sleep 2
done

if [ "$SUCCESS" = false ]; then
    log_message "Critical Error: Failed to update theme after $MAX_ATTEMPTS attempts."
    log_message "Falling back to reloading last good theme..."
    LAST_WALL_FILE="$HOME/.cache/current_wallpaper_path.txt"
    if [ -f "$LAST_WALL_FILE" ]; then
        LAST_WALL=$(cat "$LAST_WALL_FILE")
        "$(dirname "$0")/theme-update.sh" "$LAST_WALL" "$FINAL_THEME"
    fi
    exit 1
fi

# Apply GTK Settings
log_message "Applying GTK settings..."
if [ -n "$THEME_ICONS" ]; then
    gsettings set org.gnome.desktop.interface icon-theme "$THEME_ICONS"
    log_message "Set icon theme to $THEME_ICONS"
fi
if [ -n "$THEME_CURSOR" ]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$THEME_CURSOR"
    log_message "Set cursor theme to $THEME_CURSOR"
fi
if [ -n "$THEME_FONT" ]; then
    gsettings set org.gnome.desktop.interface font-name "$THEME_FONT 11"
    log_message "Set GTK font to $THEME_FONT"
fi

log_message "Theme automation complete."
