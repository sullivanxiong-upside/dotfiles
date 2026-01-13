# Quick Start Guide

Get tmux-claude-status running in 3 minutes!

## Prerequisites

```bash
# Install jq if not already installed
brew install jq  # macOS
# OR
sudo apt install jq  # Linux
```

## Installation Steps

### 1. Configure Claude Code Statusline

```bash
# Copy statusline script
cp ~/repos/dotfiles/tmux-plugins/tmux-claude-status/extras/statusline.sh ~/.claude/
chmod +x ~/.claude/statusline.sh
```

### 2. Update Claude Settings

Edit `~/.claude/settings.json` (create if doesn't exist):

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

### 3. Load Plugin in tmux

Add to your `~/.tmux.conf`:

```bash
# Load tmux-claude-status (place AFTER TPM)
run-shell ~/repos/dotfiles/tmux-plugins/tmux-claude-status/tmux-claude-status.tmux
```

### 4. Reload tmux

```bash
tmux source-file ~/.tmux.conf
```

### 5. Test It!

```bash
# Start Claude in a tmux window
claude

# You should see in the window tab:
# [1] ... claude    (while processing)
# [1] ✔ claude      (when ready)
```

## Troubleshooting

### Not seeing status?

```bash
# Check Claude statusline is working
claude
# Look for status at bottom of terminal

# Check cache files
ls -la ~/repos/dotfiles/tmux-plugins/tmux-claude-status/cache/

# Enable debug
# Add to .tmux.conf:
set -g @claude-status-debug "true"
# Then reload and check:
tail -f /tmp/tmux-claude-status-debug.log
```

### Wrong path error?

If statusline.sh shows path errors, edit `~/.claude/statusline.sh` and update this line:

```bash
STATE_DIR="${HOME}/repos/dotfiles/tmux-plugins/tmux-claude-status/cache"
```

Make sure it matches your dotfiles location.

## Customization

Add these BEFORE the plugin load line in `.tmux.conf`:

```bash
# Change icons
set -g @claude-status-icon-processing "⚙️"
set -g @claude-status-icon-completed "✨"

# Position after window name instead of before
set -g @claude-status-position "after"

# Show indicator when no Claude running
set -g @claude-status-show-empty "true"
```

## Full Documentation

- See [README.md](README.md) for complete documentation
- See [../../INSTALLATION.md](../../INSTALLATION.md) for dotfiles installation guide
