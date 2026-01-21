# gwf Quick Reference Card

A concise reference for the most commonly used `gwf` commands.

## Worktree Management (Most Important!)

```bash
# Create feature worktree
gwf wt feature <branch-name>
gwf wt feature my-feature --from=develop    # from specific base

# Create review worktree
gwf wt review <branch-name>

# Checkout PR for review
gwf pr co <pr-number>

# List all worktrees
gwf wt list

# Remove worktree (when done)
gwf wt cleanup <branch-name>
```

## Common Git Operations

```bash
# Stage all changes
gwf l a

# Stage specific files
gwf l a file1.py file2.py

# Commit
gwf l c "Your commit message"

# Status
gwf l s

# Diff
gwf l d

# Show commits ahead of main
gwf l dc
gwf l dc develop    # ahead of develop

# Push (sets upstream automatically)
gwf r ps

# Pull and rebase
gwf r r
gwf r r develop     # rebase on develop
```

## Pull Request Workflow

```bash
# Push and create/update PR in one command
gwf pr push "PR title"

# Get PR URL for current branch
gwf pr l

# Copy PR URL to clipboard (macOS)
gwf pr l | pbcopy

# List your PRs
gwf pr ls

# Create PR
gwf pr c "PR title"
```

## Inspection Commands

```bash
# Show diff
gwf i d

# Show commit log
gwf i log

# Show last 5 commits
gwf i log --oneline -5

# Show specific commit
gwf i show <commit-hash>

# Show file blame
gwf i blame <file>
```

## Typical Workflows

### Start New Feature
```bash
gwf wt feature my-feature
cd <repo>-feature-my-feature
# ... make changes ...
gwf l a
gwf l c "Implement feature"
gwf pr push "Add new feature"
```

### Review Someone's PR
```bash
gwf pr co 1234
cd <repo>-review-pr-1234
# ... review code, run tests ...
gwf wt cleanup pr-1234
```

### Work on Multiple Features in Parallel
```bash
# Terminal 1
gwf wt feature feature-a
cd <repo>-feature-feature-a
# work on feature-a...

# Terminal 2
gwf wt feature feature-b
cd <repo>-feature-feature-b
# work on feature-b simultaneously
```

### Quick Hotfix While Working on Feature
```bash
# You're in main repo working on something
gwf wt feature hotfix
cd <repo>-feature-hotfix
# fix the bug...
gwf l a
gwf l c "Fix critical bug"
gwf pr push "Hotfix: Fix critical bug"
# Back to main repo - your original work untouched
```

## Category Shortcuts

| Full | Short | Category |
|------|-------|----------|
| `local` | `l` | Local operations |
| `remote` | `r` | Remote operations |
| `worktree` | `wt` | Worktree management |
| `pr` | `pr` | Pull requests |
| `inspect` | `i` | Inspection |

## Configuration (Optional)

```bash
# Setup config for auto-copying local configs
mkdir -p ~/.config/gwf
nano ~/.config/gwf/repos.conf

# Add:
export MAIN_DP="$HOME/repos/data-pipelines"
export MAIN_CDS="$HOME/repos/customer-dashboard"
```

See [gwf-config-example.conf](./gwf-config-example.conf) for full example.

## Help Commands

```bash
gwf --help              # General help
gwf wt --help           # Worktree help
gwf pr --help           # PR help
gwf completion install  # Install shell completion
```

## Common Issues

**"Not in a git repository"**
→ Make sure you're in a git repo directory

**"gh CLI not found"**
→ Install GitHub CLI: `brew install gh` or https://cli.github.com/

**Config files not copying**
→ Configure MAIN_DP/MAIN_CDS in `~/.config/gwf/repos.conf`

**Worktree cleanup fails**
→ Use full worktree name: `gwf wt cleanup pr-1234` not `review-pr-1234`

---

For detailed documentation, see [GWF_SHARING_GUIDE.md](./GWF_SHARING_GUIDE.md)
