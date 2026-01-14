# CLAUDE.md - Dotfiles Repository

Guidance for Claude Code when working with this dotfiles repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files, scripts, and tmux plugins. Files are typically symlinked from the repo to their actual locations in the home directory.

## Working with Symlinked Files and Worktrees

### The Symlink Challenge

Many files in this repo are symlinked to their actual locations:
- `~/.claude/settings.json` → `~/repos/dotfiles/.claude/settings.json`
- `~/.tmux.conf` → `~/repos/dotfiles/.tmux.conf`
- etc.

### ⚠️ Critical Rule for Worktree Development

**When working in a feature worktree, ALWAYS edit the worktree's local copy, NOT through symlinks.**

#### Why This Matters

Git worktrees create separate working directories:
- Main repo: `~/repos/dotfiles/.claude/settings.json`
- Feature worktree: `~/repos/dotfiles-feature-my-branch/.claude/settings.json`

When you edit `~/.claude/settings.json` (the symlink), changes go to the **main repo's copy**, not the worktree's copy!

#### Correct Workflow

```bash
# ❌ WRONG - Edits main's copy via symlink
gwf wt feature my-feature
vim ~/.claude/settings.json    # Goes to main repo!

# ✅ CORRECT - Edit worktree's copy directly
gwf wt feature my-feature
cd ~/repos/dotfiles-feature-my-branch
vim .claude/settings.json      # Edits worktree's copy
```

### Files That Are Commonly Symlinked

Watch out for these when doing feature work:
- `.claude/settings.json` - Claude Code configuration
- `.tmux.conf` - tmux configuration
- `.config/zsh/user.zsh` - Shell customizations
- Any file symlinked during dotfiles installation

### Quick Check

To see if a file is symlinked:
```bash
ls -la ~/.claude/settings.json
# Shows: lrwxr-xr-x ... -> /Users/.../repos/dotfiles/.claude/settings.json
```

### What Happens If You Edit Through Symlink

1. Changes go to main branch's copy
2. Git sees uncommitted changes in main when you try to switch branches
3. You'll need to stash the changes
4. Changes won't be in your feature branch commit

### Recovery If You Made This Mistake

```bash
# Save your changes
cd ~/repos/dotfiles
git diff .claude/settings.json > /tmp/my-changes.patch

# Apply to worktree
cd ~/repos/dotfiles-feature-my-branch
git apply /tmp/my-changes.patch

# Restore main's copy
cd ~/repos/dotfiles
git restore .claude/settings.json
```

## tmux-claude-status Plugin

This repo includes a custom tmux plugin for displaying Claude Code status.

### Key Files
- `tmux-plugins/tmux-claude-status/` - Plugin directory
- `hooks/tmux-claude-status-hook.sh` - Hook script that tracks Claude state
- `.claude/settings.json` - Contains hooks configuration

### Development Notes

**v3.0 Architecture**: Uses Claude Code's official hooks system (not statusline polling)
- Hooks fire on events: UserPromptSubmit, Stop, SessionEnd, etc.
- State cached in `~/.cache/tmux-claude-status/`
- No visible UI in Claude (hooks are silent)

**Testing Changes**:
```bash
# After editing hook script, restart Claude to reload
# Use CLAUDE_TMUX_STATUS_DEBUG=1 for debug logging
export CLAUDE_TMUX_STATUS_DEBUG=1
claude

# Watch debug log in another pane
tail -f /tmp/claude-tmux-hook-debug.log
```

**Important**: Hooks are loaded when Claude starts. After changing `.claude/settings.json`, you must:
1. Exit Claude (Ctrl+D)
2. Start fresh: `claude` (not `claude --resume`)
3. Verify: `/hooks` should show tmux-claude-status hooks

## Git Workflow

### Creating Feature Branches

```bash
# Use gwf to create worktrees
gwf wt feature my-feature-name

# This creates:
# ~/repos/dotfiles-feature-my-feature-name/
```

### Important: Edit Files in Worktree

When making changes, always `cd` into the worktree and edit files relative to it:

```bash
cd ~/repos/dotfiles-feature-my-feature-name
vim .claude/settings.json        # Correct
vim tmux-plugins/.../script.sh   # Correct
```

Don't use absolute paths or symlinks when in a worktree.

### Committing and PRs

```bash
# Standard workflow
cd ~/repos/dotfiles-feature-my-feature-name
git add .
git commit -m "feat: Your change"
gwf pr push "Your PR title"
```

### Cleanup

```bash
# After PR merges
gwf wt cleanup my-feature-name
```

## Common Files to Edit

### Claude Configuration
- `.claude/settings.json` - Hooks, permissions, general settings
- Remember: Edit worktree's copy when doing feature work!

### tmux Configuration
- `.tmux.conf` - Main tmux config
- `tmux-plugins/tmux-claude-status/` - Status plugin

### Shell Configuration
- `.config/zsh/user.zsh` - User-specific shell config

### Scripts
- `scripts/` - Utility scripts (cursor-agent.sh, gwf.sh, etc.)

## Testing Changes

### tmux Plugin Changes

```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Or reload plugin specifically
~/repos/dotfiles/tmux-plugins/tmux-claude-status/tmux-claude-status.tmux
```

### Claude Settings Changes

```bash
# Must restart Claude (not --resume)
# Exit current session
# Start fresh
claude

# Verify with
/hooks
```

### Shell Config Changes

```bash
# Reload shell config
source ~/.zshrc
```

## Repository Structure

```
dotfiles/
├── .claude/
│   └── settings.json              # Claude configuration (symlinked)
├── .config/
│   └── zsh/
│       └── user.zsh               # Shell config (symlinked)
├── tmux-plugins/
│   └── tmux-claude-status/        # tmux status plugin
│       ├── hooks/                 # Hook scripts
│       ├── scripts/               # State readers
│       └── tmux-claude-status.tmux
├── scripts/                       # Utility scripts
├── .tmux.conf                     # tmux config (symlinked)
├── INSTALLATION.md                # Setup instructions
└── README.md                      # Overview
```

## Key Takeaways

1. **Always edit worktree's local copy** when doing feature work
2. **Never edit through symlinks** when in a worktree
3. **Restart Claude** (not --resume) after changing hooks
4. **Use debug mode** to troubleshoot hook issues
5. **Test in tmux** when changing tmux plugin

## Questions?

For general dotfiles usage, see:
- `README.md` - Overview and features
- `INSTALLATION.md` - Setup instructions
- `PACKAGE_MANAGEMENT.md` - Managing packages

For Claude Code CLI usage, see your global `~/.claude/CLAUDE.md`.
