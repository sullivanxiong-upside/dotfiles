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

### Critical Rule for Worktree Development

**When working in a feature worktree, ALWAYS edit the worktree's local copy, NOT through symlinks.**

#### Why This Matters

Git worktrees create separate working directories:
- Main repo: `~/repos/dotfiles/.claude/settings.json`
- Feature worktree: `~/repos/dotfiles-feature-my-branch/.claude/settings.json`

When you edit `~/.claude/settings.json` (the symlink), changes go to the **main repo's copy**, not the worktree's copy.

#### Correct Workflow

```bash
# WRONG - Edits main's copy via symlink
gwf wt feature my-feature
vim ~/.claude/settings.json    # Goes to main repo

# CORRECT - Edit worktree's copy directly
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

This repo uses the `tmux-claude-status` plugin for displaying Claude Code status in tmux window tabs.

### Installation

The plugin is installed via TPM (Tmux Plugin Manager). See `.tmux.conf`:
```bash
set -g @plugin 'SullivanXiong/tmux-claude-status'
```

### Plugin Repository

**Location**: https://github.com/SullivanXiong/tmux-claude-status

The plugin is now a separate repository and installed via TPM, not bundled with dotfiles.

### Hook Configuration

The plugin requires hooks in `.claude/settings.json` to track Claude Code state:
- `SessionStart`, `UserPromptSubmit`, `Stop`, `Notification`, `SessionEnd`
- Hook paths reference: `~/.tmux/plugins/tmux-claude-status/hooks/tmux-claude-status-hook.sh`

See the [plugin's README](https://github.com/SullivanXiong/tmux-claude-status) for full setup instructions.

### Key Points

- **v3.0 Architecture**: Uses Claude Code's official hooks API (not statusline polling)
- **State caching**: `~/.cache/tmux-claude-status/` (auto-generated)
- **Hook reload**: Restart Claude (not `--resume`) after changing `.claude/settings.json`
- **Verification**: Run `/hooks` in Claude to verify tmux-claude-status hooks are loaded

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

## Claude Session Management in Worktrees

### Overview

When creating git worktrees, Claude Code sessions are automatically linked to the main repository. This allows `claude --continue` in a worktree to resume your main repository conversation with full context.

### How It Works

Claude Code stores conversations in `~/.claude/projects/{encoded-path}/`. gwf creates a symlink from the worktree's session directory to the main repository's session directory, making all main repo conversations automatically available in worktrees.

### Basic Usage

```bash
# Normal workflow - automatic linking
cd ~/repos/dotfiles
claude  # Start conversation
gwf wt feature add-tmux-feature
cd ~/repos/dotfiles-feature-add-tmux-feature
claude --continue  # Resumes main repo conversation with full context
```

### Session Commands

**Check linking status:**
```bash
gwf session status
```

**Break link (create independent sessions):**
```bash
gwf session unlink
```

**Re-establish link:**
```bash
gwf session relink
```

### Environment Variables

**Disable automatic linking:**
```bash
export GWF_NO_SESSION_LINK=1
gwf wt feature my-branch  # Creates independent session directory
```

### Common Scenarios

**Multiple feature branches:**
All worktrees share conversation history. This is intentional - you can move between features while maintaining context.

**Independent sessions per worktree:**
Use `gwf session unlink` or set `GWF_NO_SESSION_LINK=1` before creating worktrees.

**No main sessions yet:**
If you create a worktree before running Claude in main repo, linking is skipped. Run `gwf session relink` after creating main repo sessions.

### Troubleshooting

**"Warning: Worktree has existing sessions"**
Your worktree has substantial conversations (>100KB). Options:
- Keep existing: Do nothing, worktree remains independent
- Force linking: Remove existing sessions and run `gwf session relink`

**Session not continuing in worktree:**
1. Check status: `gwf session status`
2. If unlinked: `gwf session relink`
3. If no main sessions: Create a session in main repo first

## Common Files to Edit

### Claude Configuration
- `.claude/settings.json` - Hooks, permissions, general settings
- Remember: Edit worktree's copy when doing feature work

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
# Reload tmux config (will reload all TPM plugins)
tmux source-file ~/.tmux.conf

# To update tmux-claude-status plugin to latest version:
# In tmux: Ctrl+A then U (capital u) to update plugins
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
├── scripts/                       # Utility scripts
├── .tmux.conf                     # tmux config (symlinked)
├── INSTALLATION.md                # Setup instructions
└── README.md                      # Overview
```

**Note**: `tmux-claude-status` plugin is now a separate repository installed via TPM to `~/.tmux/plugins/tmux-claude-status/`

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
