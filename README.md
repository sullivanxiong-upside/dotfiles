# Dotfiles

My personal dotfiles configuration for a Linux desktop environment with Hyprland window manager.

## Overview

This repository contains configuration files for various applications and tools used in my Linux desktop setup. The configurations are organized in the `.config` directory following the XDG Base Directory specification.

## Package List and Configuration Directories

### Window Manager & Desktop Environment
- **Hyprland** - Wayland compositor
  - Configuration: `.config/hypr/`
  - Main config: `hyprland.conf`
  - Sub-configs: `configs/` directory with modular configuration files

### Status Bar & System Information
- **Waybar** - Wayland status bar
  - Configuration: `.config/waybar/`
  - Main config: `config`
  - Modules: `modules.json`, `modules_workspaces.json`, `modules_custom.json`, `modules_groups.json`
  - Styles: `style.css`

- **Fastfetch** - System information tool
  - Configuration: `.config/fastfetch/`
  - Main config: `config.jsonc`
  - Small config: `small_config.jsonc`

### Terminal & Shell
- **Kitty** - Terminal emulator
  - Configuration: `.config/kitty/`
  - Main config: `kitty.conf`

- **Bash** - Shell configuration
  - Configuration: `.bashrc` (root directory)
  - Features: tmux integration, aliases, starship prompt

- **Starship** - Cross-shell prompt
  - Configuration: `.config/starship.toml`
  - Theme: Catppuccin Mocha palette

- **TMUX** - Terminal multiplexer
  - Auto-started sessions: `main` and `time`
  - Integrated with bash configuration

### Application Launcher & Menus
- **Rofi** - Application launcher
  - Configuration: `.config/rofi/`
  - Main config: `config.rasi`
  - Colors: `colors.rasi`
  - Features: emoji picker, calculator

### Notifications & System Control
- **SwayNC** - Notification daemon
  - Configuration: `.config/swaync/`
  - Main config: `config.json`
  - Styles: `style.css`, `themes/` directory
  - Control center with power management

- **Wlogout** - Logout menu
  - Configuration: `.config/wlogout/`
  - Layout: `layout`
  - Styles: `style.css`

### Audio & Visual
- **CAVA** - Audio visualizer
  - Configuration: `.config/cava/`
  - Main config: `config`
  - Shaders: `shaders/` directory (GLSL shaders)

- **Picom** - Compositor
  - Configuration: `.config/picom/`
  - Main config: `picom.conf`
  - Features: transparency, shadows

### File Management
- **Dolphin** - File manager
  - Configuration: `.config/dolphinrc`
  - KDE file manager integration

### Development Tools
- **Neovim** - Text editor
  - Configuration: `.config/nvim/`
  - Main config: `init.lua`
  - Lazy plugin manager setup

- **Cursor** - AI-powered editor
  - Configuration: `.config/cursor/`
  - Auth: `auth.json`
  - History: `prompt_history.json`

### System & Network
- **ProtonVPN** - VPN client
  - Configuration: `.config/protonvpn/`
  - Login config: `login.conf`

- **WayVNC** - VNC server for Wayland
  - Configuration: `.config/wayvnc/`

- **TigerVNC** - VNC client
  - Configuration: `.config/tigervnc/`

### Applications
- **Discord** - Chat application
  - Configuration: `.config/discord/`
  - Extensive module configuration

- **Spotify** - Music streaming (via Spicetify)
  - Configuration: `.config/spicetify/`
  - Main config: `config.ini`

### System Integration
- **Matugen** - Material You color generator
  - Configuration: `.config/matugen/`
  - CSS themes and configuration files

- **GTK** - GUI toolkit
  - Configuration: `.config/gtk-3.0/`, `.config/gtk-4.0/`
  - Themes and CSS customization

- **User Directories** - XDG user directories
  - Configuration: `.config/user-dirs.dirs`, `.config/user-dirs.locale`

- **DConf** - GNOME configuration system
  - Configuration: `.config/dconf/`
  - User settings: `user`

- **GNOME Session** - Session management
  - Configuration: `.config/gnome-session/`

- **IBus** - Input method framework
  - Configuration: `.config/ibus/`

- **KDE** - Desktop environment components
  - Configuration: `.config/kde.org/`
  - Settings: `kdeglobals.conf`

- **MIME Applications** - File type associations
  - Configuration: `.config/mimeapps.list`

- **Monitors** - Display configuration
  - Configuration: `.config/monitors.xml`

- **Session Management** - Application session data
  - Configuration: `.config/session/`

- **SystemD** - System service management
  - Configuration: `.config/systemd/`

- **Procps** - Process utilities
  - Configuration: `.config/procps/`

### Package Management
- **Yay** - AUR helper
  - Configuration: `.config/yay/`

### Additional Tools
- **Qalculate** - Calculator
  - Configuration: `.config/qalculate/`
  - Settings: `qalculate.cfg`
  - History: `qalculate.history`

- **EasyEffects** - Audio effects
  - Configuration: `.config/easyeffects/`

- **Evolution** - Email client
  - Configuration: `.config/evolution/`

- **Epiphany** - Web browser
  - Configuration: `.config/epiphany/`

- **Totem** - Video player
  - Configuration: `.config/totem/`

- **Nautilus** - File manager (GNOME)
  - Configuration: `.config/nautilus/`

- **FLTK** - GUI toolkit
  - Configuration: `.config/fltk.org/`
  - Preferences: `fluid.prefs`, `fltk.prefs`

- **Go** - Programming language
  - Configuration: `.config/go/`
  - Module cache and settings

- **Matplotlib** - Python plotting library
  - Configuration: `.config/matplotlib/`

- **NextJS/NodeJS** - JavaScript runtime
  - Configuration: `.config/nextjs-nodejs/`
  - Settings: `config.json`

- **PulseAudio** - Audio system
  - Configuration: `.config/pulse/`

- **Electron** - Desktop app framework
  - Configuration: `.config/Electron/`

- **Goa** - GNOME Online Accounts
  - Configuration: `.config/goa-1.0/`

- **Trash** - File deletion management
  - Configuration: `.config/trashrc`

- **Yelp** - Help system
  - Configuration: `.config/yelp/`
  - Settings: `yelp.cfg`

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Create symbolic links to your home directory:
   ```bash
   # For .config directory
   ln -sf ~/dotfiles/.config ~/.config
   
   # For individual .config directory
   ln -sf ~/dotfiles/.config/[dir] ~/.config/[dir]
   
   # For .bashrc
   ln -sf ~/dotfiles/.bashrc ~/.bashrc
   ```

3. Install required packages (Arch Linux):
   ```bash
   # Core packages
   sudo pacman -S hyprland waybar kitty rofi swaync picom cava fastfetch starship tmux
   
   # Additional packages
   sudo pacman -S dolphin discord spotify neovim waybar
   
   # AUR packages
   yay -S matugen
   ```

## Features

- **Hyprland** window manager with modular configuration
- **Catppuccin** color scheme throughout
- **Material You** dynamic theming with matugen
- **Audio visualization** with CAVA
- **System monitoring** with Waybar and Fastfetch
- **Development environment** with Neovim and Cursor
- **VPN integration** with ProtonVPN
- **Remote access** with VNC support

## Wallpapers

The `wallpapers/` directory contains various wallpapers including anime-themed images and custom designs.

## Notes

- This configuration is optimized for Arch Linux
- The configuration assumes a dual-monitor setup (HDMI-A-1 and eDP-1)
- TMUX sessions are automatically started and managed
- The setup includes both Wayland (Hyprland) and X11 compatibility where needed
