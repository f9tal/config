#!/bin/bash

# Change the volume using pamixer
pamixer "$@"

# Get the current volume and mute status
volume=$(pamixer --get-volume)
mute=$(pamixer --get-mute)

# Set the icon and text based on mute status
if [ "$mute" = "true" ]; then
    icon="audio-volume-muted-blocking-symbolic"
    text="Muted"
else
    # Set the icon based on the volume level
    if [ "$volume" -gt 70 ]; then
        icon="audio-volume-high-symbolic"
    elif [ "$volume" -gt 30 ]; then
        icon="audio-volume-medium-symbolic"
    else
        icon="audio-volume-low-symbolic"
    fi
    text="$volume%"
fi

# Send the notification
notify-send -h int:value:$volume -h string:x-canonical-private-synchronous:my-notification -i $icon -t 2000 "$text"
