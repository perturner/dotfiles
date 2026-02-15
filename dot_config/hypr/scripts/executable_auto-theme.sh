#!/bin/bash

# Load Configuration
CONFIG_FILE="$HOME/.config/hypr/theme.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

# Function to log messages
log_message() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOG_FILE"
    # Also print to stdout so user sees it when running manually
    echo "$1"
}

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

log_message "Starting theme automation..."

MAX_ATTEMPTS=3
ATTEMPT=1
SUCCESS=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    log_message "Attempt $ATTEMPT of $MAX_ATTEMPTS..."
    SELECTED_WALLPAPER=""

    if [ "$WALLPAPER_SOURCE" == "local" ]; then
        if [ -d "$WALLPAPER_DIR" ]; then
            # Pick a random file from the directory
            SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
            log_message "Selected local wallpaper: $SELECTED_WALLPAPER"
        else
            log_message "Error: Wallpaper directory $WALLPAPER_DIR not found."
            exit 1
        fi
    elif [ "$WALLPAPER_SOURCE" == "wallhaven" ]; then
        # Fetch JSON from Wallhaven
        log_message "Fetching wallpaper list from Wallhaven..."
        API_RESPONSE=$(curl -s "$WALLPAPER_URL")
        
        # History file to track seen wallpapers
        HISTORY_FILE="$HOME/.cache/wallpaper_history.txt"
        if [ ! -f "$HISTORY_FILE" ]; then touch "$HISTORY_FILE"; fi

        # Parse valid images (ID and URL) from the response
        # We get a list of "ID|URL" strings
        CANDIDATES=$(echo "$API_RESPONSE" | jq -r '.data[] | "\(.id)|\(.path)"')

        FOUND_NEW=false
        
        # Iterate through candidates to find one not in history
        while IFS='|' read -r ID URL; do
            if [ -z "$ID" ] || [ -z "$URL" ]; then continue; fi
            
            if ! grep -qxF "$ID" "$HISTORY_FILE"; then
                # Found a new wallpaper
                IMAGE_URL="$URL"
                IMAGE_ID="$ID"
                FOUND_NEW=true
                log_message "Selected fresh wallpaper: $ID"
                
                # Add to history and trim to last 50
                echo "$ID" >> "$HISTORY_FILE"
                tail -n 50 "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
                
                break
            fi
        done <<< "$CANDIDATES"

        # Fallback: If all candidates in this batch were seen, just pick the first one
        if [ "$FOUND_NEW" = false ]; then
            log_message "Warning: All returned wallpapers match history. Picking the first one anyway."
            # Extract first one manually
            FIRST_LINE=$(echo "$CANDIDATES" | head -n 1)
            IMAGE_ID="${FIRST_LINE%%|*}"
            IMAGE_URL="${FIRST_LINE#*|}"
        fi
        
        if [ -n "$IMAGE_URL" ] && [ "$IMAGE_URL" != "null" ]; then
            log_message "Found Wallhaven image: $IMAGE_URL"
            
            # Determine extension (jpg/png)
            EXT="${IMAGE_URL##*.}"
            TEMP_WALLPAPER="$HOME/.cache/current_wallpaper.$EXT"
            
            # Extract original filename from URL (e.g., wallhaven-xyz.jpg)
            ORIGINAL_FILENAME=$(basename "$IMAGE_URL")
            echo "$ORIGINAL_FILENAME" > "$HOME/.cache/current_wallpaper_name.txt"

            # Download the image
            log_message "Downloading to $TEMP_WALLPAPER..."
            if curl -L -s -o "$TEMP_WALLPAPER" "$IMAGE_URL"; then
                SELECTED_WALLPAPER="$TEMP_WALLPAPER"
                log_message "Download successful."
            else
                log_message "Error: Failed to download image file."
            fi
        else
            log_message "Error: Failed to extract image URL from Wallhaven response."
            # Log response for debugging (truncate if too long)
            log_message "Response sample: $(echo "$API_RESPONSE" | head -c 200)..."
        fi
    else
        log_message "Error: Invalid wallpaper source '$WALLPAPER_SOURCE'."
        exit 1
    fi

    if [ -n "$SELECTED_WALLPAPER" ]; then
        # Apply Theme using theme-update.sh
        SCRIPT_DIR="$(dirname "$0")"
        UPDATE_SCRIPT="$SCRIPT_DIR/theme-update.sh"

        if [ -x "$UPDATE_SCRIPT" ]; then
            log_message "Applying theme with wallpaper..."
            if "$UPDATE_SCRIPT" "$SELECTED_WALLPAPER"; then
                log_message "Theme update script executed successfully."
                SUCCESS=true
                break
            else
                log_message "Error: Theme update script failed (wal error?). Retrying..."
            fi
        else
            log_message "Error: Update script not found or not executable at $UPDATE_SCRIPT"
            exit 1
        fi
    else
        log_message "Error: No wallpaper selected/downloaded. Retrying..."
    fi

    ATTEMPT=$((ATTEMPT + 1))
    sleep 1
done

if [ "$SUCCESS" = false ]; then
    log_message "Critical Error: Failed to update theme after $MAX_ATTEMPTS attempts."
    log_message "Falling back to reloading last good theme..."
    wal -R
    exit 1
fi

# Apply other parameters (Font, Icons, Cursor) - GTK Implementation
log_message "Applying GTK settings..."

# Apply Icon Theme
if [ -n "$THEME_ICONS" ]; then
    gsettings set org.gnome.desktop.interface icon-theme "$THEME_ICONS"
    log_message "Set icon theme to $THEME_ICONS"
fi

# Apply Cursor Theme
if [ -n "$THEME_CURSOR" ]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$THEME_CURSOR"
    log_message "Set cursor theme to $THEME_CURSOR"
fi

# Apply Font (GTK)
if [ -n "$THEME_FONT" ]; then
    gsettings set org.gnome.desktop.interface font-name "$THEME_FONT 11"
    log_message "Set GTK font to $THEME_FONT"
fi

log_message "Theme automation complete."
