#!/bin/bash
# Description: Launches Firefox inside a WireGuard-protected network namespace.
# Usage: sudo ./launch-vpn-firefox.sh [config_name]
# Example: sudo ./launch-vpn-firefox.sh integrity

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# Get the actual user info
REAL_USER=${SUDO_USER:-$(whoami)}
REAL_UID=$(id -u "$REAL_USER")
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
USER_RUNTIME_DIR="/run/user/$REAL_UID"

# --- CONFIGURATION SELECTION ---
CONFIG_NAME="${1:-integrity}"
WG_CONF="$REAL_HOME/.config/wireguard/${CONFIG_NAME}.conf"
NS_NAME="${CONFIG_NAME}"
WG_IF="wg-${CONFIG_NAME}"

# Limit interface name to 15 characters (Linux limit)
if [ ${#WG_IF} -gt 15 ]; then
    WG_IF="${WG_IF:0:15}"
fi

# Check for config
if [ ! -f "$WG_CONF" ]; then
  echo "Error: Configuration file not found at $WG_CONF"
  echo "Available configurations in ~/.config/wireguard/:"
  find "$REAL_HOME/.config/wireguard" -maxdepth 1 -name "*.conf" -printf "  - %f\n" 2>/dev/null | sed 's/\.conf//'
  exit 1
fi

# --- AUTO-DETECT WAYLAND DISPLAY ---
if [ -z "$WAYLAND_DISPLAY" ]; then
    DETECTED_WD=$(find "$USER_RUNTIME_DIR" -maxdepth 1 -name "wayland-*" -type s -printf "%f\n" | head -n 1)
    if [ -n "$DETECTED_WD" ]; then
        WAYLAND_DISPLAY="$DETECTED_WD"
        echo "Auto-detected Wayland display: $WAYLAND_DISPLAY"
    fi
fi

# --- AUTO-DETECT GRAPHICS ENV VARS ---
# Fetch user's session environment variables (needed for NVIDIA/VAAPI)
USER_ENV_VARS=$(sudo -u "$REAL_USER" systemctl --user show-environment)

get_user_env() {
    echo "$USER_ENV_VARS" | grep "^$1=" | cut -d= -f2-
}

VAR_LIBVA=$(get_user_env "LIBVA_DRIVER_NAME")
VAR_NVD=$(get_user_env "NVD_BACKEND")
VAR_EGL=$(get_user_env "__EGL_VENDOR_LIBRARY_FILENAMES")

cleanup() {
    echo "Cleaning up network namespace..."
    ip netns del "$NS_NAME" 2>/dev/null
    rm -rf "/etc/netns/$NS_NAME"
}
trap cleanup EXIT

echo "Setting up namespace '$NS_NAME'..."
ip netns add "$NS_NAME"

ip link add "$WG_IF" type wireguard
ip link set "$WG_IF" netns "$NS_NAME"

# --- CONFIGURATION PARSING ---
ADDRESSES=$(grep -iP '^Address\s*=' "$WG_CONF" | cut -d= -f2 | tr ',' ' ')
DNS_SERVERS=$(grep -iP '^DNS\s*=' "$WG_CONF" | cut -d= -f2 | tr ',' ' ')

if [ -z "$ADDRESSES" ]; then
    echo "Error: Could not parse Address from config."
    exit 1
fi

CLEAN_CONF=$(mktemp)
grep -vEi '^\s*(Address|DNS|MTU|Table|PostUp|PostDown|PreUp|PreDown|SaveConfig)\s*=' "$WG_CONF" > "$CLEAN_CONF"

ip netns exec "$NS_NAME" wg setconf "$WG_IF" "$CLEAN_CONF"
rm -f "$CLEAN_CONF"

ip netns exec "$NS_NAME" ip link set "$WG_IF" up
for ip in $ADDRESSES; do
    ip netns exec "$NS_NAME" ip address add "$ip" dev "$WG_IF"
done
ip netns exec "$NS_NAME" ip link set lo up
ip netns exec "$NS_NAME" ip route add default dev "$WG_IF"

mkdir -p "/etc/netns/$NS_NAME"

# Do not let processes in this namespace use the host's systemd-resolved
# socket.  It can bypass this namespace's resolv.conf (and its DNS policy).
sed -E '/^hosts:/ s/[[:space:]]+resolve([[:space:]]+\[[^]]+\])?//' \
    /etc/nsswitch.conf > "/etc/netns/$NS_NAME/nsswitch.conf"

if [ -n "$DNS_SERVERS" ]; then
    > "/etc/netns/$NS_NAME/resolv.conf"
    for dns in $DNS_SERVERS; do
        echo "nameserver $dns" >> "/etc/netns/$NS_NAME/resolv.conf"
    done
fi

echo "VPN namespace ready. Launching Firefox..."

# --- LAUNCH FIREFOX ---
PULSE_ENV=""
if [ -e "$USER_RUNTIME_DIR/pulse/native" ]; then
    PULSE_ENV="PULSE_SERVER=unix:$USER_RUNTIME_DIR/pulse/native"
fi

# Pass detected env vars + force Wayland
ip netns exec "$NS_NAME" sudo -u "$REAL_USER" \
    env \
    DISPLAY="${DISPLAY:-:0}" \
    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    XAUTHORITY="$XAUTHORITY" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$USER_RUNTIME_DIR/bus" \
    XDG_RUNTIME_DIR="$USER_RUNTIME_DIR" \
    XCURSOR_SIZE="${XCURSOR_SIZE:-24}" \
    XCURSOR_THEME="$XCURSOR_THEME" \
    GTK_THEME="$GTK_THEME" \
    HOME="$REAL_HOME" \
    LIBVA_DRIVER_NAME="$VAR_LIBVA" \
    NVD_BACKEND="$VAR_NVD" \
    __EGL_VENDOR_LIBRARY_FILENAMES="$VAR_EGL" \
    $PULSE_ENV \
    MOZ_ENABLE_WAYLAND=1 \
    firefox

echo "Firefox closed. Cleanup complete."
