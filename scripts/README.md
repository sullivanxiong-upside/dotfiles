# Scripts Directory

This directory contains two main CLI tools for workflow automation:

## Tools

### claude-wf (cwf) - Claude Workflow CLI
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

## Configuration

### Directory Structure
```
# Config stored in dotfiles repo, symlinked to ~/.config/
~/repos/dotfiles/.config/claude-wf/
├── prompts/
│   ├── shared/           # Reusable prompt fragments
│   ├── review/
│   ├── customer-mgmt/
│   ├── feature/
│   ├── agent/
│   ├── new/
│   └── prepare-release.txt

# Symlink for access
~/.config/claude-wf -> ~/repos/dotfiles/.config/claude-wf

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

### claude-wf (cwf)
- `~/scripts/cwf.sh` - Main CLI implementation
- `~/repos/dotfiles/.config/claude-wf/` - Config directory (in dotfiles repo)
- `~/.config/claude-wf` - Symlink to dotfiles config

### gwf
- `~/scripts/gwf.sh` - Main script
- `~/repos/dotfiles/.config/gwf/` - Config directory (optional)
- `~/.config/gwf` - Symlink to config

### Shared
- `~/.local/bin/{cwf,gwf}` - Symlinks to scripts (in PATH)
- `~/.config/zsh/user.zsh` - Zsh completion (lazy-loading)
- `~/.config/bash/completions.bash` - Bash completion
- `~/scripts/README.md` - This file
