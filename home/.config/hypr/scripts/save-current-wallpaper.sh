#!/bin/bash

# Configuration
SAVE_DIR="$HOME/Wallpapers/saved" # Default directory to save wallpapers

# Function to log messages
log_message() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1"
}

# Ensure save directory exists
if [ ! -d "$SAVE_DIR" ]; then
    log_message "Creating save directory: $SAVE_DIR"
    mkdir -p "$SAVE_DIR" || { log_message "Error: Failed to create directory $SAVE_DIR"; exit 1; }
fi

# Find the current wallpaper file in .cache based on current_wallpaper.EXT pattern
# Assumes the latest 'current_wallpaper.*' is the one currently active.
LATEST_WALLPAPER=$(find "$HOME/.cache" -maxdepth 1 -type f -name "current_wallpaper.*" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

if [ -z "$LATEST_WALLPAPER" ] || [ ! -f "$LATEST_WALLPAPER" ]; then
    log_message "Error: No current wallpaper found at $HOME/.cache/current_wallpaper.*"
    exit 1
fi

EXT="${LATEST_WALLPAPER##*.}"
CURRENT_WALLPAPER_PATH="$LATEST_WALLPAPER"

# Read the original filename, if available
ORIGINAL_FILENAME_HINT=""
if [ -f "$HOME/.cache/current_wallpaper_name.txt" ]; then
    ORIGINAL_FILENAME_HINT=$(cat "$HOME/.cache/current_wallpaper_name.txt")
    # Remove extension for hint
    ORIGINAL_FILENAME_HINT="${ORIGINAL_FILENAME_HINT%.*}"
fi

# Prompt user for a filename
read -p "Enter a name for the wallpaper (default: $ORIGINAL_FILENAME_HINT, will save as .${EXT}): " FILENAME_BASE

# If no filename provided, use the original filename hint, or a timestamp if hint is empty
if [ -z "$FILENAME_BASE" ]; then
    if [ -n "$ORIGINAL_FILENAME_HINT" ]; then
        FILENAME_BASE="$ORIGINAL_FILENAME_HINT"
        log_message "No name provided, using original filename hint: $FILENAME_BASE"
    else
        FILENAME_BASE="wallpaper_$(date +%Y%m%d%H%M%S)"
        log_message "No name provided and no hint, using default: $FILENAME_BASE"
    fi
fi

SAVE_PATH="$SAVE_DIR/$FILENAME_BASE.$EXT"

# Check if the file already exists
if [ -f "$SAVE_PATH" ]; then
    read -p "File '$FILENAME_BASE.$EXT' already exists. Overwrite? (y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        log_message "Aborting: File not overwritten."
        exit 0
    fi
fi

# Copy the file
log_message "Saving wallpaper from '$CURRENT_WALLPAPER_PATH' to '$SAVE_PATH'வுகளை..."
if cp "$CURRENT_WALLPAPER_PATH" "$SAVE_PATH"; then
    log_message "Successfully saved wallpaper to: $SAVE_PATH"
else
    log_message "Error: Failed to save wallpaper."
    exit 1
fi
