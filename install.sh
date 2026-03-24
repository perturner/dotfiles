#!/bin/bash

# Get the absolute path of the dotfiles directory
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

# Function to create symlinks recursively
# Usage: link_env <folder_name>
link_env() {
    local env_folder="$DOTFILES_DIR/$1"
    if [ ! -d "$env_folder" ]; then
        return
    fi

    echo "Linking $1 environment..."

    # Find all files recursively, ignoring directories
    cd "$env_folder" && find . -type f | while read -r file; do
    # Strip the leading './'
    local rel_path="${file#./}"
    local src="$env_folder/$rel_path"
    local dest="$HOME/$rel_path"

    # Create parent directory if missing
    mkdir -p "$(dirname "$dest")"

    # Create the symbolic link
    ln -sf "$src" "$dest"

    # Ensure scripts in bin/ are executable
    if [[ "$rel_path" == *"/bin/"* ]]; then
        chmod +x "$dest"
    fi
done
}

# Always link Common
link_env "common"

# Link Identity Fragment (Path-agnostic email handling)
if [[ $(hostname) == *"gripen"* ]]; then
    echo "Detected home environment..."
    link_env "home"
    # Ensure identity points to the home version
    ln -sf "$DOTFILES_DIR/home/.gitconfig_identity" "$HOME/.gitconfig_identity"
else
    echo "Detected work environment..."
    link_env "work"
    # Ensure identity points to the work version
    ln -sf "$DOTFILES_DIR/work/.gitconfig_identity" "$HOME/.gitconfig_identity"
fi

# Ensure a private git config exists (even if empty)
# This prevents Git from complaining about a missing include path
if [ ! -f "$HOME/.gitconfig_private" ]; then
    touch "$HOME/.gitconfig_private"
    echo "Created empty ~/.gitconfig_private"
fi

echo "Done. Dotfiles successfully linked."
