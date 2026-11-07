#!/bin/bash

WIN_BOOT=$(efibootmgr | sed -n 's/^Boot\([0-9A-Fa-f]\{4\}\)\* Windows Boot Manager.*/\1/p' | head -n 1)
WIN_BOOT="${WIN_BOOT:-0000}"

if sudo -n /usr/bin/efibootmgr -n "$WIN_BOOT" 2>/dev/null; then
    systemctl reboot
else
    pkexec sh -c "/usr/bin/efibootmgr -n $WIN_BOOT && /usr/bin/systemctl reboot"
fi
