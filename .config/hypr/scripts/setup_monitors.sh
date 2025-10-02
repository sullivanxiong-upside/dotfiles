#!/bin/bash

# Script to automatically configure monitor settings based on detected monitors
# Uses hyprctl monitors to detect the number of active monitors and creates
# symbolic links to the appropriate monitor configuration file

# Configuration paths
CONFIGS_DIR="/home/suxiong/.config/hypr/configs"
MONITORS_CONF="$CONFIGS_DIR/monitors.conf"
SINGLE_MONITORS="$CONFIGS_DIR/single_monitors.conf"
DUAL_MONITORS="$CONFIGS_DIR/dual_monitors.conf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to count active monitors
count_monitors() {
    # Use hyprctl monitors and count the number of "Monitor" lines
    # This gives us the number of active monitors
    hyprctl monitors | grep -c "^Monitor"
}

# Function to create symbolic link
create_symlink() {
    local target="$1"
    local link_name="$2"
    
    # Remove existing symlink or file if it exists
    if [ -L "$link_name" ] || [ -f "$link_name" ]; then
        rm "$link_name"
        print_status "Removed existing $link_name"
    fi
    
    # Create the symbolic link
    ln -s "$target" "$link_name"
    if [ $? -eq 0 ]; then
        print_status "Created symbolic link: $link_name -> $(basename "$target")"
    else
        print_error "Failed to create symbolic link: $link_name -> $target"
        return 1
    fi
}

# Main function
main() {
    print_status "Detecting monitor configuration..."
    
    # Check if hyprctl is available
    if ! command -v hyprctl &> /dev/null; then
        print_error "hyprctl command not found. Make sure Hyprland is running."
        exit 1
    fi
    
    # Count active monitors
    monitor_count=$(count_monitors)
    print_status "Found $monitor_count active monitor(s)"
    
    # Determine which configuration to use
    if [ "$monitor_count" -eq 1 ]; then
        print_status "Single monitor detected, using single_monitors.conf"
        target_config="$SINGLE_MONITORS"
    elif [ "$monitor_count" -eq 2 ]; then
        print_status "Dual monitors detected, using dual_monitors.conf"
        target_config="$DUAL_MONITORS"
    else
        print_warning "Unusual number of monitors detected ($monitor_count). Using dual_monitors.conf as fallback."
        target_config="$DUAL_MONITORS"
    fi
    
    # Check if target configuration file exists
    if [ ! -f "$target_config" ]; then
        print_error "Target configuration file not found: $target_config"
        exit 1
    fi
    
    # Create the symbolic link
    create_symlink "$target_config" "$MONITORS_CONF"
    
    if [ $? -eq 0 ]; then
        print_status "Monitor configuration setup complete!"
        print_status "Current configuration: $(basename "$target_config")"
        
        # Reload Hyprland configuration to apply new monitor settings
        print_status "Reloading Hyprland configuration..."
        hyprctl reload
        
        if [ $? -eq 0 ]; then
            print_status "Hyprland configuration reloaded successfully!"
        else
            print_warning "Failed to reload Hyprland configuration. You may need to restart Hyprland."
        fi
        
        # Show current monitor info
        echo
        print_status "Current monitor setup:"
        hyprctl monitors | grep "^Monitor" | while read -r line; do
            monitor_name=$(echo "$line" | cut -d' ' -f2 | tr -d ':')
            echo "  - $monitor_name"
        done
    else
        print_error "Failed to setup monitor configuration"
        exit 1
    fi
}

# Run the main function
main "$@"
