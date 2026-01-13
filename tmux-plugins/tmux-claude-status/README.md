# tmux-claude-status v2.0

Real-time Claude Code status monitoring in tmux window tabs.

## Features

- **Real-time status** - Updates every 300ms from Claude's internal state via `/statusline` API
- **No flashing** - Smooth transitions based on token changes, not arbitrary timeouts
- **Per-window tracking** - Each tmux window shows its own Claude instance status
- **Customizable** - Configure icons, colors, and position
- **Low overhead** - Minimal CPU usage, efficient caching
- **TPM compatible** - Works as a standard tmux plugin

## Status Indicators

| Icon | Meaning | When Shown |
|------|---------|------------|
| `...` | Processing | Claude is generating response, thinking, or executing tools |
| `✔` | Completed | Claude finished and ready for next prompt |
| `○` | No Claude | No Claude running in this pane (optional) |

### Colors

- **Active tab**: White bold (high visibility)
- **Inactive, processing**: Yellow `...`
- **Inactive, completed**: Green `✔`

## Prerequisites

1. **tmux** 3.0+
2. **jq** - JSON processor
   ```bash
   # macOS
   brew install jq

   # Linux
   sudo apt install jq     # Debian/Ubuntu
   sudo pacman -S jq       # Arch
   ```
3. **Claude Code CLI** with statusline configured

## Installation

### Step 1: The plugin is already in your dotfiles!

This plugin is located at `~/repos/dotfiles/tmux-plugins/tmux-claude-status/`.

### Step 2: Configure Claude Code Statusline

The statusline script tells Claude Code to write state information that the plugin reads.

```bash
# Copy statusline script to Claude config
cp ~/repos/dotfiles/tmux-plugins/tmux-claude-status/extras/statusline.sh ~/.claude/
chmod +x ~/.claude/statusline.sh
```

Configure Claude Code to use it:

**Edit or create `~/.claude/settings.json`:**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

### Step 3: Load Plugin in tmux

**Add to your `~/.tmux.conf`:**

```bash
# Load tmux-claude-status plugin
# IMPORTANT: Place AFTER TPM plugins to override theme formats
run-shell ~/repos/dotfiles/tmux-plugins/tmux-claude-status/tmux-claude-status.tmux
```

**Reload tmux configuration:**
```bash
tmux source-file ~/.tmux.conf
```

### Step 4: Test It

```bash
# Start Claude in a tmux window
claude

# Watch the window tab - status should appear!
# You should see: [1] ... claude-session  (while processing)
#            or:  [1] ✔ claude-session  (when ready)
```

## Configuration

Customize via `.tmux.conf` (place BEFORE plugin load):

```bash
# Icons (default: "..." and "✔")
set -g @claude-status-icon-processing "⚙️"
set -g @claude-status-icon-completed "✨"
set -g @claude-status-icon-empty "○"

# Position: "before" or "after" window name
# before: [1] ... window-name
# after:  [1] window-name ...
set -g @claude-status-position "before"

# Show indicator when no Claude running (default: false)
set -g @claude-status-show-empty "true"

# State max age in seconds (default: 5)
# Files older than this are considered stale
set -g @claude-status-max-age "10"

# Enable debug logging (default: false)
set -g @claude-status-debug "true"
# View logs: tail -f /tmp/tmux-claude-status-debug.log
```

## How It Works

### Architecture

```
┌──────────────────────┐
│   Claude Code        │ Runs in tmux pane
│   (every 300ms)      │
└──────────┬───────────┘
           │ JSON via stdin
           ▼
┌──────────────────────┐
│  ~/.claude/          │ Analyzes token changes
│  statusline.sh       │ - tokens_out ↑ = generating
└──────────┬───────────┘ - tokens_in ↑ = thinking
           │             - stable = completed
           ▼
┌──────────────────────┐
│  cache/*.json        │ State files per pane
│  (in plugin dir)     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  state_reader.sh     │ Reads cache, formats display
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Tmux window tabs    │ [1] ... claude  [2] ✔ done
└──────────────────────┘
```

### Token-Based State Detection

The plugin detects Claude's state by monitoring token changes in the JSON data from `/statusline`:

- **Output tokens increasing** → Generating response (`...`)
- **Input tokens increasing** → Thinking/processing (`...`)
- **Cache reads increasing** → Loading context (`...`)
- **Tokens stable** → Completed/Ready (`✔`)

This approach eliminates the "flashing" problem from v1.0 which used arbitrary time windows.

## Troubleshooting

### Status not showing

1. **Check Claude statusline is working:**
   ```bash
   claude
   # Look for status line at bottom of terminal
   ```

2. **Check state files are being created:**
   ```bash
   ls -la ~/repos/dotfiles/tmux-plugins/tmux-claude-status/cache/
   # Should show .json files while Claude is running

   cat ~/repos/dotfiles/tmux-plugins/tmux-claude-status/cache/*.json | jq .
   # Should show valid JSON with status, tokens, etc.
   ```

3. **Check jq is installed:**
   ```bash
   which jq
   jq --version
   ```

4. **Enable debug logging:**
   ```bash
   # Add to .tmux.conf
   set -g @claude-status-debug "true"

   # Reload tmux
   tmux source-file ~/.tmux.conf

   # View logs
   tail -f /tmp/tmux-claude-status-debug.log
   ```

### Status shows stale data

State files older than 5 seconds are ignored. This happens if:
- Claude crashed/exited
- Statusline script has errors
- File permissions issue

**Check for errors:**
```bash
tail -f ~/.claude/statusline-errors.log
```

**Test statusline manually:**
```bash
echo '{"model":{"display_name":"Test"},"context_window":{"input_tokens":100,"output_tokens":200},"cost":{"total_cost_usd":0.05}}' | \
  ~/.claude/statusline.sh
```

### Plugin not loading

1. **Check load order in `.tmux.conf`:**
   ```bash
   grep -n "claude-status\|tpm" ~/.tmux.conf
   ```

   Plugin MUST load AFTER TPM (if using themes):
   ```bash
   run '~/.tmux/plugins/tpm/tpm'
   run-shell ~/repos/dotfiles/tmux-plugins/tmux-claude-status/tmux-claude-status.tmux
   ```

2. **Check file permissions:**
   ```bash
   ls -l ~/repos/dotfiles/tmux-plugins/tmux-claude-status/*.tmux
   ls -l ~/repos/dotfiles/tmux-plugins/tmux-claude-status/scripts/*.sh
   ls -l ~/.claude/statusline.sh
   ```

3. **Make executable if needed:**
   ```bash
   chmod +x ~/repos/dotfiles/tmux-plugins/tmux-claude-status/*.tmux
   chmod +x ~/repos/dotfiles/tmux-plugins/tmux-claude-status/scripts/*.sh
   chmod +x ~/.claude/statusline.sh
   ```

### Wrong path in statusline.sh

The statusline script needs to know where to write cache files. By default it uses:
```bash
STATE_DIR="${HOME}/repos/dotfiles/tmux-plugins/tmux-claude-status/cache"
```

If you cloned dotfiles to a different location, update this path in `~/.claude/statusline.sh`.

## Performance

- **Update latency**: ~300ms (Claude's statusline update cycle)
- **CPU overhead**: Minimal (< 1% - just file reads and jq parsing)
- **Memory**: Negligible (small JSON files, ~1KB per active pane)
- **Disk I/O**: ~3KB written per update per pane

## Comparison: v1.0 vs v2.0

### v1.0 (External Observation - Failed Approach)

- Used `ps` to check process state → Doesn't work with Node.js event loop
- Used `lsof` to check stdin → Can't distinguish blocked vs waiting
- Used time windows in `history.jsonl` → Caused flashing between states
- Result: **Unreliable, frequent flashing**

### v2.0 (Internal State Access - Current)

- Uses Claude's official `/statusline` API → Direct access to internal state
- Detects state from token changes → No arbitrary time windows
- Smooth transitions based on actual activity → No flashing
- Result: **Accurate, smooth, reliable**

## File Structure

```
~/repos/dotfiles/tmux-plugins/tmux-claude-status/
├── tmux-claude-status.tmux      # Main entry point (TPM compatible)
├── scripts/
│   ├── claude_state_reader.sh   # Reads state, formats display
│   └── helpers.sh               # Utility functions
├── extras/
│   └── statusline.sh            # Claude statusline script (copy to ~/.claude/)
├── cache/                       # State files (runtime, auto-created)
│   └── *.json
└── README.md                    # This file
```

## Why This Plugin?

Your v1.0 implementation revealed a fundamental problem: **you can't reliably observe Claude's state from the outside**. Process states, file descriptors, and activity timestamps are all indirect heuristics that fail with event-driven Node.js processes.

Claude's `/statusline` API solves this by providing **internal access** to the actual state through token changes. This v2.0 plugin leverages that official API to deliver accurate, real-time status with zero flashing.

## Related Documentation

- [Claude Code Statusline Docs](https://code.claude.com/docs/en/statusline.md)
- [Main Dotfiles README](../../README.md)
- [Installation Guide](../../INSTALLATION.md)
- [Initial Implementation Summary](~/Documents/tmux-claude-status-initial.md) (your v1.0 research)

## License

MIT - Part of personal dotfiles

## Credits

- Built with [Claude Code's statusline API](https://code.claude.com/docs/en/statusline.md)
- Inspired by [dracula/tmux](https://github.com/dracula/tmux) plugin structure
- Learned from v1.0's external observation challenges
