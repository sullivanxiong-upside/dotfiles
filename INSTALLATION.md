# Installation Guide

This guide provides detailed installation instructions for setting up the dotfiles on different platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Component Installation](#component-installation)
  - [Core Shell Configuration](#core-shell-configuration-linux--macos)
  - [CLI Tools (cwf & gwf)](#cli-tools-cwf--gwf-linux--macos)
  - [TMUX Configuration](#tmux-configuration-linux--macos)
  - [Neovim Configuration](#neovim-configuration-linux--macos)
  - [Linux Desktop Environment](#linux-desktop-environment-linux-only)
  - [macOS Specific](#macos-specific-macos-only)
- [Platform-Specific Notes](#platform-specific-notes)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### All Platforms
- Git
- A supported shell: Bash or Zsh

### Platform-Specific

**Linux:**
- Package manager: `pacman` (Arch), `apt` (Debian/Ubuntu), or equivalent
- For desktop environment: Wayland support

**macOS:**
- Homebrew (recommended): https://brew.sh/
- Xcode Command Line Tools: `xcode-select --install`

---

## Quick Start

### 1. Clone the Repository

```bash
# Clone to ~/repos/dotfiles (recommended location)
mkdir -p ~/repos
git clone <your-repo-url> ~/repos/dotfiles
cd ~/repos/dotfiles
```

### 2. Choose Your Installation Method

**Option A: Manual Installation (Recommended)**
Follow the [Component Installation](#component-installation) sections below to install only what you need.

**Option B: Use Install Script (Legacy, Linux-focused)**
> ⚠️ **Note**: The `install.sh` script is primarily designed for Linux and creates symlinks for ALL components. For cross-platform usage or selective installation, manual installation is recommended.

```bash
./install.sh
```

---

## Component Installation

### Core Shell Configuration (Linux & macOS)

#### Bash Configuration

**Dependencies:**
- Bash 4.0+ (macOS ships with old bash 3.2; install newer version via Homebrew)

**Installation:**
```bash
# Symlink .bashrc
ln -sf ~/repos/dotfiles/.bashrc ~/.bashrc

# Source to apply changes
source ~/.bashrc
```

**What's Included:**
- Modular script sourcing from `~/scripts/`
- Aliases for common commands
- Git aliases
- Integration with tmux, neovim, and utility scripts

#### Zsh Configuration

**Dependencies:**
- Zsh 5.0+

**Installation:**
```bash
# Symlink .zprofile
ln -sf ~/repos/dotfiles/.zprofile ~/.zprofile

# Source to apply changes
source ~/.zprofile
```

**What's Included:**
- Clean sourcing order with work-specific config support
- PATH configuration for ~/.local/bin
- Integration with tmux, mermaid, python utilities
- Lazy-loading completions (add completion config to ~/.config/zsh/user.zsh)

---

### CLI Tools (cwf & gwf) (Linux & macOS)

Two powerful CLI tools for workflow automation:
- **cwf** (Claude Workflow CLI): Organize Claude-powered workflows
- **gwf** (Git Workflow CLI): Git operations with worktree management

#### Dependencies

**Required:**
- Bash 4.0+
- Git 2.0+
- `gh` CLI (GitHub CLI) - for gwf PR commands

**Optional:**
- `claude` CLI (Claude Code) - for cwf to work with Claude Code

#### Installation

```bash
# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

# Symlink the scripts
ln -sf ~/repos/dotfiles/scripts/cwf.sh ~/.local/bin/cwf
ln -sf ~/repos/dotfiles/scripts/gwf.sh ~/.local/bin/gwf

# Make executable
chmod +x ~/.local/bin/cwf ~/.local/bin/gwf

# Ensure ~/.local/bin is in PATH (already done in .bashrc/.zprofile)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zprofile

# Install shell completion (optional but recommended)
cwf completion install    # Auto-detects shell and installs
gwf completion install    # Auto-detects shell and installs
```

#### Configuration

**cwf configuration:**
```bash
# Symlink cwf config directory
ln -sf ~/repos/dotfiles/.config/cwf ~/.config/cwf
```

**gwf configuration:**
```bash
# Symlink gwf config directory
ln -sf ~/repos/dotfiles/.config/gwf ~/.config/gwf

# Edit repos.conf to set your repository paths
vim ~/.config/gwf/repos.conf
```

**Claude Code configuration (optional):**
```bash
# Symlink Claude Code settings
mkdir -p ~/.claude
ln -sf ~/repos/dotfiles/.claude/settings.json ~/.claude/settings.json
```

This configures Claude Code to:
- Disable "Co-Authored-By" footers in commits
- Keep commit messages clean and professional

#### Verification

```bash
# Test cwf
cwf --help

# Test gwf
gwf --help

# Test completion (type TAB after typing)
cwf review <TAB>
gwf wt <TAB>
```

---

### TMUX Configuration (Linux & macOS)

#### Dependencies

**Linux:**
```bash
# Arch Linux
sudo pacman -S tmux

# Ubuntu/Debian
sudo apt install tmux
```

**macOS:**
```bash
brew install tmux
```

**Clipboard Support (Linux):**
```bash
# Install xclip for clipboard integration
sudo pacman -S xclip  # Arch
sudo apt install xclip  # Ubuntu/Debian
```

**Clipboard Support (macOS):**
- Uses built-in `pbcopy` (no additional installation needed)

**Plugins:**
- TPM (TMUX Plugin Manager): https://github.com/tmux-plugins/tpm

#### Installation

```bash
# Symlink .tmux.conf
ln -sf ~/repos/dotfiles/.tmux.conf ~/.tmux.conf

# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux and install plugins
tmux new-session -d
tmux source ~/.tmux.conf

# Inside tmux: Press prefix + I (Ctrl+A then I) to install plugins
```

**What's Included:**
- Dracula theme with Catppuccin colors
- OS-specific clipboard integration (pbcopy on macOS, xclip on Linux)
- Vi-style keybindings
- Vim-tmux navigator integration
- Session persistence (resurrect/continuum)
- Weather, battery, and time widgets

---

### Neovim Configuration (Linux & macOS)

#### Dependencies

**Linux:**
```bash
# Arch Linux
sudo pacman -S neovim nodejs npm python-pip ripgrep fd

# Ubuntu/Debian
sudo apt install neovim nodejs npm python3-pip ripgrep fd-find
```

**macOS:**
```bash
brew install neovim node ripgrep fd
```

**Language Servers & Formatters:**
```bash
# Install commonly used formatters
npm install -g prettier
pip install black isort  # Python
cargo install stylua     # Lua (if you have Rust)
```

#### Installation

```bash
# Symlink nvim config directory
ln -sf ~/repos/dotfiles/.config/nvim ~/.config/nvim

# Start nvim - plugins will auto-install via Lazy.nvim
nvim
```

**What's Included:**
- Lazy.nvim plugin manager
- LSP configuration with mason.nvim
- Conform.nvim for formatting with format-on-save
- Todo-comments highlighting
- Telescope fuzzy finder
- Tabby for tab management
- Nvim-surround for text manipulation
- Toggleterm for terminal integration

**Post-Installation:**
1. Open nvim: `nvim`
2. Run `:Lazy sync` to ensure all plugins are installed
3. Run `:Mason` to install language servers
4. Run `:checkhealth` to verify installation

---

### Linux Desktop Environment (Linux Only)

> ⚠️ **Linux Only**: These components are designed for Linux desktop environments, primarily Hyprland on Wayland.

#### Dependencies

**Core Hyprland Setup (Arch Linux):**
```bash
sudo pacman -S hyprland waybar kitty rofi swaync wlogout \
               picom cava fastfetch starship dunst \
               dolphin discord
```

**AUR Packages:**
```bash
yay -S matugen hyprpicker-git
```

**Ubuntu/Debian:**
> Hyprland is not officially packaged for Debian-based distros. Consider using the [Hyprland PPA](https://github.com/hyprland-community/hyprland-ubuntu) or building from source.

#### Installation

```bash
# Symlink entire .config directory (includes all desktop configs)
ln -sf ~/repos/dotfiles/.config ~/.config

# Or selectively symlink specific configs:
ln -sf ~/repos/dotfiles/.config/hypr ~/.config/hypr
ln -sf ~/repos/dotfiles/.config/waybar ~/.config/waybar
ln -sf ~/repos/dotfiles/.config/kitty ~/.config/kitty
ln -sf ~/repos/dotfiles/.config/rofi ~/.config/rofi
ln -sf ~/repos/dotfiles/.config/swaync ~/.config/swaync
# ... and so on
```

**Components Included:**
- **Hyprland**: Wayland compositor with modular configuration
- **Waybar**: Status bar with custom modules
- **Kitty**: Terminal emulator
- **Rofi**: Application launcher
- **SwayNC**: Notification daemon
- **CAVA**: Audio visualizer
- **Picom**: Compositor effects
- **Fastfetch**: System information tool
- **Many more** - see main README.md for full list

---

### macOS Specific (macOS Only)

#### Kitty Terminal

```bash
# Install Kitty
brew install kitty

# Symlink Kitty config
ln -sf ~/repos/dotfiles/.config/kitty ~/.config/kitty

# Launch Kitty
open -a Kitty
```

**Note**: The Kitty config includes transparency settings and font configuration that work best on macOS.

#### macOS Library Preferences

```bash
# Symlink Library preferences (if applicable)
ln -sf ~/repos/dotfiles/Library ~/Library
```

> ⚠️ **Caution**: This may override existing application preferences. Review the contents of `Library/` before symlinking.

---

## Platform-Specific Notes

### Linux

**Display Manager:**
- Ensure your display manager supports Wayland (GDM, SDDM, or LightDM with Wayland support)
- Add Hyprland session to your display manager

**Audio:**
- PipeWire is recommended over PulseAudio for Wayland
- Install `pipewire`, `pipewire-pulse`, `wireplumber`

**Scaling:**
- Hyprland config assumes specific monitor setup (HDMI-A-1, eDP-1)
- Edit `.config/hypr/configs/monitors.conf` to match your displays

### macOS

**Bash Version:**
- macOS ships with Bash 3.2 (2007). Many scripts require Bash 4+
- Install via Homebrew: `brew install bash`
- Add to /etc/shells: `echo /opt/homebrew/bin/bash | sudo tee -a /etc/shells`
- Change default shell: `chsh -s /opt/homebrew/bin/bash`

**TMUX Clipboard:**
- Uses `pbcopy` by default (OS-detected in .tmux.conf)
- No additional setup required

**GNU Utils:**
- Some scripts expect GNU versions of core utilities
- Install via Homebrew: `brew install coreutils findutils gnu-sed`
- Add to PATH or use `g` prefix (e.g., `gsed`, `gfind`)

---

## Troubleshooting

### Scripts Not Found in PATH

**Problem**: Running `cwf` or `gwf` returns "command not found"

**Solution**:
```bash
# Verify symlinks exist
ls -la ~/.local/bin/cwf ~/.local/bin/gwf

# Verify ~/.local/bin is in PATH
echo $PATH | grep '.local/bin'

# If not in PATH, add to shell config
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zprofile
source ~/.bashrc  # or source ~/.zprofile
```

### TMUX Plugins Not Loading

**Problem**: TMUX looks plain, plugins not active

**Solution**:
```bash
# Ensure TPM is installed
ls ~/.tmux/plugins/tpm

# If not, install it
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Inside tmux, press: Ctrl+A then I (uppercase i)
# This installs all plugins listed in .tmux.conf
```

### Neovim Plugins Not Installing

**Problem**: Neovim opens but plugins are missing

**Solution**:
```bash
# Open neovim
nvim

# Run Lazy sync command
:Lazy sync

# Check for errors
:checkhealth lazy

# Manually install if needed
:Lazy install
```

### Completion Not Working

**Problem**: Tab completion doesn't work for cwf/gwf

**Solution**:
```bash
# Verify completion is sourced in shell config
# For Zsh:
grep "cwf completion" ~/.zshrc

# For Bash:
grep "cwf completion" ~/.bashrc

# If not present, install it
cwf completion install
gwf completion install

# Reload shell
exec $SHELL
```

### Permission Denied on Scripts

**Problem**: Scripts fail with "Permission denied"

**Solution**:
```bash
# Make scripts executable
chmod +x ~/repos/dotfiles/scripts/*.sh
chmod +x ~/.local/bin/cwf ~/.local/bin/gwf

# If symlinks are correct, chmod the source files
chmod +x ~/repos/dotfiles/scripts/{cwf.sh,gwf.sh}
```

### Hyprland Won't Start (Linux)

**Problem**: Hyprland fails to start or crashes

**Solution**:
1. Check Hyprland logs: `~/.local/share/hyprland/hyprland.log`
2. Verify GPU drivers are installed
3. Ensure Wayland is enabled in your display manager
4. Test with minimal config: `Hyprland --config /dev/null`
5. Check monitor config matches your setup: `~/.config/hypr/configs/monitors.conf`

---

## Uninstallation

### Remove Symlinks

```bash
# Remove individual symlinks
rm ~/.bashrc ~/.zprofile ~/.tmux.conf
rm ~/.local/bin/cwf ~/.local/bin/gwf
rm ~/.config/nvim ~/.config/cwf ~/.config/gwf

# Remove entire .config symlink (if you symlinked the whole directory)
rm ~/.config
```

### Restore Backups

If you used the `install.sh` script, backups are in `~/.dotfiles_backup_*`:

```bash
# List backups
ls -la ~ | grep dotfiles_backup

# Restore from backup
cp -r ~/.dotfiles_backup_20231223_120000/* ~/
```

---

## Additional Resources

- **cwf Documentation**: `~/repos/dotfiles/scripts/docs/cwf-meta-commands.md`
- **gwf Documentation**: `~/repos/dotfiles/scripts/docs/gwf.md`
- **Completion Setup**: `~/repos/dotfiles/scripts/docs/completion-setup.md`
- **Main README**: `~/repos/dotfiles/README.md`
- **Scripts README**: `~/repos/dotfiles/scripts/README.md`

---

## Getting Help

If you encounter issues not covered here:

1. Check the main README.md for component-specific information
2. Review script documentation in `scripts/docs/`
3. Check logs:
   - Hyprland: `~/.local/share/hyprland/hyprland.log`
   - Waybar: `journalctl --user -u waybar`
   - TMUX: Inside tmux, run `tmux info`
   - Neovim: `:checkhealth` inside nvim

---

**Last Updated**: 2025-12-23
