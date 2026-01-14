# Dotfiles

Personal dotfiles for cross-platform development environments (Linux & macOS).

## Overview

This repository contains configuration files and scripts for productive development workflows across platforms. The configurations emphasize modularity, automation, and consistency.

## Key Features

### 🔧 Core Shell Configuration (Linux & macOS)
- **Bash & Zsh** configurations with modular script sourcing
- **TMUX** with Dracula theme, OS-specific clipboard integration, and persistent sessions
- **Git aliases** and workflow utilities

### 🚀 CLI Workflow Tools (Linux & macOS)
- **cwf** (Claude Workflow CLI): Organize Claude-powered workflows with categories and templates
- **gwf** (Git Workflow CLI): Git operations with intelligent worktree management and PR support
- **Claude Code MCP Integration**: Pre-configured MCP servers
  - Playwright (browser automation)
  - Linear & Notion (workspace integration)
  - GitHub (repository operations)
  - Grafana (AWS Managed Grafana queries, PromQL, CloudWatch Logs)
- **Comprehensive shell completion** for both tools (Bash & Zsh)

### ✏️ Development Environment (Linux & macOS)
- **Neovim** with Lazy.nvim plugin manager
  - LSP support with mason.nvim
  - Format-on-save with conform.nvim
  - Telescope fuzzy finder
  - Todo-comments highlighting
  - Enhanced tab management

### 🖥️ Linux Desktop Environment (Linux Only)
- **Hyprland** Wayland compositor with modular configuration
- **Waybar** status bar with custom modules
- **Rofi** application launcher
- **SwayNC** notification daemon
- **CAVA** audio visualizer
- **Material You** theming with matugen
- **Catppuccin** color scheme throughout

## Quick Start

### 1. Clone the Repository

```bash
mkdir -p ~/repos
git clone <your-repo-url> ~/repos/dotfiles
cd ~/repos/dotfiles
```

### 2. Install Components

See **[INSTALLATION.md](INSTALLATION.md)** for detailed installation instructions.

**For shell configuration only (quick start):**
```bash
# Bash
ln -sf ~/repos/dotfiles/.bashrc ~/.bashrc
source ~/.bashrc

# Zsh
ln -sf ~/repos/dotfiles/.zprofile ~/.zprofile
source ~/.zprofile
```

**For CLI tools (cwf & gwf) and Claude Code:**
```bash
mkdir -p ~/.local/bin ~/.claude
ln -sf ~/repos/dotfiles/scripts/cwf.sh ~/.local/bin/cwf
ln -sf ~/repos/dotfiles/scripts/gwf.sh ~/.local/bin/gwf
ln -sf ~/repos/dotfiles/home/.config/cwf ~/.config/cwf
ln -sf ~/repos/dotfiles/home/.config/gwf ~/.config/gwf
ln -sf ~/repos/dotfiles/.claude/settings.json ~/.claude/settings.json

# Configure MCP servers (see .claude/README.md for details)
claude mcp add --transport stdio --scope user playwright -- npx -y @playwright/mcp@latest
claude mcp add --transport sse --scope user linear https://mcp.linear.app/sse
claude mcp add --transport http --scope user notion https://mcp.notion.com/mcp
claude mcp add --transport stdio --scope user github -- npx -y @modelcontextprotocol/server-github
claude mcp add --transport stdio --scope user grafana-staging -- uv run --directory ~/repos/data-pipelines scripts/grafana_mcp_server/server.py --environment stage
claude mcp add --transport stdio --scope user grafana-prod -- uv run --directory ~/repos/data-pipelines scripts/grafana_mcp_server/server.py --environment prod
```

**For full installation**, see **[INSTALLATION.md](INSTALLATION.md)**.

## Platform Compatibility

| Component | Linux | macOS | Notes |
|-----------|-------|-------|-------|
| **Shell configs** (.bashrc, .zprofile) | ✅ | ✅ | Cross-platform |
| **TMUX** (.tmux.conf) | ✅ | ✅ | OS-specific clipboard auto-detected |
| **tmux-claude-status** | ✅ | ✅ | Requires jq, Claude Code |
| **CLI tools** (cwf, gwf) | ✅ | ✅ | Requires Bash 4.0+ |
| **Neovim** | ✅ | ✅ | Cross-platform |
| **Scripts** (utilities) | ✅ | ✅ | Most are cross-platform |
| **Hyprland** (desktop) | ✅ | ❌ | Linux Wayland only |
| **Waybar, Rofi, etc.** | ✅ | ❌ | Linux desktop tools |
| **Kitty terminal** | ✅ | ✅ | Better support on macOS |

## Component Overview

### Cross-Platform Components

#### Shell Configuration
- **`.bashrc`**: Bash configuration with modular script sourcing
- **`.zprofile`**: Zsh configuration with lazy-loading completion
- **`scripts/`**: Collection of utility scripts
  - `git-aliases.sh`: Enhanced git operations with worktree support
  - `grep-recursive.sh`: Recursive search utilities
  - `python-utility.sh`: Python environment helpers
  - `mermaid-utility.sh`: Mermaid diagram generation

#### CLI Tools
- **`cwf`** (Claude Workflow CLI)
  - Category-based command organization (review, feature, customer-mgmt, etc.)
  - Lazy-loaded template system for performance
  - Self-extending with meta-commands
  - Full documentation: [`scripts/docs/cwf-meta-commands.md`](scripts/docs/cwf-meta-commands.md)

- **`gwf`** (Git Workflow CLI)
  - Organized categories: local, remote, worktree, pr, inspect
  - Intelligent worktree creation with branch auto-detection
  - Repository-specific config file copying
  - Full documentation: [`scripts/docs/gwf.md`](scripts/docs/gwf.md)

#### Terminal Multiplexer
- **`.tmux.conf`**: TMUX configuration with:
  - Dracula theme + Catppuccin colors
  - OS-specific clipboard integration (pbcopy/xclip)
  - Vim-tmux navigator integration
  - Session persistence (resurrect/continuum)
  - Custom keybindings (Ctrl+A prefix)

- **`tmux-claude-status`**: Custom tmux plugin for real-time Claude Code monitoring
  - Displays Claude status in window tabs (`...` = processing, `✔` = ready)
  - Event-driven state tracking using Claude Code's official hooks API
  - Per-window status tracking with instant updates
  - Installed via TPM (Tmux Plugin Manager)
  - Repository: [SullivanXiong/tmux-claude-status](https://github.com/SullivanXiong/tmux-claude-status)

#### Text Editor
- **`.config/nvim/`**: Neovim configuration with:
  - Lazy.nvim plugin manager
  - LSP with mason.nvim for language servers
  - Conform.nvim for formatting (format-on-save)
  - Telescope fuzzy finder with custom ignore patterns
  - Todo-comments with syntax highlighting
  - Tabby for enhanced tab visualization
  - Nvim-surround for text manipulation
  - Toggleterm for integrated terminal

### Linux-Only Components

#### Window Manager & Desktop
- **Hyprland**: Modern Wayland compositor
  - Config location: `.config/hypr/`
  - Modular configuration in `configs/` subdirectory
  - Custom keybindings, animations, and workspaces

#### Status Bar & UI
- **Waybar**: Wayland status bar
  - Config: `.config/waybar/`
  - Custom modules for time, weather, battery, system info
  - Catppuccin-themed CSS

- **Rofi**: Application launcher
  - Config: `.config/rofi/`
  - Custom themes and emoji picker

#### System Utilities
- **SwayNC**: Notification daemon with control center
- **Wlogout**: Graphical logout menu
- **CAVA**: Audio visualizer with GLSL shaders
- **Fastfetch**: System information display
- **Picom**: X11 compositor (for X11 fallback)

#### Theming & Visual
- **Matugen**: Material You color generator
- **GTK**: Themes for GTK 3 and GTK 4
- **Catppuccin Mocha**: Color scheme applied throughout

#### File Management & Apps
- **Dolphin**: KDE file manager
- **Kitty**: GPU-accelerated terminal (better on macOS)
- Various app configs (Discord, Spotify, etc.)

### macOS-Specific Components

- **`Library/`**: macOS application preferences
- **Kitty terminal**: Enhanced terminal emulator (primary terminal for macOS)

## CLI Tool Documentation

### cwf (Claude Workflow CLI)

Unified CLI for Claude-powered workflows:

```bash
# Review code with specific focus
cwf review review-peer "Focus on error handling"

# Work on feature across repositories
cwf feature all "Add user activity tracking"

# Research and learn
cwf agent chat "How do I implement distributed caching?"

# Self-extend: Add new commands
cwf new add-sub-command feature
```

Full documentation: [`scripts/README.md`](scripts/README.md) and [`scripts/docs/cwf-meta-commands.md`](scripts/docs/cwf-meta-commands.md)

### gwf (Git Workflow CLI)

Git wrapper with worktree management:

```bash
# Create review worktree
gwf wt review feature/auth

# Checkout PR for review
gwf pr co 123

# Quick commit and push
gwf l a && gwf l c "Fix bug" && gwf r ps

# Create and push PR
gwf pr push "Add new feature"
```

Full documentation: [`scripts/docs/gwf.md`](scripts/docs/gwf.md)

## Installation

**Detailed Instructions**: See **[INSTALLATION.md](INSTALLATION.md)** for:
- Platform-specific dependency installation
- Component-by-component setup guide
- Configuration and post-installation steps
- Troubleshooting common issues

**Quick Manual Installation**:
```bash
# Core shell config
ln -sf ~/repos/dotfiles/.bashrc ~/.bashrc
ln -sf ~/repos/dotfiles/.zprofile ~/.zprofile

# TMUX
ln -sf ~/repos/dotfiles/.tmux.conf ~/.tmux.conf

# CLI tools
mkdir -p ~/.local/bin
ln -sf ~/repos/dotfiles/scripts/cwf.sh ~/.local/bin/cwf
ln -sf ~/repos/dotfiles/scripts/gwf.sh ~/.local/bin/gwf

# Neovim
ln -sf ~/repos/dotfiles/home/.config/nvim ~/.config/nvim

# Config directories
ln -sf ~/repos/dotfiles/home/.config/cwf ~/.config/cwf
ln -sf ~/repos/dotfiles/home/.config/gwf ~/.config/gwf

# Claude Code settings
mkdir -p ~/.claude
ln -sf ~/repos/dotfiles/.claude/settings.json ~/.claude/settings.json
# MCP servers: See .claude/README.md for setup instructions

# Linux only: Desktop environment
ln -sf ~/repos/dotfiles/home/.config/hypr ~/.config/hypr
ln -sf ~/repos/dotfiles/home/.config/waybar ~/.config/waybar
# ... (see INSTALLATION.md for complete list)
```

## Directory Structure

```
~/repos/dotfiles/
├── .bashrc                      # Bash configuration
├── .zprofile                    # Zsh configuration
├── .tmux.conf                   # TMUX configuration
├── .claude/                     # Claude Code settings
│   ├── settings.json            # Claude Code configuration
│   └── mcp.json                 # MCP server configuration
├── .config/                     # Application configs
│   ├── nvim/                    # Neovim (cross-platform)
│   ├── cwf/               # cwf CLI config (cross-platform)
│   ├── gwf/                     # gwf CLI config (cross-platform)
│   ├── hypr/                    # Hyprland (Linux only)
│   ├── waybar/                  # Waybar (Linux only)
│   ├── rofi/                    # Rofi (Linux only)
│   ├── kitty/                   # Kitty terminal
│   └── ...                      # Many more configs
├── scripts/                     # Utility scripts
│   ├── cwf.sh                   # Claude Workflow CLI
│   ├── gwf.sh                   # Git Workflow CLI
│   ├── git-aliases.sh           # Git utilities
│   ├── grep-recursive.sh        # Search utilities
│   ├── python-utility.sh        # Python helpers
│   ├── mermaid-utility.sh       # Diagram generation
│   ├── docs/                    # Tool documentation
│   └── README.md                # Scripts documentation
├── Library/                     # macOS preferences
├── wallpapers/                  # Desktop wallpapers
├── README.md                    # This file
├── INSTALLATION.md              # Detailed installation guide
└── PACKAGE_MANAGEMENT.md        # Package management guide
```

## Dependencies

### Cross-Platform (Linux & macOS)

**Required:**
- Bash 4.0+ or Zsh 5.0+
- Git 2.0+
- TMUX 3.0+
- Neovim 0.9+

**Recommended:**
- `gh` (GitHub CLI) - for gwf PR commands
- `claude` CLI - for cwf Claude integration
- `ripgrep` - for fast searching
- `fd` - for fast file finding
- Node.js & npm - for Neovim LSP and formatters

### Linux Only

**For Desktop Environment:**
- Hyprland (Wayland compositor)
- Waybar, Rofi, SwayNC, CAVA, Wlogout
- Kitty terminal
- PipeWire (audio system)
- matugen (Material You theming)

**Installation commands** - see [INSTALLATION.md](INSTALLATION.md)

### macOS Only

**For Development:**
- Homebrew
- Xcode Command Line Tools

**Recommended:**
```bash
brew install bash tmux neovim ripgrep fd gh node
```

## Documentation

- **[INSTALLATION.md](INSTALLATION.md)**: Comprehensive installation guide with platform-specific instructions
- **[.claude/README.md](.claude/README.md)**: Claude Code MCP server configuration and management
- **[scripts/README.md](scripts/README.md)**: CLI tools overview and quick reference
- **[scripts/docs/cwf-meta-commands.md](scripts/docs/cwf-meta-commands.md)**: cwf meta-commands for self-extension
- **[scripts/docs/gwf.md](scripts/docs/gwf.md)**: gwf complete usage guide
- **[scripts/docs/completion-setup.md](scripts/docs/completion-setup.md)**: Shell completion setup
- **[scripts/docs/workflow-commands.md](scripts/docs/workflow-commands.md)**: Mid-session mode switching
- **[PACKAGE_MANAGEMENT.md](PACKAGE_MANAGEMENT.md)**: Package management across systems

## Features Highlight

### Intelligent Worktree Management
- Auto-detect existing branches (local/remote)
- Copy repository-specific config files automatically
- Create review and feature worktrees with one command
- Smart cleanup that handles "currently in worktree" edge cases

### Template-Based Workflows
- Lazy-load prompt fragments only when needed
- Shared templates eliminate duplication
- Category-specific rules for contextual behavior
- Self-extending via meta-commands

### OS-Aware Configurations
- TMUX automatically detects OS for clipboard integration (pbcopy/xclip)
- Shell configs work on both Bash and Zsh
- Scripts handle cross-platform differences transparently

### Development Productivity
- Format-on-save in Neovim with LSP fallback
- Organized git workflows with shorthand syntax
- Todo-comments highlighting across the codebase
- Fuzzy finding with intelligent ignore patterns

## Troubleshooting

See **[INSTALLATION.md - Troubleshooting](INSTALLATION.md#troubleshooting)** for common issues and solutions.

Quick checks:
```bash
# Verify CLI tools are in PATH
which cwf gwf

# Test shell config
source ~/.bashrc  # or ~/.zprofile

# Check TMUX plugins
tmux run-shell ~/.tmux/plugins/tpm/tpm

# Verify Neovim setup
nvim +checkhealth
```

## Contributing

This is a personal dotfiles repository, but feel free to:
- Fork and adapt for your own use
- Submit issues for bugs in scripts
- Suggest improvements via pull requests

## License

Personal configuration files - use freely with attribution.

---

**Last Updated**: 2025-12-23
