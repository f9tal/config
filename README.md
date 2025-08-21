# Desktop Environment

This will attempt to install my preconfigured environment to the target machine.

## Core Components

*   **Compositor:** niri
*   **Status Bar:** Waybar
*   **Launcher:** fuzzel
*   **Notifications:** Mako
*   **Terminal:** Alacritty
*   **Utilities:** swaylock, swayidle, swaybg

## Installation

To install, run the following command with root privileges:

```bash
sudo ./install.sh
```

## Usage

The script provides the following options for safe management:

*   `--check`: Perform a dry run to see what changes will be made.
*   `--rollback`: Revert the system to its previous state using the latest backup.
*   `--help`: Display the help message.

## Configuration

All application settings are located in their respective directories within `~/.config/`. Global theme and font settings can be adjusted in the `config` file in this repository before installation.
