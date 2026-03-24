#!/bin/bash

echo "🎵  Stopping Spotify..."
# Kill the official launcher service (if it's running as a service)
systemctl --user stop spotify-launcher 2>/dev/null

# Kill any lingering processes (forcefully)
pkill -9 -f spotify

echo "🔊  Restarting Audio System (PipeWire)..."
systemctl --user restart pipewire pipewire-pulse wireplumber

# Wait a moment for audio to stabilize
sleep 2

echo "🚀  Starting Spotify..."
# Start it via the launcher (preferred method for your install)
# Detach it so closing the terminal doesn't kill it
nohup spotify-launcher >/dev/null 2>&1 &

echo "✅  Done!"
