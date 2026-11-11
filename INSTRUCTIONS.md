# Project: Hyprland User Configuration

## Overview
This directory contains the user configuration ("dotfiles") for a highly customized Linux desktop environment built on **Hyprland** (a dynamic tiling Wayland compositor). The setup is optimized for a ultra-wide workstation featuring a **Samsung Odyssey Neo G9 (32:9)**.

The environment relies on `fish` as the interactive shell, `waybar` for the status bar, and integrates dynamic theming via `pywal` and custom scripts.

## Key Components

### Window Manager (Hyprland)
*   **Config File:** `~/.config/hypr/hyprland.lua`
*   **Layout:** Dwindle
*   **Monitors:**
    *   Samsung Odyssey Neo G9 (7680x2160 @ 240Hz) - Workspaces 1-10
*   **Session Management:** Uses `uwsm` (Universal Wayland Session Manager) to handle autostart apps and session binding.

### Status Bar (Waybar)
*   **Config File:** `~/.config/waybar/config`
*   **Style:** `~/.config/waybar/style.css`
*   **Features:** Custom modules for hardware monitoring (CPU, GPU, RAM, Disk, Wattage), peripherals battery, and network traffic.

### Shell (Fish)
*   **Config File:** `~/.config/fish/config.fish`
*   **Environment:** Sets up `uwsm`, standard editors (`nano`, `code`), and `pyenv` for Python management.

### Theming & Automation
*   **Script:** `~/.config/hypr/scripts/auto-theme.sh`
*   **Config:** `~/.config/hypr/theme.conf`
*   **Functionality:** Automatically fetches high-resolution (32:9) wallpapers from Wallhaven or a local directory, applies the wallpaper, and updates system colors (GTK, Hyprland borders, Waybar) using `wal` (Pywal).

## Key Keybindings
(Prefix `$mainMod` is `SUPER`/Windows Key)

*   **Term:** `$mainMod + Q` (Kitty)
*   **Browser:** `$mainMod + W` (Firefox)
*   **File Manager:** `$mainMod + E` (DoubleCmd)
*   **Launcher:** `$mainMod + R` or `ALT + SPACE` (Rofi)
*   **Close Window:** `$mainMod + C`
*   **Toggle Floating:** `$mainMod + SHIFT + V`
*   **Theme/Audio Profile:** `$mainMod + O` triggers `audio-profile-toggler.sh`

## Development & Usage

### Making Changes
1.  **Hyprland:** Edit `hyprland.conf`. Changes usually auto-reload, or use `uwsm stop` to exit.
2.  **Waybar:** Edit `waybar/config` or `waybar/style.css`. Waybar often auto-reloads on config save, or can be restarted via `pkill waybar; waybar &`.
3.  **Theming:** Adjust `hypr/theme.conf` to change the wallpaper source (local vs. wallhaven) or preferred GTK fonts/icons. Run `~/.config/hypr/scripts/auto-theme.sh` to test manually.

### System Requirements
*   **OS:** Linux (Arch-based recommended due to `yay` presence)
*   **Core Packages:** `hyprland`, `waybar`, `fish`, `kitty`, `rofi`, `uwsm`, `wal` (python-pywal), `swww` or `hyprpaper` (for wallpaper), `curl`, `jq`.
