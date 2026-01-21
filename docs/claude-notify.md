# Claude Code OS Notifications

The `claude-notify` hook sends native OS notifications when:
- **Stop event**: Claude finishes processing and is waiting for user input
- **SessionEnd event**: Claude session ends

If running inside tmux, the notification includes the window name (e.g., "Waiting for input (window: my-project)").

## Cross-Platform Support

- **macOS**: Uses `osascript` to display notifications
- **Linux**: Uses `notify-send` for desktop notifications

## Installation

The hook is already configured in `home/.claude/settings.json` for the `Stop` and `SessionEnd` events.

To use on another machine:
1. Copy `bin/claude-notify` to `~/.local/bin/` or `~/repos/dotfiles/bin/`
2. Make it executable: `chmod +x bin/claude-notify`
3. Add to your Claude settings (already done in this repo's settings.json)

## Testing

Test manually:
```bash
~/repos/dotfiles/bin/claude-notify Stop
~/repos/dotfiles/bin/claude-notify SessionEnd
```

## Requirements

- **macOS**: Built-in `osascript` (no additional dependencies)
- **Linux**: `notify-send` (usually from `libnotify-bin` package)
  ```bash
  # Ubuntu/Debian
  sudo apt-get install libnotify-bin

  # Arch
  sudo pacman -S libnotify
  ```

## Customization

Edit `bin/claude-notify` to customize notification messages or add more events.

Available hook events:
- `SessionStart` - Claude session starts
- `UserPromptSubmit` - User submits a prompt
- `Stop` - Claude finishes and waits for input (currently enabled)
- `Notification` - Claude internal notification
- `SessionEnd` - Claude session ends (currently enabled)

## How It Works

The script:
1. Checks if running inside tmux and gets the window name
2. Detects the operating system using `is-macos` and `is-linux` helper scripts
3. Calls the appropriate notification system with the window name appended
4. Fails silently if the notification system is unavailable

## Example Notifications

**Outside tmux:**
- "Waiting for input"
- "Session ended"

**Inside tmux:**
- "Waiting for input (window: data-pipelines)"
- "Session ended (window: my-project)"

## Troubleshooting

**Notifications not appearing:**
- Restart Claude Code (not `--resume`) to reload hooks
- Check that the script is executable: `ls -la ~/repos/dotfiles/bin/claude-notify`
- Test manually: `~/repos/dotfiles/bin/claude-notify Stop`
- On Linux, ensure `notify-send` is installed: `which notify-send`

**Verify hooks are loaded:**
```bash
# In Claude Code
/hooks
```

You should see `claude-notify` listed under Stop and SessionEnd events.
