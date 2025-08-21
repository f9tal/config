
<img width="3200" height="2000" alt="screenshot1" src="https://github.com/user-attachments/assets/84a7d04d-3a7b-4fe2-8328-e3fa9e96642e" />

<img width="3200" height="2000" alt="screenshot2" src="https://github.com/user-attachments/assets/e582f782-85ea-4095-933f-4543d473b5b6" />

<img width="3200" height="2000" alt="screenshot3" src="https://github.com/user-attachments/assets/5d81ccd4-723e-4fb6-8f21-7f09fad6b98c" />



# Welcome

This will attempt to install my preconfigured environment to the target machine.

## Core Components

*   **Compositor:** niri
*   **Status Bar:** Waybar
*   **Launcher:** fuzzel
*   **Notifications:** Mako
*   **Terminal:** Alacritty
*   **Utilities:** swaylock, swayidle, swaybg 
*   **Optional:** swayosd, xwayland-satellite

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
