# Scripts Directory

This directory contains two main CLI tools for workflow automation:

## Tools

### cwf (Claude Workflow CLI) - Claude Workflow CLI
A unified CLI for managing Claude-powered workflows with organized categories, shared prompts, and self-extending capabilities.

### gwf - Git Workflow CLI
A bash wrapper around git commands with organized categories, intelligent worktree management, and shorthand syntax.

## Quick Start

```bash
# Usage
cwf <category> <subcommand> [context...]

# Get help
cwf --help

# Examples
cwf review review-peer "Focus on error handling"
cwf feature dp "Add new metric aggregation"
cwf new add-sub-command feature
```

## Installation

Both tools are available in your PATH via symlinks:
```bash
~/.local/bin/cwf -> ~/repos/dotfiles/scripts/cwf.sh
~/.local/bin/gwf -> ~/repos/dotfiles/scripts/gwf.sh
```

Shell completion is configured using lazy-loading (Zsh) or immediate-loading (Bash) patterns. See **[docs/completion-setup.md](docs/completion-setup.md)** for detailed setup and cross-platform configuration.

## Command Categories

### Review
- `review-peer` - Review PR changes with ratings
- `address-feedback` - Address peer feedback on current branch

### Customer Management
- `bump-resource` - Handle OOM resource bump workflow
- `regen-fields` - Regenerate customer SFDC query fields
- `onboard` - Onboard a new customer

### Feature Development
- `dp` - Work on data-pipelines feature
- `cd` - Work on customer-dashboard feature
- `all` - Cross-repo feature (dp + cd + sql-core-migrations)
- `general` - General feature work outside main repos
- `continue` - Analyze current branch and plan next steps
- `plan` - Plan feature implementation with detailed exploration

### Agent (Research and Learning)
- `chat` - Research and learn about specific topics with expert guidance

### Release
- `prepare-release` - Generate release notes from prod to main

### Meta Commands (Self-Extending)
- `add-shared` - Interactively add shared prompt fragments
- `add-top-rule <category>` - Add category-specific rules
- `add-top-command` - Create new top-level categories
- `add-sub-command <category>` - Add subcommands to categories
- `improve-rules` - Analyze and optimize all rule files and shared fragments
- `improve-workflows` - Improve the cwf/gwf workflow tools themselves

## Automatic Worktree Management

`cwf` integrates with `gwf` to automatically manage worktrees for code review and feature development workflows.

### How It Works

When you run `cwf review` or `cwf feature`, Claude will:

1. **Detect your branch name** from:
   - Linear ticket (via MCP if available)
   - Current git branch (`git branch --show-current`)
   - Your prompt text (e.g., "Review branch sul-123-fix-bug")

2. **Check your location**:
   - Feature work expects: `~/repos/${repo}-feature-${branch}`
   - Review work expects: `~/repos/${repo}-review-${branch}`

3. **Create worktree if needed**:
   - Uses `gwf wt feature <branch>` for features
   - Uses `gwf wt review <branch>` for reviews
   - Changes to the worktree directory
   - Continues with your task

### Examples

**Already in worktree (most common):**
```bash
cd ~/repos/data-pipelines-feature-sul-123-my-feature
cwf feature dp "Implement new aggregation logic"
# Claude detects you're already in correct worktree, proceeds immediately
```

**Need to create worktree:**
```bash
cd ~/repos/data-pipelines
git checkout sul-456-another-feature
cwf feature dp "Continue working on this feature"
# Claude detects branch sul-456-another-feature
# Creates ~/repos/data-pipelines-feature-sul-456-another-feature
# Changes to that directory
# Proceeds with feature work
```

**Review someone's PR:**
```bash
cd ~/repos/customer-dashboard
cwf review review-peer "Review branch john-789-fix-bug"
# Claude extracts branch name from prompt
# Creates ~/repos/customer-dashboard-review-john-789-fix-bug
# Changes to that directory
# Proceeds with review
```

### Requirements

- `gwf` must be available in PATH (should be at ~/.local/bin/gwf)
- Must be in a git repository
- Branch name must be detectable or provided in prompt

### Smart Behavior

Claude intelligently handles:
- **Already in correct worktree (99% case)**: Proceeds silently
- **Branch detection from multiple sources**: Linear MCP > git > prompt text
- **Existing worktrees**: Just changes directory, no recreation
- **Failed detection**: Asks you for branch name or continues in current directory
- **Non-git repos**: Skips worktree logic entirely

## GitHub CLI Context Gathering (MCP-Like)

`cwf` teaches Claude to use the GitHub CLI (`gh`) to proactively gather rich context about PRs, issues, commits, and repositories - mimicking what an MCP integration would provide automatically.

### How It Works

Claude will intelligently use `gh` commands to gather context BEFORE making recommendations:

**For PR Reviews:**
- `gh pr view` - Get PR details, author, status, checks
- `gh pr diff` - See what changed
- `gh pr checks` - Verify CI/CD status
- `gh pr view --json reviews,comments` - Read existing feedback

**For Feature Development:**
- `gh pr status` - Check if PR exists for current branch
- `gh issue list --assignee @me` - See your assigned issues
- `gh pr list --author @me` - See your PRs
- `gh run list` - Check CI/CD workflow status

**For Repository Context:**
- `gh repo view` - Get repo info, default branch, languages
- `gh api` - Query GitHub API for detailed information
- Extract Linear ticket IDs from branch names or PR bodies

### Benefits

✅ **Comprehensive Context**: Claude knows PR status, CI checks, review comments
✅ **Informed Decisions**: Makes recommendations based on actual GitHub state
✅ **No Assumptions**: Queries GitHub instead of guessing
✅ **Linear Integration**: Can extract Linear ticket IDs from branches/PRs
✅ **Proactive**: Gathers context automatically during review/feature workflows

### Example Context Gathering

When you run `cwf review review-peer`, Claude will:

```bash
# 1. Check if in a PR branch
gh pr view --json number,title,state,mergeable,statusCheckRollup

# 2. Get the PR diff
gh pr diff

# 3. Check CI status
gh pr checks

# 4. Read existing review comments
gh pr view --json reviews,comments

# 5. Then provide informed review feedback
```

When you run `cwf feature continue`, Claude will:

```bash
# 1. Check current branch
git branch --show-current

# 2. See if PR exists
gh pr view --json number,title,state

# 3. Get your related issues
gh issue list --assignee @me --state open

# 4. Check recent commits
git log --oneline -10

# 5. Then help you continue work with full context
```

### Requirements

- `gh` CLI must be installed and authenticated
- Run `gh auth login` if not already authenticated
- Works in any GitHub repository

## Configuration

### Directory Structure
```
# Config stored in dotfiles repo, symlinked to ~/.config/
~/repos/dotfiles/.config/cwf/
├── prompts/
│   ├── shared/           # Reusable prompt fragments
│   ├── review/
│   ├── customer-mgmt/
│   ├── feature/
│   ├── agent/
│   ├── new/
│   └── prepare-release.txt

# Symlink for access
~/.config/cwf -> ~/repos/dotfiles/.config/cwf

# Category-specific rules (optional)
~/.claude-review-rules
~/.claude-customer-mgmt-rules
~/.claude-feature-rules
~/.claude-prepare-release-rules
```

### Template Variables

Prompts support these template variables:
- `{{DOCS_INSTRUCTIONS}}` - Documentation reading patterns
- `{{DESIGN_PATTERNS}}` - Design pattern considerations
- `{{API_PROTO_CHECK}}` - API/proto file checking
- `{{FILE_READING_REMINDER}}` - File reading reminders
- `{{REVIEW_AND_UPDATE_DOCS}}` - Auto doc updates
- `{{CATEGORY_RULES}}` - Category-specific rules
- `{{CATEGORY}}` - Current category name

## Adding Rules

Add rules that apply to all commands in a category:

```bash
# Quick add
cwf new add-top-rule review

# Or edit directly
echo "All API calls should have proper error handling" >> ~/.claude-review-rules
```

## Examples

### Review Code
```bash
cwf review review-peer "Focus on security vulnerabilities"
```

### Continue Feature Work
```bash
cwf feature continue "Should I refactor or continue current approach?"
```

### Plan Feature Implementation
```bash
cwf feature plan "Plan implementation for adding real-time notifications"
```

### Research and Learn
```bash
cwf agent chat "How do I implement distributed caching with Redis?"
cwf agent chat "Best practices for GraphQL API design"
```

### Cross-Repo Feature
```bash
cwf feature all "Add user activity tracking across all services"
```

### Add New Subcommand
```bash
cwf new add-sub-command feature
# Claude guides you through creating the new subcommand interactively
```

### Generate Release Notes
```bash
cwf prepare-release
```

### Handling Special Characters and Quotes

When passing context with quotes or special characters, you have several options:

**Option 1: Use stdin with heredoc (RECOMMENDED - No quote escaping needed!)**
```bash
cwf review review-peer <<'EOF'
The PR description says "Introduce an internal FastAPI service"
Uses 'any' quotes and `backticks` without escaping
Multiple lines work perfectly!
EOF
```

**Option 2: Pipe content directly**
```bash
echo 'Content with "any" quotes' | cwf review review-peer

# Combine with git commands
git log main..HEAD --oneline --no-merges | cwf review review-peer
```

**Option 3: Use single quotes for arguments (prevents shell interpolation)**
```bash
cwf review review-peer 'the pr says "Introduce new feature"'
```

**Option 4: Escape inner quotes**
```bash
cwf review review-peer "the pr says \"Introduce new feature\""
```

**Option 5: Mix quote styles**
```bash
cwf review review-peer "the pr says 'single quotes' and we're done"
```

**Option 6: Combine arguments and stdin**
```bash
# Arguments provide context, stdin provides the main content
cwf review review-peer "Focus on security" <<'EOF'
PR changes include "authentication" and 'authorization'
EOF
```

**Tip:** Options 1 and 2 (stdin) are the most flexible and avoid all quoting issues!

## Architecture

The CLI is built with:
- **Modularity** - Shared prompts eliminate duplication
- **Extensibility** - Add commands through conversation
- **Consistency** - All commands follow the same patterns
- **Self-documenting** - Meta-commands update docs automatically

## Documentation

Detailed documentation for both tools:
- **[docs/completion-setup.md](docs/completion-setup.md)** - Cross-platform shell completion (Bash & Zsh)
- **[docs/gwf.md](docs/gwf.md)** - Git workflow CLI (gwf) complete guide
- **[docs/cwf-meta-commands.md](docs/cwf-meta-commands.md)** - Meta-commands for extending cwf
- **[docs/workflow-commands.md](docs/workflow-commands.md)** - Mid-session mode switching

## Files

### cwf (Claude Workflow CLI)
- `~/scripts/cwf.sh` - Main CLI implementation
- `~/repos/dotfiles/.config/cwf/` - Config directory (in dotfiles repo)
- `~/.config/cwf` - Symlink to dotfiles config

### gwf
- `~/scripts/gwf.sh` - Main script
- `~/repos/dotfiles/.config/gwf/` - Config directory (optional)
- `~/.config/gwf` - Symlink to config

### Shared
- `~/.local/bin/{cwf,gwf}` - Symlinks to scripts (in PATH)
- `~/.config/zsh/user.zsh` - Zsh completion (lazy-loading)
- `~/.config/bash/completions.bash` - Bash completion
- `~/scripts/README.md` - This file
