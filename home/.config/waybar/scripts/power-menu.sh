#!/bin/bash

# Define options
shutdown=" Shutdown"
reboot=" Reboot"
lock=" Lock"
suspend=" Suspend"
logout=" Logout"

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | rofi -dmenu -i -p \"Power Menu\")"

case $chosen in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $lock)
        loginctl lock-session
        ;;
    $suspend)
        systemctl suspend
        ;;
    $logout)
        uwsm stop
        ;;
esac
