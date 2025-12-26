# gwf - Git Workflow CLI

A bash wrapper around git commands with organized categories, intelligent worktree management, and shorthand syntax.

## Quick Start

```bash
# Stage all changes
gwf l a

# Commit with message
gwf l c "Fix bug"

# Create review worktree
gwf wt review feature/auth

# Push and create PR
gwf pr p "Add new feature"
```

## Installation

The `gwf` alias is configured in `.bashrc` and `.zprofile`:
```bash
alias gwf="~/scripts/gwf.sh"
```

## Command Categories

### Local (l) - Local Repository Operations

```bash
gwf l a [files]          # Stage files (default: all)
gwf l c "message"        # Commit with message
gwf l s                  # Show status
gwf l d [target]         # Diff against base branch
```

### Remote (r) - Remote Repository Operations

```bash
gwf r ps                 # Push current branch (sets upstream)
gwf r r [branch]         # Pull and rebase (default: main/master)
gwf r pl [branch]        # Pull from remote (default: main/master)
```

### Worktree (wt) - Intelligent Worktree Management

```bash
gwf wt review <branch> [--from=base]    # Create review worktree
gwf wt feature <branch> [--from=base]   # Create feature worktree
gwf wt cleanup <name>                   # Remove worktree
gwf wt list                             # List all worktrees
```

**Worktree Features:**
- ✓ Naming convention: `<repo>-review-<name>` and `<repo>-feature-<name>`
- ✓ Works from any location (main repo or any worktree)
- ✓ Auto-detects main repository location
- ✓ Can cleanup worktree even when inside it
- ✓ Supports `--from=branch` to specify base branch
- ✓ Intelligently checks for existing remote branches before creating new ones
- ✓ Automatically sets up tracking for remote branches

**Examples:**
```bash
# Create review worktree - checks for existing remote branch first
gwf wt review feature/user-auth
# If origin/feature/user-auth exists: Creates tracking branch
# Otherwise: Creates new branch from main
# Creates: ~/repos/data-pipelines-review-user-auth

# Create feature worktree - intelligently handles existing branches
gwf wt feature new-api --from=develop
# If origin/new-api exists: Checks out existing remote branch with tracking
# If local new-api exists: Checks out existing local branch
# Otherwise: Creates new branch from develop
# Creates: ~/repos/data-pipelines-feature-new-api

# Cleanup works from anywhere
gwf wt cleanup user-auth
# Removes the review worktree, even if you're inside it
```

### PR - Pull Request Workflows (requires gh CLI)

```bash
gwf pr c [title]         # Create PR
gwf pr co <number>       # Checkout PR (creates review worktree)
gwf pr ls [options]      # List PRs
gwf pr d [base]          # Preview PR diff
gwf pr p [title]         # Push + create/update PR
```

**PR Examples:**
```bash
# Checkout PR #123 for review
gwf pr co 123
# Fetches PR and creates: ~/repos/data-pipelines-review-pr-123

# Push and create/update PR in one command
gwf pr p "Add dark mode feature"
```

### Inspect (i) - Inspection Commands

```bash
gwf i d [target]         # Show diff (default: vs base branch)
gwf i log [options]      # Show commit log
gwf i show [commit]      # Show commit details
gwf i blame <file>       # Show file blame
```

## Smart Features

### Base Branch Auto-Detection

Commands that need a base branch automatically detect it in this order:
1. `main`
2. `master`
3. `develop`
4. `HEAD`

You can always override:
```bash
gwf l d develop          # Diff against develop
gwf r pr staging         # Rebase onto staging
```

### Intelligent Branch Handling

Both `gwf wt review` and `gwf wt feature` intelligently handle existing branches:

**Priority Order:**
1. **Remote branch exists** → Creates local tracking branch from `origin/<branch>`
2. **Local branch exists** → Checks out existing local branch
3. **Neither exists** → Creates new branch from base (main/master/develop or `--from=` branch)

**Automatic Behavior:**
```bash
# Scenario 1: Remote branch exists (e.g., colleague's branch)
gwf wt feature colleague-branch
# → Fetches latest refs
# → Detects origin/colleague-branch exists
# → Creates local tracking branch: git worktree add ... -b colleague-branch --track origin/colleague-branch
# → Result: Your local branch tracks the remote, no divergence!

# Scenario 2: Only local branch exists
gwf wt feature my-local-work
# → Detects local branch exists
# → Checks out existing local branch: git worktree add ... my-local-work
# → Result: Continues your local work

# Scenario 3: Brand new branch
gwf wt feature brand-new-feature
# → No remote or local branch found
# → Creates new branch from main: git worktree add ... -b brand-new-feature main
# → Result: Fresh branch from base
```

**This fixes the common problem:**
Previously, `gwf wt feature existing-remote-branch` would create a *new* branch from main, causing divergence from the remote branch that already existed. Now it properly checks out and tracks the existing remote branch.

### Worktree Intelligence

The worktree commands are repository-aware:

**From Main Repo:**
```bash
cd ~/repos/data-pipelines
gwf wt feature new-thing
# Creates: ~/repos/data-pipelines-feature-new-thing
```

**From Any Worktree:**
```bash
cd ~/repos/data-pipelines-review-123
gwf wt feature another-thing
# Still creates: ~/repos/data-pipelines-feature-another-thing
```

**Cleanup From Anywhere:**
```bash
cd ~/repos/data-pipelines-review-123
gwf wt cleanup 123
# Removes the current worktree you're in (cd's to main first)
```

### Shorthand Syntax

All categories and common subcommands support shorthand:

| Full Command | Shorthand |
|---|---|
| `gwf local add` | `gwf l a` |
| `gwf local commit` | `gwf l c` |
| `gwf local status` | `gwf l s` |
| `gwf local diff` | `gwf l d` |
| `gwf remote push` | `gwf r ps` |
| `gwf remote rebase` | `gwf r r` |
| `gwf remote pull` | `gwf r pl` |
| `gwf worktree review` | `gwf wt review` |
| `gwf pr create` | `gwf pr c` |
| `gwf pr checkout` | `gwf pr co` |
| `gwf pr list` | `gwf pr ls` |
| `gwf inspect diff` | `gwf i d` |

## Comparison with git-aliases.sh

### Before (git-aliases.sh)
```bash
git-a                    # Stage all
git-c "message"          # Commit
git-d                    # Diff
git-push                 # Push
git-rebase               # Pull and rebase
git-wt-review branch     # Create review worktree
git-wt-cleanup pattern   # Cleanup worktree
```

### After (gwf)
```bash
gwf l a                  # Stage all
gwf l c "message"        # Commit
gwf l d                  # Diff
gwf r ps                 # Push
gwf r r                  # Pull and rebase
gwf wt review branch     # Create review worktree
gwf wt cleanup name      # Cleanup worktree (works from anywhere!)
```

## Configuration

Minimal config stored in `~/repos/dotfiles/.config/gwf/` (optional):
```bash
base_branch=main  # Default base branch
```

## Requirements

- **git** - Required
- **gh** (GitHub CLI) - Optional, needed for PR commands
  - Install: https://cli.github.com/

## Examples

### Daily Workflow
```bash
# Start new feature
gwf wt feature add-auth
cd ~/repos/data-pipelines-feature-add-auth

# Make changes
gwf l a
gwf l c "Add authentication"

# Push and create PR
gwf pr p "Add user authentication"

# Back to main repo
cd ~/repos/data-pipelines

# Cleanup feature worktree
gwf wt cleanup add-auth
```

### Review Workflow
```bash
# Checkout PR for review
gwf pr co 456
cd ~/repos/data-pipelines-review-pr-456

# Review changes
gwf i d
gwf i log --oneline -5

# Done reviewing, cleanup
gwf wt cleanup pr-456
```

### Multi-Worktree Workflow
```bash
# Multiple features in parallel
gwf wt feature frontend-fixes
gwf wt feature backend-api --from=develop
gwf wt review someones-pr

# List all worktrees
gwf wt list

# Cleanup when done
gwf wt cleanup frontend-fixes
gwf wt cleanup backend-api
gwf wt cleanup someones-pr
```

## Files

- `~/scripts/gwf.sh` - Main script
- `~/repos/dotfiles/.config/gwf/` - Config directory (optional)
- `~/.config/gwf` - Symlink to config
- `.bashrc` / `.zprofile` - Shell aliases

## Troubleshooting

**"Not in a git repository"**
- Make sure you're in a git repository
- Check that `.git` exists

**"gh CLI not found"**
- PR commands require GitHub CLI
- Install from https://cli.github.com/

**Worktree detection issues**
- Ensure you're in ~/repos/ directory structure
- Check that main repo follows naming convention

**"Worktree not found"**
- Run `gwf wt list` to see available worktrees
- Check the identifier matches (e.g., `gwf wt cleanup user-auth` not `gwf wt cleanup review-user-auth`)
