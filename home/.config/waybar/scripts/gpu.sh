#!/bin/bash
OUTPUT=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits)
UTIL=$(echo "$OUTPUT" | awk -F', ' '{print $1}')
TEMP=$(echo "$OUTPUT" | awk -F', ' '{print $2}')
MEM_USED=$(echo "$OUTPUT" | awk -F', ' '{print $3}')
MEM_TOTAL=$(echo "$OUTPUT" | awk -F', ' '{print $4}')
POWER=$(echo "$OUTPUT" | awk -F', ' '{print $5}')

# Calculate VRAM in GiB for display
MEM_GB=$(awk "BEGIN {printf \"%.1f\", $MEM_USED / 1024}")
MEM_PERC=$(awk "BEGIN {printf \"%.0f\", ($MEM_USED / $MEM_TOTAL) * 100}")

# Format fields to fixed width to prevent jitter
UTIL_FMT=$(printf "%3s" "$UTIL")
TEMP_FMT=$(printf "%3s" "$TEMP")
MEM_FMT=$(printf "%4s" "$MEM_GB")

# Output JSON
# Text: Util% Temp°C VRAM_GiB
# Tooltip: Detailed info including Power
echo "{\"text\": \"$UTIL_FMT% ${TEMP_FMT}°C ${MEM_FMT}GiB\", \"tooltip\": \"GPU Usage: $UTIL%\nTemp: ${TEMP}°C\nVRAM: ${MEM_USED}MB / ${MEM_TOTAL}MB ($MEM_PERC%)\nPower: ${POWER}W\", \"class\": \"custom-gpu\", \"percentage\": $UTIL}"