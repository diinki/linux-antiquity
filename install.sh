#!/usr/bin/env bash

set -e
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

USERNAME=$(whoami)
BACKUP_DIR="$HOME/${USERNAME}_BACKUPS"
CONFIG_DIR="$HOME/.config"
THEME_CONFIGS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/configs"

DEPS=("hyprpaper" "nemo" "kitty" "quickshell" "hyprshot" "mako" "jq" "socat")
WINDOW_MANAGER="Hyprland"

print_txt() {
    echo -e "${2}${1}${NC}"
}


echo "
"
print_txt "【 Welcome to the Linux Antiquity installation/update Process. 】" "$GREEN"
print_txt " _________________________________________" "$GREEN"


echo
print_txt "Verifiying existence of dependencies..." "$YELLOW"

# The entire theme is built around Hyprland, so check for it before anything else.
if command -v "$WINDOW_MANAGER" >/dev/null 2>&1 ; then
    print_txt "✓ $WINDOW_MANAGER - Found." "$GREEN"
else
    print_txt "✗ $WINDOW_MANAGER - Not Found!" "$RED"
    print_txt "Linux Antiquity is a Hyprland theme and won't work without it." "$RED"
    print_txt "Install Hyprland first (https://wiki.hypr.land/Getting-Started/Installation/), then run this script again." "$RED"
    exit 1
fi

missing_deps=()

# Best way to do this? Unsure if this has high compat
for dep in "${DEPS[@]}"; do
    if command -v "$dep" >/dev/null 2>&1 ; then
        print_txt "✓ $dep - Found." "$GREEN"
    else
        missing_deps+=("$dep")
        print_txt "✗ $dep - Not Found!" "$RED"
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo
    print_txt "Missing dependencies: ${missing_deps[*]}" "$RED"
    print_txt "Please install the required dependencies, and then run this script again." "$RED"
    
    # Some hints bcz we're nice.
    if command -v apt &> /dev/null; then
        print_txt "Hint: sudo apt install ${missing_deps[*]}" "$YELLOW"
    elif command -v pacman &> /dev/null; then
        print_txt "Hint: sudo pacman -S ${missing_deps[*]}" "$YELLOW"
    fi
    
    exit 1
fi

if [ ! -d "$THEME_CONFIGS" ]; then
    print_txt "Error: Corrupt repository! '$THEME_CONFIGS' not found! Please re-install Antiquity. Exiting." "$RED"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo
print_txt "Copying configs for programs..." "$YELLOW"

# A bit messy, here we copy all config dirs and also detect if we need to create a backup of something.
for dir in "$THEME_CONFIGS"/*/ ; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        target_dir="$CONFIG_DIR/$dirname"
        
        # Create backup if a directory already exists.
        if [ -d "$target_dir" ]; then
            backup_target="$BACKUP_DIR/$dirname"
            print_txt "Backing up existing $dirname to $backup_target" "$YELLOW"
            
            # Append timestamp to backup, in case of multiple backups existing.
            if [ -d "$backup_target" ]; then
                timestamp=$(date +"%Y%m%d_%H%M%S")
                backup_target="${backup_target}_${timestamp}"
            fi
            
            mv "$target_dir" "$backup_target"
            print_txt "✓ Backed up $dirname" "$GREEN"
        fi
        
        # Copy config.
        cp -r "$dir" "$target_dir"
        print_txt "✓ Copied $dirname to ~/.config/" "$GREEN"
    fi
done

echo
print_txt "All configurations have been installed to ~/.config/" "$GREEN"
print_txt "Make sure to move the icon theme manually to ~/.local/share/icons if you want to use the provided icon theme." "$GREEN"

if [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    print_txt "Backups of existing files have been created in: $BACKUP_DIR" "$YELLOW"
fi

echo
print_txt "_____________________________________________________________________________" "$NC"
echo
print_txt "Successfully installed/updated Linux Antiquity v0.1" "$GREEN"
print_txt "It's recommended to restart your computer to ensure all changes take effect if this is your first time." "$NC"
print_txt "Quickshell UI will be launched on-start." "$NC"
print_txt "_____________________________________________________________________________" "$NC"