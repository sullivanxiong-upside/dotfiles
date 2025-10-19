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

# Function to bootstrap AUR helper if not available
bootstrap_aur_helper() {
    local helper="${1:-yay}"
    
    if command -v "$helper" &> /dev/null; then
        echo "$helper is already installed"
        return 0
    fi
    
    echo "AUR helper '$helper' not found. Bootstrapping..."
    
    case "$helper" in
        "yay")
            echo "Installing yay from AUR using pacman and git..."
            # Install dependencies first
            echo "Installing dependencies: git, base-devel"
            sudo pacman -S --needed git base-devel
            
            # Clone and build yay
            local original_dir=$(pwd)
            cd /tmp
            if [[ -d "yay" ]]; then
                echo "Removing existing yay directory..."
                rm -rf yay
            fi
            
            echo "Cloning yay from AUR..."
            if ! git clone https://aur.archlinux.org/yay.git; then
                echo "Error: Failed to clone yay repository"
                cd "$original_dir"
                return 1
            fi
            
            cd yay
            echo "Building yay..."
            if ! makepkg -si --noconfirm; then
                echo "Error: Failed to build yay"
                cd "$original_dir"
                return 1
            fi
            
            # Clean up
            cd /tmp
            rm -rf yay
            cd "$original_dir"
            
            # Verify installation
            if command -v yay &> /dev/null; then
                echo "yay successfully installed!"
                yay --version
                return 0
            else
                echo "Error: yay installation completed but command not found"
                return 1
            fi
            ;;
        "paru")
            echo "Installing paru from AUR using pacman and git..."
            # Install dependencies first
            echo "Installing dependencies: git, base-devel, rust"
            sudo pacman -S --needed git base-devel rust
            
            # Clone and build paru
            local original_dir=$(pwd)
            cd /tmp
            if [[ -d "paru" ]]; then
                echo "Removing existing paru directory..."
                rm -rf paru
            fi
            
            echo "Cloning paru from AUR..."
            if ! git clone https://aur.archlinux.org/paru.git; then
                echo "Error: Failed to clone paru repository"
                cd "$original_dir"
                return 1
            fi
            
            cd paru
            echo "Building paru..."
            if ! makepkg -si --noconfirm; then
                echo "Error: Failed to build paru"
                cd "$original_dir"
                return 1
            fi
            
            # Clean up
            cd /tmp
            rm -rf paru
            cd "$original_dir"
            
            # Verify installation
            if command -v paru &> /dev/null; then
                echo "paru successfully installed!"
                paru --version
                return 0
            else
                echo "Error: paru installation completed but command not found"
                return 1
            fi
            ;;
        *)
            echo "Error: Unknown AUR helper '$helper'"
            echo "Supported helpers: yay, paru"
            return 1
            ;;
    esac
}

# Function to install packages from file
install_packages() {
    local package_file="$1"
    local package_manager="${2:-pacman}"
    local dry_run="${3:-false}"
    
    if [[ ! -f "$package_file" ]]; then
        echo "Error: Package file '$package_file' not found"
        return 1
    fi
    
    # Check if package file is empty
    if [[ ! -s "$package_file" ]]; then
        echo "Error: Package file '$package_file' is empty"
        return 1
    fi
    
    echo "Installing packages from $package_file using $package_manager..."
    
    # Validate package file format (should contain package=version format)
    if ! grep -q "=" "$package_file"; then
        echo "Warning: Package file doesn't appear to be in 'package=version' format"
        echo "This might cause installation issues"
    fi
    
    case "$package_manager" in
        "pacman")
            # Extract package names and install them
            local packages=($(cat "$package_file" | cut -d'=' -f1))
            echo "Installing ${#packages[@]} packages..."
            echo "Packages: ${packages[*]}"
            if [[ "$dry_run" == "true" ]]; then
                echo "DRY RUN: Would execute: sudo pacman -S --needed ${packages[*]}"
            else
                sudo pacman -S --needed "${packages[@]}"
            fi
            ;;
        "yay")
            # Bootstrap yay if not available
            if ! command -v yay &> /dev/null; then
                if [[ "$dry_run" == "true" ]]; then
                    echo "DRY RUN: Would bootstrap yay first"
                    echo "DRY RUN: Would then execute: yay -S [packages]"
                    return 0
                else
                    echo "yay not found. Bootstrapping..."
                    if ! bootstrap_aur_helper "yay"; then
                        echo "Error: Failed to bootstrap yay. Cannot install AUR packages."
                        return 1
                    fi
                fi
            fi
            
            # Extract package names and install them
            local packages=($(cat "$package_file" | cut -d'=' -f1))
            echo "Installing ${#packages[@]} packages..."
            echo "Packages: ${packages[*]}"
            if [[ "$dry_run" == "true" ]]; then
                echo "DRY RUN: Would execute: yay -S ${packages[*]}"
            else
                yay -S "${packages[@]}"
            fi
            ;;
        "paru")
            # Bootstrap paru if not available
            if ! command -v paru &> /dev/null; then
                if [[ "$dry_run" == "true" ]]; then
                    echo "DRY RUN: Would bootstrap paru first"
                    echo "DRY RUN: Would then execute: paru -S [packages]"
                    return 0
                else
                    echo "paru not found. Bootstrapping..."
                    if ! bootstrap_aur_helper "paru"; then
                        echo "Error: Failed to bootstrap paru. Cannot install AUR packages."
                        return 1
                    fi
                fi
            fi
            
            # Extract package names and install them
            local packages=($(cat "$package_file" | cut -d'=' -f1))
            echo "Installing ${#packages[@]} packages..."
            echo "Packages: ${packages[*]}"
            if [[ "$dry_run" == "true" ]]; then
                echo "DRY RUN: Would execute: paru -S ${packages[*]}"
            else
                paru -S "${packages[@]}"
            fi
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
        "install-dry")
            install_packages "$1" "$2" "true"
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
            echo "  $0 install-dry PACKAGE_FILE [MANAGER]"
            echo "  $0 info PACKAGE_FILE"
            echo ""
            echo "Export formats: pacman, aur, official, minimal"
            echo "Package managers: pacman, yay, paru"
            echo ""
            echo "Examples:"
            echo "  $0 export minimal essential.txt"
            echo "  $0 install packages-pacman.txt"
            echo "  $0 install packages-aur.txt yay"
            echo "  $0 install-dry packages-pacman.txt pacman"
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