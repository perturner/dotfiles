#!/usr/bin/fish

# Dual-Quake Scratchpad Toggle
# Uses the special:scratchpad workspace

# 1. Toggle the workspace visibility
hyprctl dispatch togglespecialworkspace scratchpad

# 2. Ensure both terminals are running
# The window rules in hyprland.conf will handle the placement and workspace assignment
if not hyprctl clients | grep -q "scratchpad-left"
    uwsm app -- kitty --class scratchpad-left &
end

if not hyprctl clients | grep -q "scratchpad-right"
    uwsm app -- kitty --class scratchpad-right &
end
