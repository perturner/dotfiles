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

CACHE_DIR="$HOME/.cache/wallpapers"
HISTORY_FILE="$HOME/.cache/wallpaper_history.txt"
mkdir -p "$CACHE_DIR"
touch "$HISTORY_FILE"

is_recent() {
    local id="$1"
    grep -Fxq "$id" "$HISTORY_FILE" 2>/dev/null
}

record_history() {
    local id="$1"
    echo "$id" >> "$HISTORY_FILE"
    tail -n 40 "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

fetch_wallhaven() {
    log_message "Fetching wallpaper list from Wallhaven..."
    local json_response
    json_response=$(curl -s --max-time 10 "$WALLPAPER_URL")
    local wallpaper_data
    wallpaper_data=$(echo "$json_response" | jq -r '.data[]? | .id + " " + .path')

    if [ -n "$wallpaper_data" ]; then
        local candidates=()
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            local wp_id="${line%% *}"
            if ! is_recent "wallhaven:$wp_id"; then
                candidates+=("$line")
            fi
        done <<< "$wallpaper_data"

        # If all returned items were in recent history, fall back to full list
        if [ ${#candidates[@]} -eq 0 ]; then
            while IFS= read -r line; do
                [ -n "$line" ] && candidates+=("$line")
            done <<< "$wallpaper_data"
        fi

        if [ ${#candidates[@]} -gt 0 ]; then
            local idx=$((RANDOM % ${#candidates[@]}))
            local wp_id wp_path
            read -r wp_id wp_path <<< "${candidates[$idx]}"
            local ext="${wp_path##*.}"
            local dest="$CACHE_DIR/wallhaven-${wp_id}.${ext}"

            log_message "Selected Wallhaven wallpaper: $wp_id ($wp_path)"
            if curl -sL --fail --max-time 20 -o "$dest" "$wp_path" && [ -s "$dest" ]; then
                record_history "wallhaven:$wp_id"
                SELECTED_WALLPAPER="$dest"
                return 0
            fi
        fi
    fi
    return 1
}

fetch_reddit() {
    local sorts=("sort=top&t=year" "sort=top&t=all" "sort=hot" "sort=new" "sort=top&t=month")
    local sort_param="${sorts[$((RANDOM % ${#sorts[@]}))]}"
    local rss_url="${REDDIT_RSS_BASE}&${sort_param}"

    log_message "Fetching wallpaper list from Reddit ($sort_param)..."
    local rss_content
    rss_content=$(curl -sL --max-time 10 -A "Mozilla/5.0 (X11; Linux x86_64; rv:135.0) Gecko/20100101 Firefox/135.0" "$rss_url")
    local urls
    urls=$(echo "$rss_content" | grep -oE 'https://i\.redd\.it/[a-zA-Z0-9_-]+\.(jpg|jpeg|png)' | sort -u)

    if [ -n "$urls" ]; then
        local candidates=()
        while IFS= read -r url; do
            [ -z "$url" ] && continue
            local fname="${url##*/}"
            if ! is_recent "reddit:$fname"; then
                candidates+=("$url")
            fi
        done <<< "$urls"

        if [ ${#candidates[@]} -eq 0 ]; then
            while IFS= read -r url; do
                [ -n "$url" ] && candidates+=("$url")
            done <<< "$urls"
        fi

        if [ ${#candidates[@]} -gt 0 ]; then
            local idx=$((RANDOM % ${#candidates[@]}))
            local img_url="${candidates[$idx]}"
            local fname="${img_url##*/}"
            local dest="$CACHE_DIR/reddit-${fname}"

            log_message "Selected Reddit wallpaper: $img_url"
            if curl -sL --fail --max-time 20 -o "$dest" "$img_url" && [ -s "$dest" ]; then
                record_history "reddit:$fname"
                SELECTED_WALLPAPER="$dest"
                return 0
            fi
        fi
    fi
    return 1
}

fetch_local() {
    log_message "Selecting random local wallpaper from $WALLPAPER_DIR..."
    if [ -d "$WALLPAPER_DIR" ]; then
        local files=()
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            if ! is_recent "local:$file"; then
                files+=("$file")
            fi
        done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))

        if [ ${#files[@]} -eq 0 ]; then
            while IFS= read -r file; do
                [ -n "$file" ] && files+=("$file")
            done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
        fi

        if [ ${#files[@]} -gt 0 ]; then
            local idx=$((RANDOM % ${#files[@]}))
            SELECTED_WALLPAPER="${files[$idx]}"
            record_history "local:$SELECTED_WALLPAPER"
            log_message "Selected local wallpaper: $SELECTED_WALLPAPER"
            return 0
        fi
    fi
    return 1
}

# Build list of enabled sources (supports both WALLPAPER_SOURCES and legacy WALLPAPER_SOURCE)
SOURCES_STR="${WALLPAPER_SOURCES:-${WALLPAPER_SOURCE:-wallhaven}}"
read -r -a SOURCES_ARR <<< "$SOURCES_STR"

MAX_ATTEMPTS=4
SUCCESS=false

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
    log_message "Attempt $attempt of $MAX_ATTEMPTS..."

    SELECTED_WALLPAPER=""
    CHOSEN_SOURCE="${SOURCES_ARR[$((RANDOM % ${#SOURCES_ARR[@]}))]}"
    log_message "Trying source: $CHOSEN_SOURCE"

    case "$CHOSEN_SOURCE" in
        wallhaven)
            fetch_wallhaven || fetch_reddit || fetch_local
            ;;
        reddit)
            fetch_reddit || fetch_wallhaven || fetch_local
            ;;
        local)
            fetch_local || fetch_wallhaven
            ;;
        *)
            fetch_wallhaven || fetch_local
            ;;
    esac

    if [ -n "$SELECTED_WALLPAPER" ]; then
        # Prune old cached downloads (keep newest 10 files in CACHE_DIR)
        ls -1t "$CACHE_DIR"/* 2>/dev/null | tail -n +11 | xargs -r rm -f

        # Save absolute path
        echo "$(realpath "$SELECTED_WALLPAPER")" > "$HOME/.cache/current_wallpaper_path.txt"

        # Apply Theme using theme-update.sh
        SCRIPT_DIR="$(dirname "$0")"
        UPDATE_SCRIPT="$SCRIPT_DIR/theme-update.sh"

        if [ -x "$UPDATE_SCRIPT" ]; then
            log_message "Applying theme with wallpaper: $SELECTED_WALLPAPER"
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
