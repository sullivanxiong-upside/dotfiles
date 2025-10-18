#!/bin/bash

# Work Environment Dotfiles Installation Script
# This script creates symbolic links for work-safe dotfiles configurations
# It excludes work-specific configurations like .bashrc and AWS settings

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
BACKUP_DIR="$HOME_DIR/.dotfiles_work_backup_$(date +%Y%m%d_%H%M%S)"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create backup of existing files
backup_existing() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        print_warning "Backing up existing $target to $BACKUP_DIR"
        mkdir -p "$(dirname "$BACKUP_DIR$target")"
        mv "$target" "$BACKUP_DIR$target"
    fi
}

# Function to create symbolic link
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        print_error "Source file $source does not exist!"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        print_status "Creating directory $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Backup existing file/directory
    backup_existing "$target"
    
    # Create symbolic link
    print_status "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
    
    if [[ $? -eq 0 ]]; then
        print_success "Linked $target -> $source"
    else
        print_error "Failed to create symlink for $target"
        return 1
    fi
}

# Function to install work-safe dotfiles
install_work_dotfiles() {
    print_status "Starting work environment dotfiles installation..."
    print_status "Dotfiles directory: $DOTFILES_DIR"
    print_status "Home directory: $HOME_DIR"
    print_status "Backup directory: $BACKUP_DIR"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Array of work-safe files/directories to link
    declare -a files_to_link=(
        ".tmux.conf"
        "scripts"
    )
    
    # Link each file/directory
    for file in "${files_to_link[@]}"; do
        local source="$DOTFILES_DIR/$file"
        local target="$HOME_DIR/$file"
        
        if [[ -e "$source" ]]; then
            create_symlink "$source" "$target"
        else
            print_warning "File $source not found, skipping..."
        fi
    done
    
    # Link specific .config directories (work-safe only)
    declare -a config_dirs_to_link=(
        "nvim"
        "cursor"
    )
    
    for config_dir in "${config_dirs_to_link[@]}"; do
        local source="$DOTFILES_DIR/.config/$config_dir"
        local target="$HOME_DIR/.config/$config_dir"
        
        if [[ -e "$source" ]]; then
            create_symlink "$source" "$target"
        else
            print_warning "Config directory $source not found, skipping..."
        fi
    done
    
    print_success "Work environment dotfiles installation completed!"
    
    # Show backup information
    if [[ -d "$BACKUP_DIR" && "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        print_status "Backup created at: $BACKUP_DIR"
        print_status "To restore backed up files, run:"
        print_status "  cp -r $BACKUP_DIR/* $HOME_DIR/"
    fi
}

# Function to uninstall work dotfiles (remove symlinks and restore backups)
uninstall_work_dotfiles() {
    print_status "Starting work dotfiles uninstallation..."
    
    # Array of files/directories to unlink
    declare -a files_to_unlink=(
        ".tmux.conf"
        "scripts"
    )
    
    # Array of config directories to unlink
    declare -a config_dirs_to_unlink=(
        "nvim"
        "cursor"
    )
    
    # Remove symlinks
    for file in "${files_to_unlink[@]}"; do
        local target="$HOME_DIR/$file"
        
        if [[ -L "$target" ]]; then
            print_status "Removing symlink: $target"
            rm "$target"
            print_success "Removed symlink: $target"
        elif [[ -e "$target" ]]; then
            print_warning "$target exists but is not a symlink, skipping..."
        fi
    done
    
    # Remove config directory symlinks
    for config_dir in "${config_dirs_to_unlink[@]}"; do
        local target="$HOME_DIR/.config/$config_dir"
        
        if [[ -L "$target" ]]; then
            print_status "Removing config symlink: $target"
            rm "$target"
            print_success "Removed config symlink: $target"
        elif [[ -e "$target" ]]; then
            print_warning "$target exists but is not a symlink, skipping..."
        fi
    done
    
    print_success "Work dotfiles uninstallation completed!"
}

# Function to show help
show_help() {
    echo "Work Environment Dotfiles Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  install, -i              Install work-safe dotfiles (create symlinks)"
    echo "  uninstall, -u           Uninstall work dotfiles (remove symlinks)"
    echo "  help, -h                Show this help message"
    echo ""
    echo "This script only installs work-safe configurations:"
    echo "  - .tmux.conf"
    echo "  - scripts/ (excluding work/ directory)"
    echo "  - .config/nvim/"
    echo "  - .config/cursor/"
    echo ""
    echo "It excludes work-specific configurations like:"
    echo "  - .bashrc (keeps original work environment)"
    echo "  - AWS VPN configurations"
    echo "  - Other work-specific .config directories"
}

# Main script logic
main() {
    case "${1:-install}" in
        "install"|"-i"|"")
            install_work_dotfiles
            ;;
        "uninstall"|"-u")
            uninstall_work_dotfiles
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
