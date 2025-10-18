#!/bin/bash

# Dotfiles Installation Script
# This script creates symbolic links for all dotfiles to their respective locations in the home directory

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
BACKUP_DIR="$HOME_DIR/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

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

# Function to install dotfiles
install_dotfiles() {
    print_status "Starting dotfiles installation..."
    print_status "Dotfiles directory: $DOTFILES_DIR"
    print_status "Home directory: $HOME_DIR"
    print_status "Backup directory: $BACKUP_DIR"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Array of files/directories to link
    declare -a files_to_link=(
        ".bashrc"
        ".tmux.conf"
        ".config"
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
    
    print_success "Dotfiles installation completed!"
    
    # Show backup information
    if [[ -d "$BACKUP_DIR" && "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        print_status "Backup created at: $BACKUP_DIR"
        print_status "To restore backed up files, run:"
        print_status "  cp -r $BACKUP_DIR/* $HOME_DIR/"
    fi
}

# Function to uninstall dotfiles (remove symlinks and restore backups)
uninstall_dotfiles() {
    print_status "Starting dotfiles uninstallation..."
    
    # Array of files/directories to unlink
    declare -a files_to_unlink=(
        ".bashrc"
        ".tmux.conf"
        ".config"
        "scripts"
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
    
    print_success "Dotfiles uninstallation completed!"
}

# Function to restore from backup
restore_backup() {
    local backup_path="$1"
    
    if [[ -z "$backup_path" ]]; then
        print_error "No backup path provided!"
        print_status "Usage: $0 restore_backup <backup_directory>"
        print_status "Example: $0 restore_backup ~/.dotfiles_backup_20251001_220428"
        return 1
    fi
    
    if [[ ! -d "$backup_path" ]]; then
        print_error "Backup directory $backup_path does not exist!"
        return 1
    fi
    
    print_status "Starting backup restoration..."
    print_status "Backup directory: $backup_path"
    print_status "Target directory: $HOME_DIR"
    
    # Check if backup directory has content
    if [[ ! "$(ls -A "$backup_path" 2>/dev/null)" ]]; then
        print_warning "Backup directory is empty, nothing to restore."
        return 0
    fi
    
    # Array of files/directories to restore
    declare -a files_to_restore=(
        ".bashrc"
        ".tmux.conf"
        ".config"
        "scripts"
    )
    
    # Restore each file/directory
    for file in "${files_to_restore[@]}"; do
        # Try both direct path and full path structure
        local backup_file="$backup_path/$file"
        local backup_file_full="$backup_path$HOME_DIR/$file"
        local target="$HOME_DIR/$file"
        
        # Determine which backup path exists
        local actual_backup_file=""
        if [[ -e "$backup_file" ]]; then
            actual_backup_file="$backup_file"
        elif [[ -e "$backup_file_full" ]]; then
            actual_backup_file="$backup_file_full"
        fi
        
        if [[ -n "$actual_backup_file" ]]; then
            # Remove existing symlink or file
            if [[ -L "$target" || -e "$target" ]]; then
                print_status "Removing existing $target"
                rm -rf "$target"
            fi
            
            # Restore from backup
            print_status "Restoring $target from backup"
            cp -r "$actual_backup_file" "$target"
            
            if [[ $? -eq 0 ]]; then
                print_success "Restored $target from backup"
            else
                print_error "Failed to restore $target"
                return 1
            fi
        else
            print_warning "Backup file for $file not found, skipping..."
        fi
    done
    
    print_success "Backup restoration completed!"
    print_status "Restored files from: $backup_path"
}

# Function to show help
show_help() {
    echo "Dotfiles Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS] [ARGUMENTS]"
    echo ""
    echo "Options:"
    echo "  install, -i              Install dotfiles (create symlinks)"
    echo "  uninstall, -u           Uninstall dotfiles (remove symlinks)"
    echo "  restore_backup, -r      Restore files from backup directory"
    echo "  help, -h                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install              # Install dotfiles"
    echo "  $0 -i                   # Install dotfiles"
    echo "  $0 uninstall            # Uninstall dotfiles"
    echo "  $0 -u                   # Uninstall dotfiles"
    echo "  $0 restore_backup ~/.dotfiles_backup_20251001_220428"
    echo "  $0 -r ~/.dotfiles_backup_20251001_220428"
    echo ""
    echo "Backup Restoration:"
    echo "  The restore_backup option restores files from a backup directory"
    echo "  created during installation. It removes existing symlinks/files"
    echo "  and restores the original files from the backup."
}

# Main script logic
main() {
    case "${1:-install}" in
        "install"|"-i"|"")
            install_dotfiles
            ;;
        "uninstall"|"-u")
            uninstall_dotfiles
            ;;
        "restore_backup"|"-r")
            restore_backup "$2"
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