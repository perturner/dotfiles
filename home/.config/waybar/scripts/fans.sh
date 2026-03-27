#!/bin/bash
# Fan 2 is the actual CPU Fan (~600-700 RPM)
FAN_CPU=$(sensors nct6798-isa-0290 | grep "fan2" | awk '{print $2}')

# Fan 7 is the Water Pump (~4700 RPM)
FAN_PUMP=$(sensors nct6798-isa-0290 | grep "fan7" | awk '{print $2}')

# Output JSON
# Text: FanRPM | PumpRPM
echo "{\"text\": \"󰈐 $FAN_CPU |  $FAN_PUMP\", \"tooltip\": \"CPU Fan: $FAN_CPU RPM\nWater Pump: $FAN_PUMP RPM\", \"class\": \"custom-fans\"}"
