#!/bin/bash

# --- Creative AE-5 Sink ---
SINK_NAME="alsa_output.pci-0000_04_00.0.analog-surround-51"
# ---

# 1. Isolate the correct sink block using awk's "record" mode
# 2. Find only the lines between "Ports:" and "Active Port:"
# 3. Get the port name (everything before the first colon)
# 4. Trim whitespace
PORT_LIST=$(pactl list sinks | \
              awk -v sink="$SINK_NAME" -v RS= '/Name: / && $0 ~ sink' | \
              awk '/Ports:/ {f=1; next} /Active Port:/ {f=0} f' | \
              awk -F: '{print $1}' | \
              sed 's/^\s*//;s/\s*$//')

# Let the user choose a port from Rofi
CHOSEN_PORT=$(echo -e "$PORT_LIST" | rofi -dmenu -p "Select Port:")

# If the user cancelled, exit
if [ -z "$CHOSEN_PORT" ]; then
    exit 0
fi

# Set the chosen port for the sink
pactl set-sink-port "$SINK_NAME" "$CHOSEN_PORT"
