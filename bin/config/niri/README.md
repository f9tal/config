# Niri Configuration

This directory contains the configuration for the Niri window manager.

## Custom Scripts

This configuration uses several custom scripts to extend Niri's functionality:

*   `scripts/brightness.sh`: Adjusts the screen brightness. It automatically detects the correct device.
*   `scripts/kbd-brightness.sh`: Adjusts the keyboard backlight brightness. It automatically detects the correct device.
*   `scripts/power-menu.sh`: Displays a power menu using `fuzzel` for locking, logging out, rebooting, and shutting down.
*   `scripts/reload-waybar.sh`: Reloads the Waybar status bar.

## Keybindings

This configuration uses a number of custom keybindings. See the `binds` section of `config.kdl` for a full list.
