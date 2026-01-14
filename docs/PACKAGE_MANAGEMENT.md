# Arch Linux Package Management

This directory contains scripts for managing Arch Linux packages in a requirements.txt-like format.

## Quick Start

### Export Packages

```bash
# Export all explicitly installed packages
pkg-export pacman

# Export only AUR packages
pkg-export-aur

# Export only official repository packages
pkg-export-official

# Export minimal essential packages
pkg-export-minimal

# Export to specific file
pkg-export pacman my-packages.txt
```

### Install Packages

```bash
# Install from package file using pacman
pkg-install packages-pacman.txt

# Install AUR packages using yay
pkg-install packages-aur.txt yay

# Install using paru
pkg-install packages-aur.txt paru
```

### Get Package Info

```bash
# Show information about a package file
pkg-info packages-minimal.txt
```

## Available Formats

### `pacman` (default)
- Exports all explicitly installed packages
- Format: `package-name=version`
- Use with: `pacman -S --needed $(cat file.txt | cut -d'=' -f1)`

### `aur`
- Exports only AUR packages
- Format: `package-name=version`
- Use with: `yay -S $(cat file.txt | cut -d'=' -f1)`

### `official`
- Exports only official repository packages
- Format: `package-name=version`
- Use with: `pacman -S --needed $(cat file.txt | cut -d'=' -f1)`

### `minimal`
- Exports only essential packages
- Includes: base, base-devel, linux, git, vim, neovim, tmux, etc.
- Format: `package-name=version`

## File Structure

```
scripts/
├── package-manager.sh    # Main package management script
├── export-packages.sh    # Simple export script (legacy)
└── bash-aliases.sh       # Contains package management aliases
```

## Examples

### Backup Your System
```bash
# Export all packages
pkg-export pacman system-backup.txt

# Export only AUR packages
pkg-export-aur aur-backup.txt
```

### Restore on New System
```bash
# Install official packages
pkg-install system-backup.txt

# Install AUR packages
pkg-install aur-backup.txt yay
```

### Share Minimal Setup
```bash
# Export minimal essential packages
pkg-export-minimal essential.txt

# Share the file and install on another system
pkg-install essential.txt
```

## Integration with Dotfiles

The package management aliases are automatically loaded when you source your `.bashrc`:

```bash
# These aliases are available after sourcing .bashrc
pkg-export
pkg-install
pkg-info
pkg-export-minimal
pkg-export-aur
pkg-export-official
```

## Advanced Usage

### Custom Package Lists
You can create custom package lists by editing the `essential_packages` array in the script:

```bash
# Edit the script to add your custom packages
vim scripts/package-manager.sh
```

### Batch Operations
```bash
# Export multiple formats at once
for format in pacman aur official minimal; do
    pkg-export $format packages-$format.txt
done
```

### Integration with Git
```bash
# Track your package lists in git
git add packages-*.txt
git commit -m "Update package lists"
```

## Troubleshooting

### Permission Issues
Make sure the scripts are executable:
```bash
chmod +x scripts/*.sh
```

### Package Not Found
If a package is not found during installation, check if it's available in the repositories:
```bash
pacman -Ss package-name
yay -Ss package-name
```

### AUR Packages
AUR packages require an AUR helper like `yay` or `paru`:
```bash
# Install yay
sudo pacman -S yay

# Install paru
yay -S paru
```