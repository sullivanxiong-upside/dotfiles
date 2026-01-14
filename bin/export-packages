#!/bin/bash

# Arch Linux Package Export Script
# Exports installed packages in various formats similar to requirements.txt

# Function to show usage
show_usage() {
    echo "Usage: $0 [FORMAT] [OUTPUT_FILE]"
    echo ""
    echo "FORMAT options:"
    echo "  pacman     - Standard pacman format (default)"
    echo "  aur        - AUR packages only"
    echo "  official   - Official repository packages only"
    echo "  minimal    - Minimal essential packages only"
    echo "  all        - All packages with versions"
    echo ""
    echo "OUTPUT_FILE: Optional output file (default: packages-{FORMAT}.txt)"
    echo ""
    echo "Examples:"
    echo "  $0 pacman packages.txt"
    echo "  $0 aur"
    echo "  $0 minimal essential-packages.txt"
}

# Function to export pacman format
export_pacman() {
    local output_file="$1"
    echo "Exporting pacman format to $output_file..."
    pacman -Qe | awk '{print $1 "=" $2}' > "$output_file"
    echo "Exported $(wc -l < "$output_file") packages"
}

# Function to export AUR packages only
export_aur() {
    local output_file="$1"
    echo "Exporting AUR packages to $output_file..."
    pacman -Qm | awk '{print $1 "=" $2}' > "$output_file"
    echo "Exported $(wc -l < "$output_file") AUR packages"
}

# Function to export official repository packages only
export_official() {
    local output_file="$1"
    echo "Exporting official repository packages to $output_file..."
    pacman -Qn | awk '{print $1 "=" $2}' > "$output_file"
    echo "Exported $(wc -l < "$output_file") official packages"
}

# Function to export minimal essential packages
export_minimal() {
    local output_file="$1"
    echo "Exporting minimal essential packages to $output_file..."
    
    # Essential packages that are typically needed
    local essential_packages=(
        "base" "base-devel" "linux" "linux-firmware" "linux-headers"
        "grub" "networkmanager" "openssh" "git" "vim" "neovim"
        "tmux" "starship" "fastfetch" "fzf" "ripgrep" "fd"
        "htop" "tree" "rsync" "wget" "curl" "jq"
    )
    
    # Get installed essential packages
    for pkg in "${essential_packages[@]}"; do
        if pacman -Q "$pkg" &>/dev/null; then
            pacman -Q "$pkg" | awk '{print $1 "=" $2}'
        fi
    done > "$output_file"
    
    echo "Exported $(wc -l < "$output_file") essential packages"
}

# Function to export all packages with detailed info
export_all() {
    local output_file="$1"
    echo "Exporting all packages with detailed info to $output_file..."
    
    {
        echo "# Arch Linux Package List"
        echo "# Generated on: $(date)"
        echo "# Total packages: $(pacman -Q | wc -l)"
        echo ""
        echo "# Official Repository Packages:"
        pacman -Qn | awk '{print $1 "=" $2}'
        echo ""
        echo "# AUR Packages:"
        pacman -Qm | awk '{print $1 "=" $2}'
    } > "$output_file"
    
    echo "Exported detailed package list to $output_file"
}

# Main script logic
main() {
    local format="${1:-pacman}"
    local output_file="$2"
    
    # Set default output file if not provided
    if [[ -z "$output_file" ]]; then
        output_file="packages-${format}.txt"
    fi
    
    case "$format" in
        "pacman")
            export_pacman "$output_file"
            ;;
        "aur")
            export_aur "$output_file"
            ;;
        "official")
            export_official "$output_file"
            ;;
        "minimal")
            export_minimal "$output_file"
            ;;
        "all")
            export_all "$output_file"
            ;;
        "help"|"-h"|"--help")
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown format '$format'"
            show_usage
            exit 1
            ;;
    esac
    
    echo ""
    echo "To install packages from this file:"
    echo "  # For pacman format:"
    echo "  pacman -S --needed \$(cat $output_file | cut -d'=' -f1)"
    echo ""
    echo "  # For AUR packages:"
    echo "  yay -S \$(cat $output_file | cut -d'=' -f1)"
}

# Run main function with all arguments
main "$@"