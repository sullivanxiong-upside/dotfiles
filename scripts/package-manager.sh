#!/bin/bash

# Arch Linux Package Management Script
# Provides functions for exporting and installing packages

# Function to export packages
export_packages() {
    local format="${1:-pacman}"
    local output_file="$2"
    
    # Set default output file if not provided
    if [[ -z "$output_file" ]]; then
        output_file="packages-${format}.txt"
    fi
    
    case "$format" in
        "pacman")
            echo "Exporting all explicitly installed packages..."
            pacman -Qe | awk '{print $1 "=" $2}' > "$output_file"
            echo "Exported $(wc -l < "$output_file") packages to $output_file"
            ;;
        "aur")
            echo "Exporting AUR packages..."
            pacman -Qm | awk '{print $1 "=" $2}' > "$output_file"
            echo "Exported $(wc -l < "$output_file") AUR packages to $output_file"
            ;;
        "official")
            echo "Exporting official repository packages..."
            pacman -Qn | awk '{print $1 "=" $2}' > "$output_file"
            echo "Exported $(wc -l < "$output_file") official packages to $output_file"
            ;;
        "minimal")
            echo "Exporting minimal essential packages..."
            local essential_packages=(
                "base" "base-devel" "linux" "linux-firmware" "linux-headers"
                "grub" "networkmanager" "openssh" "git" "vim" "neovim"
                "tmux" "starship" "fastfetch" "fzf" "ripgrep" "fd"
                "htop" "tree" "rsync" "wget" "curl" "jq"
            )
            
            for pkg in "${essential_packages[@]}"; do
                if pacman -Q "$pkg" &>/dev/null; then
                    pacman -Q "$pkg" | awk '{print $1 "=" $2}'
                fi
            done > "$output_file"
            echo "Exported $(wc -l < "$output_file") essential packages to $output_file"
            ;;
        *)
            echo "Error: Unknown format '$format'"
            echo "Available formats: pacman, aur, official, minimal"
            return 1
            ;;
    esac
}

# Function to install packages from file
install_packages() {
    local package_file="$1"
    local package_manager="${2:-pacman}"
    
    if [[ ! -f "$package_file" ]]; then
        echo "Error: Package file '$package_file' not found"
        return 1
    fi
    
    echo "Installing packages from $package_file using $package_manager..."
    
    case "$package_manager" in
        "pacman")
            local packages=$(cat "$package_file" | cut -d'=' -f1 | tr '\n' ' ')
            echo "Installing: $packages"
            sudo pacman -S --needed $packages
            ;;
        "yay")
            local packages=$(cat "$package_file" | cut -d'=' -f1 | tr '\n' ' ')
            echo "Installing: $packages"
            yay -S $packages
            ;;
        "paru")
            local packages=$(cat "$package_file" | cut -d'=' -f1 | tr '\n' ' ')
            echo "Installing: $packages"
            paru -S $packages
            ;;
        *)
            echo "Error: Unknown package manager '$package_manager'"
            echo "Available managers: pacman, yay, paru"
            return 1
            ;;
    esac
}

# Function to show package info
show_package_info() {
    local package_file="$1"
    
    if [[ ! -f "$package_file" ]]; then
        echo "Error: Package file '$package_file' not found"
        return 1
    fi
    
    echo "Package file: $package_file"
    echo "Total packages: $(wc -l < "$package_file")"
    echo ""
    echo "First 10 packages:"
    head -10 "$package_file"
    echo ""
    echo "Last 10 packages:"
    tail -10 "$package_file"
}

# Main function for command line usage
main() {
    local command="$1"
    shift
    
    case "$command" in
        "export")
            export_packages "$@"
            ;;
        "install")
            install_packages "$@"
            ;;
        "info")
            show_package_info "$@"
            ;;
        "help"|"-h"|"--help")
            echo "Arch Linux Package Manager"
            echo ""
            echo "Usage:"
            echo "  $0 export [FORMAT] [OUTPUT_FILE]"
            echo "  $0 install PACKAGE_FILE [MANAGER]"
            echo "  $0 info PACKAGE_FILE"
            echo ""
            echo "Export formats: pacman, aur, official, minimal"
            echo "Package managers: pacman, yay, paru"
            echo ""
            echo "Examples:"
            echo "  $0 export minimal essential.txt"
            echo "  $0 install packages-pacman.txt"
            echo "  $0 install packages-aur.txt yay"
            ;;
        *)
            echo "Error: Unknown command '$command'"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# If script is run directly (not sourced), execute main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi