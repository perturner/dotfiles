#!/usr/bin/env bash
set -euo pipefail

hyprctl eval 'hl.config({ master = { orientation = "right", mfact = 0.70 } })' >/dev/null

game_address=$(hyprctl activewindow -j | jq -r '.address')

if [ "$game_address" != "null" ] && [ -n "$game_address" ]; then
    hyprctl dispatch 'hl.dsp.layout("swapwithmaster")' >/dev/null 2>&1 || true
fi

notify-send "Hyprland" "Game + stream layout: 70/30"
