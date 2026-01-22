---
description: Discover available context files and shared prompt rules
allowed-tools:
  - Read
  - Bash(ls:*)
  - Bash(find:*)
  - Bash(tree:*)
---

## Context

- Current repository: !`git rev-parse --show-toplevel 2>/dev/null`
- Current branch: !`git branch --show-current 2>/dev/null`

## Arguments

$ARGUMENTS

Optional: Specific repository name or topic to focus on (e.g., `customer-dashboard`, `monitoring`, `deployment`)

## Your Task

Provide a concise, actionable guide to available context knowledge. The user needs to understand what context exists and how to access it efficiently.

## Context System Structure

Context files are organized in `~/.claude/context/`:

**General context** (applicable to any session):

```
~/.claude/context/*.md
```

Examples:

- `cwf-prompts-library.md` - Complete reference of all cwf workflow prompts and shared rules
- `claude-code-hooks.md` - Claude Code hooks API and notification patterns

**Repository-specific context**:

```
~/.claude/context/{repo-name}/
~/.claude/context/{repo-name}/{group}/
```

Examples:

- `customer-dashboard/monitoring/grafana-investigation.md`
- `data-pipelines/deployment/argocd-setup.md`
- `dotfiles/claude-code-skills.md`

## Step 1: Discover Available Context

Run commands to list available context:

```bash
# List general context files
ls -1 ~/.claude/context/*.md

# List all repositories with context
ls -d ~/.claude/context/*/ | xargs -n 1 basename

# Show structure for specific repo
tree -L 2 ~/.claude/context/{repo-name}/ 2>/dev/null || find ~/.claude/context/{repo-name} -name "*.md" -type f
```

## Step 2: Identify Relevant Context

Based on the current task or user's question, determine which context files are relevant:

**For general Claude Code knowledge:**

- Working with hooks, notifications, or integrations? Read `claude-code-hooks.md`
- Want to know available cwf workflows and shared prompts? Read `cwf-prompts-library.md` and decided for yourself if there are relevant rules/prompts you may want to pull in for youself so that you know more about my preferences and personal style(s).

**For repository-specific work:**

- Investigating errors? Check `{repo}/monitoring/` files
- Deploying changes? Check `{repo}/deployment/` files
- New features? Check `{repo}/architecture/` and `{repo}/services/` files

**Using shared prompts from cwf-prompts-library.md:**

The `cwf-prompts-library.md` documents all shared prompt fragments in `~/.config/cwf/prompts/shared/`. When you identify that a shared prompt would be helpful (e.g., writing-style.txt, upside.txt, git-safety.txt), read it directly:

```bash
Read ~/.config/cwf/prompts/shared/writing-style.txt
```

This allows you to pull in relevant standards and conventions as needed.

## Step 3: Present Findings

Show the user:

1. **What context exists** for their current task
2. **Which files to read** with exact Read commands
3. **Key insights** if files are short (<100 lines)

Format:

```
Current Context: {repo-name} / {topic}

Relevant Context Files:
1. ~/.claude/context/{file}.md
   Brief description of contents

2. ~/.config/cwf/prompts/shared/{file}.txt
   Shared prompt fragment (from cwf-prompts-library reference)

Quick Read Commands:
Read ~/.claude/context/{file}.md
Read ~/.config/cwf/prompts/shared/{file}.txt

Key Information (if file is short):
- Important point 1
- Important point 2
```

## Step 4: Proactive Context Loading

Use your judgment to proactively read relevant context:

**When debugging/investigating:**

- Read monitoring files first
- Check logs/error patterns
- Pull in relevant service documentation

**When deploying:**

- Read deployment workflow files
- Check for gotcas or special procedures

**When writing code or documentation:**

- Read `cwf-prompts-library.md` to find relevant shared prompts
- Pull in `writing-style.txt` if generating text for peers
- Pull in `upside.txt` for Upside coding standards
- Pull in relevant conventions for the task

**When working with git:**

- Pull in `git-safety.txt` from shared prompts

## Guidelines

Keep responses concise and actionable:

- Show 3-5 most relevant files, not everything
- Provide actual Read commands ready to execute
- Extract key insights if files are short
- Link related context files when relevant
- Don't list every file unless asked
- Don't overwhelm with information

Efficiency tips:

- If context file is short, read and summarize key points
- If context file is long, provide path and description
- Group related files together
- Highlight Fast Triage or Quick Reference sections when they exist

## Shared Prompts Discovery

The `cwf-prompts-library.md` is your map to available shared prompts. When you read it, you'll discover:

**Coding Standards:**

- `upside.txt` - Upside Labs conventions
- `code-quality-fundamentals.txt` - General code quality
- `security-best-practices.txt` - Security guidelines
- `runtime-safety.txt` - Error handling patterns

**Workflow Protocols:**

- `git-safety.txt` - Git operations safety
- `github-context.txt` - Using gh CLI
- `worktree-workflow.txt` - Git worktree management
- `workflow-commands.txt` - In-session command switching

**Documentation:**

- `writing-style.txt` - Technical writing guidelines
- `testing-documentation.txt` - Test documentation patterns
- `review-and-update-docs.txt` - When/how to update docs

Use the library to discover what's available, then read the specific shared prompts you need.

## Example Workflow

User asks you to investigate production errors:

1. Run `/context-knowledge monitoring`
2. Discover `customer-dashboard/monitoring/grafana-investigation.md` exists
3. Read that file to get the Fast Triage Protocol
4. Notice it mentions needing to use Grafana MCP efficiently
5. Apply the protocol to investigate the issue

User asks you to write a PR description:

1. Notice you need to generate peer-facing text
2. Read `cwf-prompts-library.md` to find writing guidelines
3. Discover `writing-style.txt` is the relevant shared prompt
4. Read `~/.config/cwf/prompts/shared/writing-style.txt`
5. Apply the no-emoji, concise, factual style
6. Generate the PR description

## Remember

The goal is to help the user acquire context quickly and help you discover relevant standards and conventions. Be selective about what you show and recommend. Use the cwf-prompts-library as your guide to available shared prompts, then pull in the specific ones you need.
