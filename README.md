# Dotfiles

Personal dotfiles for cross-platform development environments (Linux & macOS).

## Overview

This repository contains configuration files and scripts for productive development workflows across platforms. The configurations emphasize modularity, automation, and consistency.

## Key Features

### Core Shell Configuration (Linux & macOS)
- **Bash & Zsh** configurations with modular script sourcing
- **TMUX** with Dracula theme, OS-specific clipboard integration, and persistent sessions
- **Git aliases** and workflow utilities

### CLI Workflow Tools (Linux & macOS)
- **cwf** (Claude Workflow CLI): Organize Claude-powered workflows with categories and templates
- **gwf** (Git Workflow CLI): Git operations with intelligent worktree management and PR support
- **Built-in shell completion** for both tools (Bash & Zsh)
  - Run `gwf completion install` and `cwf completion install` after copying to ~/.local/bin
  - Completion scripts are dynamically generated - no separate files needed
- **Claude Code MCP Integration**: Pre-configured MCP servers
  - Playwright (browser automation)
  - Linear & Notion (workspace integration)
  - GitHub (repository operations)
  - Grafana (AWS Managed Grafana queries, PromQL, CloudWatch Logs)

### Development Environment (Linux & macOS)
- **Neovim** with Lazy.nvim plugin manager
  - LSP support with mason.nvim
  - Format-on-save with conform.nvim
  - Telescope fuzzy finder
  - Todo-comments highlighting
  - Enhanced tab management

### Linux Desktop Environment (Linux Only)
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

### 2. Configure Secrets

**IMPORTANT**: Set up your secret environment variables before using MCP servers that require API keys.

```bash
# Copy the template
cp ~/repos/dotfiles/home/.config/zsh/secret.template.zsh ~/.config/zsh/secret.zsh

# Edit and add your actual API keys
vim ~/.config/zsh/secret.zsh

# The file is automatically gitignored - never commit it!
```

**Required secrets for MCP servers:**
- `FIREFLIES_API_KEY` - Get from https://fireflies.ai/api

See the **[Secret Management](#secret-management)** section below for details.

### 3. Install Components

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
mkdir -p ~/.local/bin ~/.claude ~/.claude/commands

# CLI tools (symlink to bin/ in dotfiles repo)
ln -sf ~/repos/dotfiles/bin/cwf ~/.local/bin/cwf
ln -sf ~/repos/dotfiles/bin/gwf ~/.local/bin/gwf

# CLI tool configs
ln -sf ~/repos/dotfiles/home/.config/cwf ~/.config/cwf
ln -sf ~/repos/dotfiles/home/.config/gwf ~/.config/gwf

# Install shell completion (auto-detects bash/zsh)
gwf completion install
cwf completion install
source ~/.zshrc  # or source ~/.bashrc to activate

# Claude Code settings
ln -sf ~/repos/dotfiles/home/.claude/settings.json ~/.claude/settings.json

# Symlink Claude Code skills
ln -sf ~/repos/dotfiles/home/.claude/commands/capture-knowledge.md ~/.claude/commands/capture-knowledge.md

# Configure MCP servers - merge template into ~/.claude.json
# IMPORTANT: Claude Code reads MCP servers from ~/.claude.json, NOT from a separate mcp.json file.
# The mcp.json.template file in this repo is ONLY a template - it must be merged into ~/.claude.json.
jq --argjson mcp "$(cat ~/repos/dotfiles/home/.claude/mcp.json.template | jq .)" \
   '. + $mcp' ~/.claude.json > ~/.claude.json.tmp && \
   mv ~/.claude.json.tmp ~/.claude.json

# Verify MCP servers loaded
claude mcp list
```

**For full installation**, see **[INSTALLATION.md](INSTALLATION.md)**.

## Platform Compatibility

| Component | Linux | macOS | Notes |
|-----------|-------|-------|-------|
| **Shell configs** (.bashrc, .zprofile) | Yes | Yes | Cross-platform |
| **TMUX** (.tmux.conf) | Yes | Yes | OS-specific clipboard auto-detected |
| **tmux-claude-status** | Yes | Yes | Requires jq, Claude Code |
| **CLI tools** (cwf, gwf) | Yes | Yes | Requires Bash 4.0+ |
| **Neovim** | Yes | Yes | Cross-platform |
| **Scripts** (utilities) | Yes | Yes | Most are cross-platform |
| **Hyprland** (desktop) | Yes | No | Linux Wayland only |
| **Waybar, Rofi, etc.** | Yes | No | Linux desktop tools |
| **Kitty terminal** | Yes | Yes | Better support on macOS |

## Component Overview

### Cross-Platform Components

#### Shell Configuration
- **`.bashrc`**: Bash configuration with modular script sourcing
- **`.zprofile`**: Zsh configuration with lazy-loading completion
- **`bin/`**: Collection of utility scripts
  - `git-aliases`: Enhanced git operations with worktree support
  - `grep-recursive`: Recursive search utilities
  - `cursor-agent`: Wrapper for cursor-agent with .cursor/rules support
  - Various utilities for platform detection and package management

#### CLI Tools
- **`cwf`** (Claude Workflow CLI)
  - Category-based command organization (review, feature, customer-mgmt, etc.)
  - Lazy-loaded template system for performance
  - Self-extending with meta-commands
  - Built-in shell completion (run `cwf completion install`)
  - Full documentation: [`docs/cwf-meta-commands.md`](docs/cwf-meta-commands.md)

- **`gwf`** (Git Workflow CLI)
  - Organized categories: local, remote, worktree, pr, inspect
  - Intelligent worktree creation with branch auto-detection
  - Repository-specific config file copying
  - Built-in shell completion (run `gwf completion install`)
  - Full documentation: [`docs/gwf.md`](docs/gwf.md)
  - Sharing guide: [`docs/GWF_SHARING_GUIDE.md`](docs/GWF_SHARING_GUIDE.md)

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
- **`home/.config/nvim/`**: Neovim configuration with:
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

# Improve workflows and rules
cwf new improve-workflows
cwf new improve-rules

# Add/improve personal repo operational knowledge
cwf new improve-repo-knowledge

# Install shell completion
cwf completion install
```

**Installation**: Copy `bin/cwf` to `~/.local/bin/cwf`, then run `cwf completion install`

Full documentation: [`docs/cwf-meta-commands.md`](docs/cwf-meta-commands.md)

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

# Install shell completion
gwf completion install
```

**Installation**: Copy `bin/gwf` to `~/.local/bin/gwf`, then run `gwf completion install`

Full documentation:
- [`docs/gwf.md`](docs/gwf.md) - Complete command reference
- [`docs/GWF_SHARING_GUIDE.md`](docs/GWF_SHARING_GUIDE.md) - Sharing guide for coworkers

## Secret Management

### Overview

API keys and credentials are managed through `~/.config/zsh/secret.zsh`, which is automatically loaded by your shell configuration and **gitignored** to prevent accidental commits.

### Setup

1. **Copy the template:**
   ```bash
   cp ~/repos/dotfiles/home/.config/zsh/secret.template.zsh ~/.config/zsh/secret.zsh
   ```

2. **Edit with your actual secrets:**
   ```bash
   vim ~/.config/zsh/secret.zsh
   ```

3. **Add your API keys:**
   ```bash
   export FIREFLIES_API_KEY="your-actual-api-key"
   export OPENAI_API_KEY="your-openai-key"
   # ... other secrets
   ```

4. **Reload your shell:**
   ```bash
   source ~/.zshrc  # or restart your terminal
   ```

### How It Works

- **`secret.zsh`** (not in repo): Contains your actual secrets
  - Location: `~/.config/zsh/secret.zsh`
  - **Gitignored** via `.gitignore` pattern: `*secret*`
  - Automatically sourced by `.zshrc`

- **`secret.template.zsh`** (in repo): Template for reference
  - Location: `~/repos/dotfiles/home/.config/zsh/secret.template.zsh`
  - Contains placeholder values and documentation
  - Safe to commit and share

### MCP Server Integration

MCP servers reference secrets via environment variables. MCP configuration lives in `~/.claude.json` (managed by Claude Code):

```json
// ~/.claude.json (excerpt)
{
  "mcpServers": {
    "fireflies": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://api.fireflies.ai/mcp",
        "--header",
        "Authorization: Bearer ${FIREFLIES_API_KEY}"
      ]
    }
  }
}
```

The `${FIREFLIES_API_KEY}` is automatically expanded from your `secret.zsh` when Claude Code starts.

### MCP Configuration with Templates

**IMPORTANT**: Claude Code reads MCP servers from `~/.claude.json`, NOT from a separate `mcp.json` file.

The `home/.claude/mcp.json.template` file in this repository is:
- **A template only** - version-controlled reference for MCP server configurations
- **NOT used directly** - Claude Code never reads this file
- **Merged during setup** - Content is merged into `~/.claude.json` using the jq command shown in Quick Start

**Why this approach?**
- `~/.claude.json` contains both configuration (MCP servers) AND runtime state (session data, onboarding flags, OAuth tokens)
- Claude Code actively manages `~/.claude.json` during normal operation
- Template merging separates version-controlled config from runtime state
- Allows portable MCP setup across machines without exposing session data

See Quick Start section for the merge command.

### Security Best Practices

**DO:**
- Keep `secret.zsh` in `~/.config/zsh/` only (never in repo)
- Set restrictive permissions: `chmod 600 ~/.config/zsh/secret.zsh`
- Rotate API keys periodically
- Use environment variables for all secrets in configs

**DON'T:**
- Commit `secret.zsh` to git
- Hardcode API keys in `mcp.json` or other config files
- Share your `secret.zsh` file with others
- Store secrets in version-controlled files

### Required Secrets by Component

| Service | Environment Variable | Where to Get It |
|---------|---------------------|-----------------|
| Fireflies | `FIREFLIES_API_KEY` | https://fireflies.ai/api |
| Linear | (OAuth) | Authenticated via browser |
| Notion | (OAuth) | Authenticated via browser |
| GitHub | (CLI) | `gh auth login` |
| Grafana | (AWS credentials) | AWS IAM / `~/.aws/` |

### Troubleshooting

**MCP server fails with authentication error:**
1. Check `secret.zsh` exists: `ls -la ~/.config/zsh/secret.zsh`
2. Verify variable is set: `echo $FIREFLIES_API_KEY`
3. Restart Claude Code (not just `--resume`)
4. Check MCP logs: `claude mcp logs fireflies`

**Variable not found:**
- Ensure `.zshrc` sources `secret.zsh` (it should automatically)
- Check shell: `echo $SHELL` (should be `/bin/zsh`)
- Manual load: `source ~/.config/zsh/secret.zsh`

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
ln -sf ~/repos/dotfiles/bin/cwf ~/.local/bin/cwf
ln -sf ~/repos/dotfiles/bin/gwf ~/.local/bin/gwf

# Neovim
ln -sf ~/repos/dotfiles/home/.config/nvim ~/.config/nvim

# Config directories
ln -sf ~/repos/dotfiles/home/.config/cwf ~/.config/cwf
ln -sf ~/repos/dotfiles/home/.config/gwf ~/.config/gwf

# Claude Code settings
mkdir -p ~/.claude
ln -sf ~/repos/dotfiles/home/.claude/settings.json ~/.claude/settings.json

# MCP servers: Must be merged into ~/.claude.json (NOT symlinked)
# See Quick Start section above for the jq merge command

# Linux only: Desktop environment
ln -sf ~/repos/dotfiles/home/.config/hypr ~/.config/hypr
ln -sf ~/repos/dotfiles/home/.config/waybar ~/.config/waybar
# ... (see INSTALLATION.md for complete list)
```

## Directory Structure

```
~/repos/dotfiles/
├── .bashrc                          # Bash configuration
├── .zprofile                        # Zsh configuration
├── .tmux.conf                       # TMUX configuration
├── home/                            # Files that go in ~/
│   ├── .claude/                     # Claude Code settings
│   │   ├── settings.json            # Hooks & permissions (symlinked)
│   │   └── mcp.json.template        # MCP template (NOT used directly - merged to ~/.claude.json)
│   └── .config/                     # Application configs
│       ├── nvim/                    # Neovim (cross-platform)
│       ├── cwf/                     # cwf CLI config (cross-platform)
│       ├── gwf/                     # gwf CLI config (cross-platform)
│       ├── zsh/                     # Zsh configuration files
│       │   └── secret.template.zsh  # API keys template
│       ├── hypr/                    # Hyprland (Linux only)
│       ├── waybar/                  # Waybar (Linux only)
│       ├── rofi/                    # Rofi (Linux only)
│       ├── kitty/                   # Kitty terminal
│       └── ...                      # Many more configs
├── bin/                             # Utility scripts
│   ├── cwf                          # Claude Workflow CLI
│   ├── gwf                          # Git Workflow CLI
│   ├── git-aliases                  # Git utilities
│   ├── grep-recursive               # Search utilities
│   └── ...                          # More utilities
├── Library/                         # macOS preferences
├── wallpapers/                      # Desktop wallpapers
├── README.md                        # This file
├── INSTALLATION.md                  # Detailed installation guide
└── PACKAGE_MANAGEMENT.md            # Package management guide
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
- **[home/.claude/README.md](home/.claude/README.md)**: Claude Code MCP server configuration and management
- **[docs/cwf-meta-commands.md](docs/cwf-meta-commands.md)**: cwf meta-commands for self-extension
- **[docs/gwf.md](docs/gwf.md)**: gwf complete usage guide and command reference
- **[docs/GWF_SHARING_GUIDE.md](docs/GWF_SHARING_GUIDE.md)**: gwf sharing guide for coworkers
- **[docs/gwf-quick-reference.md](docs/gwf-quick-reference.md)**: gwf quick reference card
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
