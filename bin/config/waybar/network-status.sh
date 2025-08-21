#!/bin/bash

# Check if connected to Wi-Fi
if iw dev | grep -q "ssid"; then
    # Get the name of the Wi-Fi interface
    interface=$(iw dev | grep "Interface" | awk '{print $2}')

    # Get the signal strength in dBm
    signal=$(iw dev $interface link | grep "signal" | awk '{print $2}')

    # Convert the signal strength to a percentage
    percentage=$((100 * (100 + signal) / 70))

    echo "$percentage"
else
    echo "Disconnected"
fi