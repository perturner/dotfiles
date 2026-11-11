#!/bin/bash

# Load theme colors for inline Pango spans (fallback to Kanagawa defaults)
COLOR_COOL="#7E9CD8"
COLOR_NORMAL="#98BB6C"
COLOR_WARM="#E6C384"
COLOR_HOT="#E82424"

if [ -f "$HOME/.cache/wal/colors.json" ]; then
    read -r COLOR_COOL COLOR_NORMAL COLOR_WARM COLOR_HOT < <(
        jq -r '[.colors.color4, .colors.color10, .colors.color11, .colors.color9] | join(" ")' "$HOME/.cache/wal/colors.json" 2>/dev/null
    )
fi

get_cpu_temp() {
    # Find coretemp hwmon path
    HWMON_PATH=$(grep -l "coretemp" /sys/class/hwmon/hwmon*/name | head -n 1 | xargs -r dirname)

    if [ -z "$HWMON_PATH" ]; then
        echo "{\"text\": \" N/A\", \"tooltip\": \"Coretemp sensor not found\"}"
        return
    fi

    # Find the label file for "Package id 0"
    LABEL_FILE=$(grep -l "Package id 0" "$HWMON_PATH"/temp*_label | head -n 1)

    if [ -n "$LABEL_FILE" ]; then
        # Construct input file path (replace _label with _input)
        INPUT_FILE="${LABEL_FILE/_label/_input}"
        
        if [ -f "$INPUT_FILE" ]; then
            TEMP_MILLI=$(cat "$INPUT_FILE")
            TEMP_C=$((TEMP_MILLI / 1000))
            
            # Determine icon and class based on temp
            if [ "$TEMP_C" -ge 80 ]; then
                ICON=""
                STATE_CLASS="temp-hot"
            elif [ "$TEMP_C" -ge 60 ]; then
                ICON=""
                STATE_CLASS="temp-warm"
            elif [ "$TEMP_C" -ge 45 ]; then
                ICON=""
                STATE_CLASS="temp-normal"
            else
                ICON=""
                STATE_CLASS="temp-cool"
            fi

            echo "{\"text\": \"$ICON $TEMP_C°C\", \"tooltip\": \"CPU Package Temp\nSensor: $INPUT_FILE\", \"class\": [\"custom-cpu-temp\", \"$STATE_CLASS\"], \"percentage\": $TEMP_C}"
        else
            echo "{\"text\": \" Err\", \"tooltip\": \"Input file not found: $INPUT_FILE\"}"
        fi
    else
        # Fallback to temp1_input if label not found
        FALLBACK="$HWMON_PATH/temp1_input"
        if [ -f "$FALLBACK" ]; then
            TEMP_MILLI=$(cat "$FALLBACK")
            TEMP_C=$((TEMP_MILLI / 1000))
            echo "{\"text\": \" $TEMP_C°C\", \"tooltip\": \"CPU Temp (Fallback)\nSensor: $FALLBACK\", \"class\": \"custom-cpu-temp\"}"
        else
            echo "{\"text\": \" N/A\", \"tooltip\": \"No suitable sensor found\"}"
        fi
    fi
}

get_ram_temp() {
    # Find all spd5118 hwmon paths
    HWMON_PATHS=$(grep -l "spd5118" /sys/class/hwmon/hwmon*/name | xargs -r dirname)

    if [ -z "$HWMON_PATHS" ]; then
        echo "{\"text\": \" N/A\", \"tooltip\": \"SPD5118 sensors not found\"}"
        return
    fi

    MAX_TEMP=0
    TOOLTIP="RAM Temperatures:"

    for path in $HWMON_PATHS; do
        if [ -f "$path/temp1_input" ]; then
            TEMP_MILLI=$(cat "$path/temp1_input")
            TEMP_C=$((TEMP_MILLI / 1000))
            TOOLTIP="$TOOLTIP\nSensor $(basename "$path"): ${TEMP_C}°C"
            if [ "$TEMP_C" -gt "$MAX_TEMP" ]; then
                MAX_TEMP=$TEMP_C
            fi
        fi
    done

    if [ "$MAX_TEMP" -eq 0 ]; then
        echo "{\"text\": \" N/A\", \"tooltip\": \"No temperature data found\"}"
        return
    fi

    # Determine icon and class based on temp (DDR5 thresholds)
    if [ "$MAX_TEMP" -ge 55 ]; then
        ICON=""
        STATE_CLASS="temp-hot"
    elif [ "$MAX_TEMP" -ge 45 ]; then
        ICON=""
        STATE_CLASS="temp-warm"
    elif [ "$MAX_TEMP" -ge 38 ]; then
        ICON=""
        STATE_CLASS="temp-normal"
    else
        ICON=""
        STATE_CLASS="temp-cool"
    fi

    echo "{\"text\": \"$ICON $MAX_TEMP°C\", \"tooltip\": \"$TOOLTIP\", \"class\": [\"custom-ram-temp\", \"$STATE_CLASS\"], \"percentage\": $MAX_TEMP}"
}

get_load() {
    read -r LOAD_1 LOAD_5 LOAD_15 _ < /proc/loadavg
    CORES=$(nproc)
    PERCENT=$(awk -v loadavg="$LOAD_1" -v cores="$CORES" 'BEGIN { printf "%d", (loadavg / cores) * 100 }')

    echo "{\"text\": \"󰓅 $LOAD_1\", \"tooltip\": \"Load average: $LOAD_1, $LOAD_5, $LOAD_15\nCPU threads: $CORES\", \"class\": \"custom-load\", \"percentage\": $PERCENT}"
}

get_water_temp() {
    HWMON_PATH=$(grep -l "asusec" /sys/class/hwmon/hwmon*/name 2>/dev/null | head -n 1 | xargs -r dirname)
    BOARD_HWMON_PATH=$(grep -l "nct6798" /sys/class/hwmon/hwmon*/name 2>/dev/null | head -n 1 | xargs -r dirname)

    if [ -z "$HWMON_PATH" ]; then
        echo "{\"text\": \" N/A\", \"tooltip\": \"ASUS EC water sensor not found\", \"class\": \"custom-water-temp\"}"
        return
    fi

    MAX_TEMP=-999
    TOOLTIP="ASUS EC Temperatures:"

    for label_file in "$HWMON_PATH"/temp*_label; do
        [ -f "$label_file" ] || continue

        LABEL=$(cat "$label_file")
        case "$LABEL" in
            Water_In|Water_Out|T_Sensor|VRM) ;;
            *) continue ;;
        esac

        input_file="${label_file/_label/_input}"
        [ -f "$input_file" ] || continue

        TEMP_MILLI=$(cat "$input_file")
        TEMP_C=$((TEMP_MILLI / 1000))
        TOOLTIP="$TOOLTIP\n$LABEL: ${TEMP_C}°C"

        case "$LABEL" in
            Water_In|Water_Out|T_Sensor)
                # ASUS reports disconnected temperature headers as -40C.
                if [ "$TEMP_C" -gt -20 ] && [ "$TEMP_C" -gt "$MAX_TEMP" ]; then
                    MAX_TEMP=$TEMP_C
                fi
                ;;
        esac
    done

    if [ -n "$BOARD_HWMON_PATH" ]; then
        PUMP_RPM=""
        FAN_MIN=""
        FAN_MAX=""

        for fan_input in "$BOARD_HWMON_PATH"/fan*_input; do
            [ -f "$fan_input" ] || continue

            FAN_NAME=$(basename "$fan_input")
            FAN_ID=${FAN_NAME#fan}
            FAN_ID=${FAN_ID%_input}
            RPM=$(cat "$fan_input")

            [ "$RPM" -gt 0 ] || continue

            if [ "$FAN_ID" = "7" ]; then
                PUMP_RPM=$RPM
                continue
            fi

            if [ -z "$FAN_MIN" ] || [ "$RPM" -lt "$FAN_MIN" ]; then
                FAN_MIN=$RPM
            fi
            if [ -z "$FAN_MAX" ] || [ "$RPM" -gt "$FAN_MAX" ]; then
                FAN_MAX=$RPM
            fi
        done

        if [ -n "$PUMP_RPM" ]; then
            TOOLTIP="$TOOLTIP\nPump: ${PUMP_RPM} RPM"
        fi

        if [ -n "$FAN_MIN" ] && [ -n "$FAN_MAX" ]; then
            TOOLTIP="$TOOLTIP\nFans: ${FAN_MIN}-${FAN_MAX} RPM"
        fi
    fi

    if [ "$MAX_TEMP" -eq -999 ]; then
        echo "{\"text\": \" N/A\", \"tooltip\": \"$TOOLTIP\", \"class\": \"custom-water-temp\"}"
        return
    fi

    # Coolant temperature thresholds
    if [ "$MAX_TEMP" -ge 40 ]; then
        STATE_CLASS="temp-hot"
    elif [ "$MAX_TEMP" -ge 35 ]; then
        STATE_CLASS="temp-warm"
    elif [ "$MAX_TEMP" -ge 30 ]; then
        STATE_CLASS="temp-normal"
    else
        STATE_CLASS="temp-cool"
    fi

    echo "{\"text\": \" ${MAX_TEMP}°C\", \"tooltip\": \"$TOOLTIP\", \"class\": [\"custom-water-temp\", \"$STATE_CLASS\"], \"percentage\": $MAX_TEMP}"
}

get_disk() {
    # Disk Usage for /
    USAGE=$(df -h / | tail -1 | awk '{print $3 " / " $2}')

    # Find all NVMe sensors using sensors command
    NVME_DEVICES=$(sensors 2>/dev/null | grep "nvme-pci-" | cut -d'-' -f3)
    
    MAX_TEMP=0
    TOOLTIP_TEXT="Disk Usage: $USAGE"
    
    for dev in $NVME_DEVICES; do
        SENSOR_NAME="nvme-pci-$dev"
        TEMP=$(sensors "$SENSOR_NAME" 2>/dev/null | grep "Composite" | awk '{print $2}' | cut -d. -f1 | cut -c2-)
        
        if [ -n "$TEMP" ]; then
            if [ "$TEMP" -gt "$MAX_TEMP" ]; then
                MAX_TEMP=$TEMP
            fi
            TOOLTIP_TEXT="$TOOLTIP_TEXT\n$SENSOR_NAME: ${TEMP}°C"
        fi
    done

    if [ "$MAX_TEMP" -eq 0 ]; then
        TEMP_TEXT=" N/A"
    else
        if [ "$MAX_TEMP" -ge 65 ]; then
            DISK_TEMP_COLOR="$COLOR_HOT"
        elif [ "$MAX_TEMP" -ge 50 ]; then
            DISK_TEMP_COLOR="$COLOR_WARM"
        elif [ "$MAX_TEMP" -ge 38 ]; then
            DISK_TEMP_COLOR="$COLOR_NORMAL"
        else
            DISK_TEMP_COLOR="$COLOR_COOL"
        fi
        TEMP_TEXT="<span color='${DISK_TEMP_COLOR}'> ${MAX_TEMP}°C</span>"
    fi

    echo "{\"text\": \" $USAGE  $TEMP_TEXT\", \"tooltip\": \"$TOOLTIP_TEXT\", \"class\": \"custom-disk\"}"
}

case "$1" in
    "cpu")
        get_cpu_temp
        ;;
    "ram")
        get_ram_temp
        ;;
    "load")
        get_load
        ;;
    "water")
        get_water_temp
        ;;
    "disk")
        get_disk
        ;;
    *)
        echo "Usage: $0 {cpu|ram|load|water|disk}"
        exit 1
        ;;
esac
