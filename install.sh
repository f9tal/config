#!/usr/bin/env bash

# --- Script Configuration ---

# Exit immediately if a command exits with a non-zero status.
set -o errexit
# Exit immediately if a pipeline returns a non-zero status.
set -o pipefail
# Treat unset variables as an error when substituting.
set -o nounset

# --- Variables ---
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# List of required packages
dependencies=(
  "niri"
  "waybar"
  "mako"
  "alacritty"
  "swaylock"
  "fuzzel"
  "dconf"
  "swayidle"
  "swaybg"
  "gnome-themes-extra"
  "noto-fonts"
  "noto-fonts-emoji"
  "noto-fonts-cjk"
  "ttf-nerd-fonts-symbols"
  "xdg-desktop-portal-gnome"
  "xdg-desktop-portal-gtk"
)

# List of configurations to copy
configs=(
  "niri"
  "waybar"
  "mako"
  "alacritty"
  "swaylock"
  "fuzzel"
)

# --- Error Handling ---
trap 'echo "[ERROR] An error occurred. Exiting."; exit 1' ERR

# --- Functions ---

# Show the usage message.
usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --check      Check the environment for dependencies and configuration files."
  echo "  --rollback   Roll back the changes made by the script."
  echo "  --help       Show this help message."
  exit 0
}

# Check the environment for dependencies and configuration files.
check_environment() {
  echo "--- Environment Check ---"

  # Check for dependencies
  echo "[INFO] Checking for dependencies..."
  missing_packages=()
  for pkg in "${dependencies[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
      missing_packages+=("$pkg")
    fi
  done

  if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "[INFO] The following packages are missing and would be installed:"
    for pkg in "${missing_packages[@]}"; do
      echo "  - $pkg"
    done
  else
    echo "[INFO] All dependencies are already installed."
  fi

  # Check for configuration files
  echo "[INFO] Checking for configuration files..."
  for config in "${configs[@]}"; do
    dest_dir="$HOME/.config/$config"
    if [ -d "$dest_dir" ]; then
      echo "[INFO] $config configuration is already installed and would be backed up."
    else
      echo "[INFO] $config configuration is not installed and would be copied."
    fi
  done
  echo "--- End of Environment Check ---"
  exit 0
}

# Roll back the changes made by the script.
rollback() {
  echo "--- Rollback ---"

  # Restore configuration files
  echo "[INFO] Restoring configuration files..."
  for config in "${configs[@]}"; do
    dest_dir="$HOME/.config/$config"
    # Find the latest backup
    latest_backup=$(find "$HOME/.config" -name "$config.bak_*" -type d -print0 | xargs -0 ls -td | head -n1)
    if [ -n "$latest_backup" ]; then
      echo "[INFO] Restoring $config configuration from $latest_backup..."
      rm -rf "$dest_dir"
      mv "$latest_backup" "$dest_dir"
    else
        echo "[INFO] No backup found for $config"
    fi
  done

  # Remove installed packages
  read -p "Do you want to remove the installed packages? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[INFO] To remove the packages, please run the following command:"
    echo "sudo pacman -Rns ${dependencies[*]}"
  fi

  # Remove background files
  echo "[INFO] Removing background files..."
  rm -rf "$HOME/.local/share/backgrounds"

  # Remove systemd user services
  echo "[INFO] Disabling and removing systemd user services..."
  systemctl --user stop niri.service swayidle.service swaybg.service mako.service waybar.service || true
  systemctl --user disable niri.service swayidle.service swaybg.service mako.service waybar.service || true
  rm -f "$SYSTEMD_USER_DIR"/swaybg.service
  rm -f "$SYSTEMD_USER_DIR"/swayidle.service
  systemctl --user daemon-reload

  echo "--- Rollback Complete ---"
  exit 0
}

# Safely parse the user configuration file.
parse_config() {
  config_file="$1"
  if [ ! -f "$config_file" ]; then
    echo "[ERROR] Config file not found: $config_file"
    exit 1
  fi

  while IFS='=' read -r key value; do
    # Remove leading/trailing whitespace from key and value
    key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Remove quotes from value
    value=$(echo "$value" | sed 's/"//g')

    # Skip comments and empty lines
    if [[ "$key" =~ ^# ]] || [ -z "$key" ]; then
      continue
    fi

    # Assign to global variables
    case "$key" in
      GTK_THEME) GTK_THEME="$value" ;;
      ICON_THEME) ICON_THEME="$value" ;;
      FONT_NAME) FONT_NAME="$value" ;;
      MONOSPACE_FONT_NAME) MONOSPACE_FONT_NAME="$value" ;;
      SCALING_FACTOR) SCALING_FACTOR="$value" ;;
    esac
  done < "$config_file"
}

# --- Command-line Options ---
if [ $# -gt 0 ]; then
  case "$1" in
    --check)
      check_environment
      ;;
    --rollback)
      rollback
      ;;
    --help)
      usage
      ;;
    *)
      echo "[ERROR] Unknown option: $1"
      usage
      ;;
  esac
fi

# --- Main Script ---

# Sudo check
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Please run as root"
  exit 1
fi

# Confirmation prompt
read -p "This script will install and configure the desktop environment. Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

# --- Dependency Check and Installation ---
echo "[INFO] Checking for dependencies..."

# Check if pacman is available
if ! command -v pacman &>/dev/null; then
  echo "[ERROR] pacman not found. This script is intended for Arch-based distributions."
  exit 1
fi

# Check for and install missing packages
missing_packages=()
for pkg in "${dependencies[@]}"; do
  if ! pacman -Q "$pkg" &>/dev/null; then
    missing_packages+=("$pkg")
  fi
done

if [ ${#missing_packages[@]} -gt 0 ]; then
  echo "[INFO] The following packages are missing: ${missing_packages[*]}. Installing..."
  pacman -S --noconfirm "${missing_packages[@]}"
else
  echo "[INFO] All dependencies are already installed."
fi

# --- User Configuration ---
CONFIG_FILE="$SCRIPT_DIR/config"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[INFO] Creating default config file..."
  cat > "$CONFIG_FILE" << EOL
# --- User Configuration ---

# GTK theme
GTK_THEME="Adwaita-dark"

# Icon theme
ICON_THEME="Adwaita"

# Font
FONT_NAME="Noto Sans 11"

# Monospace font
MONOSPACE_FONT_NAME="Noto Mono 11"

# Scaling factor (e.g., 1.5 for 150%)
# SCALING_FACTOR="1.5"
EOL
fi

parse_config "$CONFIG_FILE"

# --- Backup and Copy Configuration Files ---
echo "[INFO] Backing up existing configurations and copying new ones..."

for config in "${configs[@]}"; do
  src_dir="$SCRIPT_DIR/bin/config/$config"
  dest_dir="$HOME/.config/$config"

  if [ -d "$dest_dir" ]; then
    echo "[INFO] Backing up existing $config configuration to $dest_dir.bak_$(date +%F_%T)"
    mv "$dest_dir" "$dest_dir.bak_$(date +%F_%T)"
  fi

  echo "[INFO] Copying $config configuration..."
  mkdir -p "$HOME/.config"
  cp -r "$src_dir" "$dest_dir"
done

# --- Copy Backgrounds ---
echo "[INFO] Copying background files..."
background_dir="$HOME/.local/share/backgrounds"
if [ ! -d "$background_dir" ]; then
  mkdir -p "$background_dir"
fi
cp -r "$SCRIPT_DIR"/bin/backdrop/* "$background_dir/"

# --- Systemd User Services ---
echo "[INFO] Setting up systemd user services..."
mkdir -p "$SYSTEMD_USER_DIR"

echo "[INFO] Copying service files..."
cp "$SCRIPT_DIR"/bin/service/*.service "$SYSTEMD_USER_DIR/"

echo "[INFO] Reloading systemd daemon..."
systemctl --user daemon-reload

echo "[INFO] Enabling niri services..."
systemctl --user add-wants niri.service swayidle.service
systemctl --user add-wants niri.service swaybg.service
systemctl --user add-wants niri.service mako.service
systemctl --user add-wants niri.service waybar.service

# --- GNOME Settings ---
echo "[INFO] Defining GNOME settings..."
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

# Set GTK theme, icons, and fonts
dconf write /org/gnome/desktop/interface/gtk-theme "'$GTK_THEME'"
dconf write /org/gnome/desktop/interface/icon-theme "'$ICON_THEME'"
dconf write /org/gnome/desktop/interface/font-name "'$FONT_NAME'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'$MONOSPACE_FONT_NAME'"

# Enable fractional scaling for high-DPI displays
dconf write /org/gnome/mutter/experimental-features "['scale-monitor-framebuffer']"

# Set scaling factor (e.g., 1.5 for 150%)
if [ -n "${SCALING_FACTOR:-}" ]; then
  dconf write /org/gnome/desktop/interface/scaling-factor "$SCALING_FACTOR"
fi

# Allow XWayland applications to grab the keyboard
dconf write /org/gnome/mutter/wayland/xwayland-allow-grabs "true"

echo "[SUCCESS] Installation complete!"