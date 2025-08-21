#!/bin/bash

# Function to send a notification
notify() {
    notify-send -t 3000 -a "Niri Script" "$1" "$2"
}

# Check for dependencies
if ! command -v brightnessctl &> /dev/null; then
    notify "Error" "'brightnessctl' is not installed."
    exit 1
fi

if ! command -v notify-send &> /dev/null; then
    echo "Warning: 'notify-send' is not installed. Error messages will not be displayed."
fi

# Find the first available keyboard brightness device
device=$(brightnessctl -l -m | grep "kbd_backlight" | head -n 1 | cut -d ',' -f 1)

if [ -z "$device" ]; then
    notify "Error" "No keyboard brightness device found."
    exit 1
fi

# Adjust brightness based on argument
case "$1" in
    up)
        brightnessctl --device="$device" set "+1"
        ;;
    down)
        brightnessctl --device="$device" set "1-"
        ;;
    *)
        notify "Script Error" "Usage: kbd-brightness.sh {up|down}"
        exit 1
        ;;
esac