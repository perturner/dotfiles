#!/bin/bash
# G9 Layout Sweep (Group-Aware)
LOG=/tmp/g9-layout.log
echo "--- $(date) ---" > $LOG
MODE=$1

MONITOR_WIDTH=$(hyprctl monitors -j | jq '.[] | select(.focused == true) | .width')
WS=$(hyprctl activeworkspace -j | jq '.id')

# Get clients, but only pick ONE window per unique position (at[0], at[1])
# This effectively treats a Group (tabbed windows) as a single "slot"
CLIENT_DATA=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $WS and .floating == false) | \"\(.at[0])\t\(.at[1])\t\(.address)\"" | sort -n -k1,1 -k2,2 -u)

# Extract just the addresses of these unique slots
WINDOWS=($(echo "$CLIENT_DATA" | cut -f3))
COUNT=${#WINDOWS[@]}
echo "Unique layout slots found: $COUNT" >> $LOG
echo "Addresses: ${WINDOWS[@]}" >> $LOG

if [ "$COUNT" -lt 2 ]; then 
    echo "Not enough slots to layout. Exiting." >> $LOG
    exit 0; 
fi

# Define target percentages
if [ "$MODE" == "proportional" ]; then
    if [ "$COUNT" -eq 2 ]; then TARGETS=(35)
    elif [ "$COUNT" -eq 3 ]; then TARGETS=(15 70)
    elif [ "$COUNT" -eq 4 ]; then TARGETS=(15 35 35)
    else 
        EQUAL_PCT=$(echo "100 / $COUNT" | bc)
        TARGETS=($(for i in $(seq 1 $(($COUNT-1))); do echo $EQUAL_PCT; done))
    fi
else
    EQUAL_PCT=$(echo "100 / $COUNT" | bc)
    TARGETS=($(for i in $(seq 1 $(($COUNT-1))); do echo $EQUAL_PCT; done))
fi

# Sweep from left to right
for i in "${!TARGETS[@]}"; do
    ADDR=${WINDOWS[$i]}
    PCT=${TARGETS[$i]}
    
    hyprctl dispatch focuswindow "address:$ADDR" >> $LOG 2>&1
    
    CUR_WIDTH=$(hyprctl activewindow -j | jq '.size[0]')
    TARGET_PX=$(echo "($MONITOR_WIDTH * $PCT) / 100" | bc)
    DIFF=$(echo "$TARGET_PX - $CUR_WIDTH" | bc)
    
    echo "Slot $i ($ADDR): Current=$CUR_WIDTH, Target=$TARGET_PX, Diff=$DIFF" >> $LOG
    hyprctl dispatch resizeactive "$DIFF" 0 >> $LOG 2>&1
done

# Refocus a central slot
CENTER_IDX=$(echo "$COUNT / 2" | bc)
hyprctl dispatch focuswindow "address:${WINDOWS[$CENTER_IDX]}" >> $LOG 2>&1
