#!/bin/bash

# Function to send a notification
notify() {
    notify-send -t 3000 -a "Niri Script" "$1" "$2"
}

# Check for dependencies
for cmd in fuzzel swaylock loginctl systemctl notify-send; do
    if ! command -v $cmd &> /dev/null;
    then
        # If notify-send itself is missing, we can't send a notification
        if [ "$cmd" == "notify-send" ]; then
            echo "Warning: 'notify-send' is not installed. Error messages will not be displayed."
        else
            notify "Error" "'$cmd' is not installed."
        fi
        exit 1
    fi
done

# Options for the power menu
options="Lock\nLogout\nReboot\nShutdown"

# Prompt the user to select an option
selected=$(echo -e "$options" | fuzzel --dmenu --prompt="Power Menu: ")

# Execute the selected command
case "$selected" in
    "Lock")
        swaylock -f
        ;;
    "Logout")
        loginctl terminate-session self
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac