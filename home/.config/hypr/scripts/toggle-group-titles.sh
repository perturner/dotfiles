#!/bin/bash

# Toggle Hyprland group titles visibility while keeping a clickable pill bar when hidden

RENDER_TITLES=$(hyprctl getoption group.groupbar.render_titles -j | jq -r '.bool')

if [ "$RENDER_TITLES" = "true" ]; then
    hyprctl eval 'hl.config({ group = { groupbar = { render_titles = false, indicator_height = 12 } } })'
else
    hyprctl eval 'hl.config({ group = { groupbar = { render_titles = true, indicator_height = 0 } } })'
fi


