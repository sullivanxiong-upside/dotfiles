# gwf - Git Workflow Tool: Sharing Guide

A comprehensive guide for getting started with `gwf`, a Git workflow tool that makes worktree management and parallel development effortless.

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start: Worktrees](#quick-start-worktrees)
- [Configuration (Optional)](#configuration-optional)
- [Tips and Patterns](#tips-and-patterns)
- [Command Reference](#command-reference)
- [FAQ](#faq)

---

## Introduction

### What is gwf?

`gwf` (Git Workflow) is a bash wrapper around git that provides:

1. **Intelligent worktree management** - Work on multiple branches simultaneously without switching
2. **Config file auto-copying** - Automatically copy local configs to new worktrees (Claude permissions, local YAML configs, etc.)
3. **Convenient shortcuts** - Organized git commands with shorthand syntax
4. **PR integration** - Push and create PRs in one command

### Why use it?

**Problem**: You're working on a feature, someone asks you to review their PR. You either:
- Stash your work, switch branches, review, switch back (slow, error-prone)
- Clone another copy of the repo (wastes disk space, multiple remotes to manage)

**Solution**: Git worktrees let you have multiple working directories for the same repository. `gwf` makes this effortless.

**Bonus**: When creating worktrees, `gwf` can automatically copy your config files (like `.claude/settings.local.json` for Claude permissions, or `local-config.*.yaml` files) so you don't have to re-approve permissions or reconfigure services in every worktree.

### Prerequisites

- **git** (obviously)
- **gh** CLI (optional, only needed for PR commands like `gwf pr push`)
  - Install: `brew install gh` or see https://cli.github.com/

---

## Installation

### Step 1: Get the script

**Option A: Copy from a coworker**

```bash
# Copy gwf script to your local bin
mkdir -p ~/.local/bin
cp /path/to/their/gwf ~/.local/bin/gwf
chmod +x ~/.local/bin/gwf
```

**Option B: Copy from dotfiles repo**

```bash
mkdir -p ~/.local/bin
cp ~/repos/dotfiles/bin/gwf ~/.local/bin/gwf
chmod +x ~/.local/bin/gwf
```

**Option C: Download directly** (if hosted on GitHub)

```bash
mkdir -p ~/.local/bin
curl -o ~/.local/bin/gwf https://raw.githubusercontent.com/YourOrg/dotfiles/main/bin/gwf
chmod +x ~/.local/bin/gwf
```

### Step 2: Add to PATH (if needed)

Make sure `~/.local/bin` is in your PATH. Check with:

```bash
echo $PATH | grep -q "$HOME/.local/bin" && echo "Already in PATH" || echo "Need to add to PATH"
```

If you need to add it, add this to your `~/.zshrc` or `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

### Step 3: Verify installation

```bash
gwf --help
```

You should see the gwf help output.

### Step 4: Install shell completion (Recommended)

For command completion in your shell (auto-detects bash or zsh):

```bash
gwf completion install
```

This adds the completion source to your `~/.config/zsh/user.zsh` (zsh) or `~/.bashrc` (bash).

Then reload your shell:

```bash
source ~/.config/zsh/user.zsh  # zsh
source ~/.bashrc               # bash
```

**What this does**: Adds a small snippet to your shell config that dynamically loads completion when gwf is available. The completion script is built into gwf - no separate files needed.

---

## Quick Start: Worktrees

### What are worktrees?

Git worktrees let you check out multiple branches simultaneously in different directories, all sharing the same git repository data.

**Traditional workflow:**
```bash
cd ~/projects/my-repo
git checkout feature-a
# Work on feature-a...
git stash  # Ugh, someone needs a review
git checkout their-branch
# Review...
git checkout feature-a
git stash pop
```

**With worktrees:**
```bash
# Terminal 1: Your main work
cd ~/projects/my-repo
# Keep working on current branch

# Terminal 2: Quick review in parallel
cd ~/projects/my-repo-review-their-branch
# Review independently, no stashing needed
```

### Creating worktrees with gwf

**Feature worktree** (for your own new work):

```bash
cd ~/projects/data-pipelines
gwf wt feature my-new-feature

# Creates: ~/projects/data-pipelines-feature-my-new-feature/
# Now you can cd there and work independently
```

**Review worktree** (for reviewing someone else's work):

```bash
cd ~/projects/data-pipelines
gwf wt review colleague-branch

# Creates: ~/projects/data-pipelines-review-colleague-branch/
```

**Where do they get created?**

Worktrees are created as **siblings** to your main repository:
- Main repo: `~/projects/data-pipelines/`
- Feature worktree: `~/projects/data-pipelines-feature-my-new-feature/`
- Review worktree: `~/projects/data-pipelines-review-colleague-branch/`

This works **regardless of where your repo is located** - no hardcoded paths.

### Your first worktree workflow

```bash
# 1. Create a feature worktree
cd ~/projects/data-pipelines
gwf wt feature add-logging

# 2. Go to the worktree
cd ~/projects/data-pipelines-feature-add-logging

# 3. Make your changes...
# ... edit files ...

# 4. Commit
gwf l a              # Stage all (git add .)
gwf l c "Add logging"  # Commit

# 5. Push and create PR
gwf pr push "Add structured logging"

# 6. Back to main repo
cd ~/projects/data-pipelines

# 7. Clean up when done
gwf wt cleanup add-logging
```

### Cleanup

When you're done with a worktree:

```bash
gwf wt cleanup my-new-feature
# Removes: ~/projects/data-pipelines-feature-my-new-feature/
```

This removes the directory and tells git to stop tracking that worktree.

---

## Configuration (Optional)

### Why configure?

By default, `gwf` worktree commands work perfectly **without any configuration**. However, configuration enables a powerful feature: **automatic config file copying**.

**Without config:**
- All worktree commands work
- You'll need to manually copy local configs to each worktree
- You'll need to re-approve Claude Code permissions in each worktree

**With config:**
- All worktree commands work
- Local configs automatically copied to new worktrees
- Claude permissions already approved in new worktrees
- Service configs (local-config.*.yaml) already set up

### First-run setup wizard

The first time you run `gwf wt feature` or `gwf wt review`, you'll see a setup wizard:

```
===== First-time gwf setup =====

To auto-copy config files to worktrees, please provide paths to your main repos.
Leave empty to skip (you can set MAIN_CDS/MAIN_DP environment variables later).

Path to main customer-dashboard repo: /Users/you/projects/customer-dashboard
Path to main data-pipelines repo: /Users/you/projects/data-pipelines

Configuration saved to ~/.gwf-config
```

**You can skip this** by pressing Enter - worktrees will still work, but configs won't auto-copy.

### What gets auto-copied?

When you create a worktree, `gwf` automatically copies:

**Universal (all repos):**
- `.claude/settings.local.json` - Claude Code permissions

**data-pipelines specific:**
- `src/jobs/datahub_llm_analysis_service/local-config.<your-name>.yaml`
- `src/jobs/datahub_llm_job_processor/local-config.<your-name>.yaml`
- Any other `local-config.*.yaml` files you configure

**customer-dashboard specific:**
- `.env.local` - Local environment variables
- Any other local config files you configure

### Manual configuration

Create or edit `~/.config/gwf/repos.conf`:

```bash
# gwf configuration - Upside-specific setup

# Main repository paths (absolute paths required)
export MAIN_CDS="/Users/you/projects/customer-dashboard"
export MAIN_DP="/Users/you/projects/data-pipelines"

# (Optional) Customize which configs to copy for data-pipelines
export CONFIGS_DATA_PIPELINES=(
  "src/jobs/datahub_llm_analysis_service/local-config.yourname.yaml"
  "src/jobs/datahub_llm_job_processor/local-config.yourname.yaml"
  "path/to/any/other/config.yaml"
)

# (Optional) Customize which configs to copy for customer-dashboard
export CONFIGS_CUSTOMER_DASHBOARD=(
  ".env.local"
  "path/to/any/other/config"
)
```

**Note**: Replace `yourname` with your actual name as it appears in your config files.

### Updating configuration

If your main repo paths change, just edit `~/.config/gwf/repos.conf` or `~/.gwf-config` with the new paths.

---

## Tips and Patterns

### 1. Review PRs without disrupting current work

```bash
# You're working on feature-a in main repo
cd ~/projects/data-pipelines
# ... coding ...

# Someone asks: "Can you review PR #1234?"
gwf pr co 1234
# Creates: ~/projects/data-pipelines-review-pr-1234/

# Open a new terminal tab/window
cd ~/projects/data-pipelines-review-pr-1234
# Review, test, leave comments...

# Done reviewing
gwf wt cleanup pr-1234

# Back to terminal 1: you never stopped working on feature-a
```

### 2. Feature development workflow

```bash
# Start new feature
gwf wt feature my-feature
cd ~/projects/data-pipelines-feature-my-feature

# Make changes...
# ... edit files ...

# Commit frequently
gwf l a                # Stage all
gwf l c "Add feature X"  # Commit
gwf l c "Fix tests"      # Another commit

# Push and create PR in one command
gwf pr push "Add feature X"

# Get PR URL to share
gwf pr l
# Output: https://github.com/UpsideLabs/data-pipelines/pull/1686

# Copy to clipboard (macOS)
gwf pr l | pbcopy
```

### 3. Working on multiple features

```bash
# Feature A: waiting on CI
gwf wt feature feature-a
cd ~/projects/data-pipelines-feature-feature-a
# Make changes...
gwf pr push "Feature A"

# Feature B: start immediately without waiting
gwf wt feature feature-b
cd ~/projects/data-pipelines-feature-feature-b
# Work independently

# List all your worktrees
gwf wt list

# Clean up when PRs merge
gwf wt cleanup feature-a
gwf wt cleanup feature-b
```

### 4. Creating branches from different bases

```bash
# Create feature from develop instead of main
gwf wt feature my-fix --from=develop

# Create feature from staging
gwf wt feature experiment --from=staging

# Review a branch that's based on develop
gwf wt review colleague-feature
# gwf automatically detects the base branch
```

### 5. List all worktrees

```bash
gwf wt list

# Example output:
# /Users/you/projects/data-pipelines (main)
# /Users/you/projects/data-pipelines-feature-new-api (feature/new-api)
# /Users/you/projects/data-pipelines-review-pr-1234 (pr-1234)
```

### 6. Cleanup after PR merges

```bash
# After your PR merges
cd ~/projects/data-pipelines
gwf wt cleanup my-feature-branch

# Or cleanup by PR number
gwf wt cleanup pr-1234
```

### 7. Quick git operations

```bash
# Stage all changes
gwf l a

# Commit with message
gwf l c "Fix bug"

# Check status
gwf l s

# See diff
gwf l d

# See commits ahead of main
gwf l dc

# Push (sets upstream automatically)
gwf r ps

# Pull and rebase
gwf r r
```

---

## Command Reference

### Command Categories

`gwf` organizes commands into categories with shortcuts:

| Category | Shortcut | Purpose |
|----------|----------|---------|
| `local` | `l` | Local repo operations (stage, commit, status, diff) |
| `remote` | `r` | Remote operations (push, pull, rebase) |
| `worktree` | `wt` | Worktree management (review, feature, cleanup, list) |
| `pr` | `pr` | Pull request operations (create, checkout, push, list) |
| `inspect` | `i` | Inspection (diff, log, show, blame) |

### Most Useful Commands for Worktrees

```bash
# Worktree management
gwf wt feature <branch> [--from=base]   # Create feature worktree
gwf wt review <branch>                  # Create review worktree
gwf wt cleanup <branch>                 # Remove worktree
gwf wt list                             # List all worktrees

# PR workflow (requires gh CLI)
gwf pr co <number>                      # Checkout PR as review worktree
gwf pr push ["title"]                   # Push + create/update PR
gwf pr l                                # Get PR URL for current branch
gwf pr ls                               # List PRs

# Common git operations
gwf l a [files]                         # Stage files (default: all)
gwf l c "message"                       # Commit with message
gwf l s                                 # Status
gwf l d [target]                        # Diff
gwf l dc [branch]                       # Show commits ahead of base

gwf r ps                                # Push (sets upstream)
gwf r r [branch]                        # Pull and rebase
gwf r pl [branch]                       # Pull from remote

gwf i d [target]                        # Show diff
gwf i log [options]                     # Show commit log
```

### Full Command Reference

For the complete command reference, see [docs/gwf.md](./gwf.md).

---

## FAQ

### General Questions

**Q: Where do worktrees get created?**

A: As siblings to your main repository. If your main repo is at `/home/user/code/my-repo`, worktrees become:
- `/home/user/code/my-repo-feature-mybranch`
- `/home/user/code/my-repo-review-pr-123`

This works **regardless of where you put your repos** - no hardcoded paths like `~/repos/`.

**Q: Do I need to configure MAIN_CDS/MAIN_DP?**

A: No, configuration is completely optional. Without configuration:
- All worktree commands work perfectly
- Config files won't auto-copy to new worktrees
- You'll see helpful tip messages like: `"Tip: Set MAIN_DP=/path/to/data-pipelines to auto-copy config files"`

Configuration only enables the config auto-copying feature. If you don't mind manually copying configs or don't use local configs, you can skip configuration entirely.

**Q: What if I skip the first-run setup wizard?**

A: You can:
1. Run `gwf wt feature` again - the wizard will appear
2. Manually create `~/.config/gwf/repos.conf` with the config
3. Set environment variables in your shell config:
   ```bash
   export MAIN_DP="$HOME/projects/data-pipelines"
   export MAIN_CDS="$HOME/projects/customer-dashboard"
   ```

**Q: Can I use gwf with any git repo, not just Upside ones?**

A: Yes. All worktree commands work with any git repository. The config auto-copying is specific to data-pipelines and customer-dashboard, but you can:
- Use worktrees without config auto-copying
- Customize the config arrays in `~/.config/gwf/repos.conf` for your repos

### Worktree Questions

**Q: What happens when I create a worktree for a branch that already exists?**

A: `gwf` intelligently handles existing branches:

1. **Remote branch exists** (e.g., `origin/feature-x`)
   - Creates local tracking branch from remote
   - Result: Your local branch tracks the remote, no divergence

2. **Local branch exists**
   - Checks out your existing local branch
   - Result: Continues your local work

3. **Neither exists**
   - Creates new branch from base (main/master/develop or `--from=` branch)
   - Result: Fresh branch from base

**Q: What's the difference between `review` and `feature` worktrees?**

A: **Just naming convention.** Both work identically - the prefix helps you organize:
- `feature`: For creating new branches/features (becomes `repo-feature-name`)
- `review`: For checking out existing branches to review (becomes `repo-review-name`)

**Q: What happens to my worktree configs when I cleanup?**

A: The **entire worktree directory is removed**, including all copied configs. Your main repo configs are **never touched**.

**Q: Can I have multiple worktrees from the same repo?**

A: Yes. You can have:
- Main repo: working on feature-a
- Worktree 1: working on feature-b
- Worktree 2: reviewing PR #123
- Worktree 3: testing hotfix

All simultaneously, all independent.

**Q: The worktree path is really long. Can I change it?**

A: Currently no, but you can create symlinks or aliases:

```bash
# Create a symlink
ln -s ~/projects/data-pipelines-feature-very-long-branch ~/dp-feat
cd ~/dp-feat

# Or use a shell alias
alias dpf='cd ~/projects/data-pipelines-feature-very-long-branch'
```

### Configuration Questions

**Q: Which config files get auto-copied?**

A: By default:

**All repos:**
- `.claude/settings.local.json` (Claude permissions)

**data-pipelines:**
- `src/jobs/datahub_llm_analysis_service/local-config.*.yaml`
- `src/jobs/datahub_llm_job_processor/local-config.*.yaml`

**customer-dashboard:**
- `.env.local`

You can customize these in `~/.config/gwf/repos.conf`.

**Q: Can I customize which config files get copied?**

A: Yes. Edit `~/.config/gwf/repos.conf`:

```bash
export CONFIGS_DATA_PIPELINES=(
  "path/to/config1.yaml"
  "path/to/config2.json"
  ".env.local"
)

export CONFIGS_CUSTOMER_DASHBOARD=(
  ".env.local"
  ".env.test"
)
```

**Q: What if my main repo path changes?**

A: Edit `~/.config/gwf/repos.conf` or `~/.gwf-config` with the new paths:

```bash
export MAIN_DP="/new/path/to/data-pipelines"
export MAIN_CDS="/new/path/to/customer-dashboard"
```

**Q: Why are there two config files (~/.gwf-config and ~/.config/gwf/repos.conf)?**

A: `~/.gwf-config` is the legacy format (created by the first-run wizard). `~/.config/gwf/repos.conf` is the new preferred location following XDG standards. `gwf` checks both for backward compatibility.

### Tool Questions

**Q: Do I need GitHub CLI (gh)?**

A: Optional. Without gh:
- All worktree commands work
- All basic git commands work
- PR commands won't work (`gwf pr create`, `gwf pr push`, etc.)

Install gh if you want PR integration: `brew install gh` or https://cli.github.com/

**Q: How do I update gwf later?**

A: Just replace the file in `~/.local/bin/gwf` with the new version:

```bash
cp /path/to/new/gwf ~/.local/bin/gwf
chmod +x ~/.local/bin/gwf
```

**Q: Where can I get help?**

A:
- Run `gwf --help` for command overview
- Run `gwf <category> --help` for category help (e.g., `gwf wt --help`)
- Read the [full documentation](./gwf.md)
- Ask your coworker who shared this with you!

### Upside-Specific Questions

**Q: I use Upside's data-pipelines repo. What should I configure?**

A: Configure your main repo path and local config files:

```bash
# In ~/.config/gwf/repos.conf
export MAIN_DP="$HOME/repos/data-pipelines"

# Customize with your actual config file names
export CONFIGS_DATA_PIPELINES=(
  "src/jobs/datahub_llm_analysis_service/local-config.yourname.yaml"
  "src/jobs/datahub_llm_job_processor/local-config.yourname.yaml"
)
```

Replace `yourname` with your actual name as it appears in your config files.

**Q: I use Upside's customer-dashboard repo. What should I configure?**

A: Configure your main repo path:

```bash
# In ~/.config/gwf/repos.conf
export MAIN_CDS="$HOME/repos/customer-dashboard"

# .env.local is auto-detected, but you can customize:
export CONFIGS_CUSTOMER_DASHBOARD=(
  ".env.local"
)
```

---

## Getting Started Checklist

- [ ] Install gwf to `~/.local/bin/gwf`
- [ ] Add `~/.local/bin` to PATH
- [ ] Verify with `gwf --help`
- [ ] (Optional) Install shell completion: `gwf completion install`
- [ ] (Optional) Configure main repo paths for config auto-copying
- [ ] Try your first worktree: `gwf wt feature test-gwf`
- [ ] Explore and cleanup: `gwf wt list` then `gwf wt cleanup test-gwf`

---

## Additional Resources

- [Full command documentation](./gwf.md) - Complete reference for all commands
- [GitHub CLI documentation](https://cli.github.com/manual/) - For PR integration
- [Git worktrees documentation](https://git-scm.com/docs/git-worktree) - Official git docs

---

## Support

If you encounter issues:

1. Check `gwf --help` for usage
2. Verify you're in a git repository
3. For PR commands, ensure `gh` is installed and authenticated
4. Ask your coworker who shared this with you
