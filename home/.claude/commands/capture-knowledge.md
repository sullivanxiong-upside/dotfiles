---
description: Extract and preserve operational knowledge from conversation into context files and cwf prompts
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash(ls:*)
  - Bash(mkdir:*)
  - Bash(git rev-parse:*)
  - Bash(git branch:*)
---

## Context

- Current repository: !`git rev-parse --show-toplevel 2>/dev/null`
- Current branch: !`git branch --show-current 2>/dev/null`

## Arguments

$ARGUMENTS

If a repository name is provided, focus knowledge extraction on that repository. Otherwise, analyze the entire conversation and extract knowledge for all relevant repositories.

## Your Task

Analyze this conversation and extract operational knowledge that should be preserved for future work. This includes both repository-specific context AND improvements to cwf workflows and shared prompts.

### 1. Identify what type of knowledge was gained

**Repository-specific operational knowledge:**
- Deployment patterns and workflows
- Service architectures and how components interact
- Gotchas, edge cases, and things that aren't obvious
- Common debugging approaches
- Configuration patterns
- Tool usage patterns

**Workflow and standards improvements:**
- Better patterns for feature development, review, or customer workflows
- New coding standards or conventions discovered
- Security patterns that should be codified
- Git workflow improvements
- Documentation or writing style refinements
- Testing patterns that should be standardized

### 2. Repository Context Files

For repository-specific operational knowledge:

**File structure:**
- Simple topics: `~/.claude/context/{repo-name}.md`
- Complex repos: `~/.claude/context/{repo-name}/{group}/{file}.md`
- General knowledge: `~/.claude/context/{topic}.md`
- Common groups: `services/`, `jobs/`, `deployment/`, `testing/`, `infrastructure/`, `monitoring/`

**Process:**
1. Read existing files if they exist
2. Update or add new sections as appropriate
3. Keep each file focused on a single topic
4. Use clear section headers and examples

### 3. CWF Prompt Improvements

For workflow patterns and coding standards that should be captured:

**Shared prompt fragments** (`~/.config/cwf/prompts/shared/`):

These are reusable standards injected into workflows via `{{VARIABLES}}`:

- `upside.txt` - Upside Labs coding conventions (use existing shared libraries, constructor purity, etc.)
- `code-quality-fundamentals.txt` - General code quality principles
- `security-best-practices.txt` - Security guidelines (SQL injection, XSS, etc.)
- `runtime-safety.txt` - Error handling patterns
- `git-safety.txt` - Git operations safety protocol
- `github-context.txt` - Using gh CLI for context gathering
- `worktree-workflow.txt` - Git worktree management
- `workflow-commands.txt` - In-session command switching
- `writing-style.txt` - Technical writing guidelines
- `testing-documentation.txt` - Test documentation patterns
- `performance-database.txt` - Database query optimization
- `design-patterns.txt` - Common design patterns and anti-patterns

**When to update shared prompts:**
- Discovered new security vulnerability patterns
- Found better error handling approaches
- Learned new git safety protocols
- Refined coding conventions
- Improved writing or documentation standards
- Identified new performance patterns

**Workflow prompts** (`~/.config/cwf/prompts/{category}/`):

These define workflow-specific behaviors:

- `feature/` - Feature development workflows (dp, cd, all, dotfiles, etc.)
- `review/` - Code review and feedback workflows
- `customer-mgmt/` - Customer-specific workflows (bump-resource, onboard, etc.)
- `agent/` - Research and orchestration
- `new/` - Creation workflows (add-skill, improve-repo-knowledge, etc.)

**When to update workflow prompts:**
- Found more efficient workflow patterns
- Discovered better ways to structure feature work
- Improved review process patterns
- Enhanced customer management workflows

**Process for updating prompts:**
1. Read the existing prompt file
2. Identify the specific section that needs improvement
3. Update with the new pattern or standard
4. Preserve the existing structure and format
5. Update `~/.claude/context/cwf-prompts-library.md` if you added new prompts

### 4. Provide a comprehensive summary

List what was captured:
- Repository context files created/updated
- CWF shared prompts updated (with what improvement)
- CWF workflow prompts updated (with what improvement)
- Full paths for future reading

## Guidelines

**For repository context:**
- Focus on operational knowledge, not implementation details
- Capture the "why" and "how", not just the "what"
- Include concrete examples when helpful
- Document gotchas and non-obvious behaviors
- Keep it concise - future Claude should quickly find relevant info
- Use hierarchical structure for repos with multiple services/domains

**For cwf prompt improvements:**
- Only update prompts when the improvement is generalizable
- Preserve existing structure and format
- Be specific about what changed and why
- Test that updated prompts still work in context
- Don't duplicate - if it fits in shared prompt, don't put in workflow prompt
- Update cwf-prompts-library.md if adding new prompts

## Example Output Structure

**Repository context:**
```
~/.claude/context/data-pipelines/deployment/
├── argocd-application-manifests.md
├── helm-charts.md
└── ci-cd-pipeline.md

~/.claude/context/customer-dashboard/monitoring/
└── grafana-investigation.md
```

**General context:**
```
~/.claude/context/
├── claude-code-hooks.md
└── cwf-prompts-library.md
```

**CWF prompt updates:**
```
~/.config/cwf/prompts/shared/
├── security-best-practices.txt  (added new XSS prevention pattern)
├── git-safety.txt               (added worktree cleanup protocol)
└── writing-style.txt            (refined PR review format)

~/.config/cwf/prompts/feature/
└── dp.txt                       (added better testing workflow)
```

## What NOT to Include

**In repository context:**
- Temporary debugging steps that won't recur
- Implementation code (that's already in the repo)
- One-time setup instructions (those go in repo docs)
- Personal notes or task tracking

**In cwf prompts:**
- One-off fixes or workarounds
- Repository-specific patterns (those go in context files)
- Temporary workflow adjustments
- Preferences that aren't generalizable

## Self-Improvement Pattern

When you notice during a session that:
- You made the same mistake multiple times
- A pattern emerged that should be standardized
- You discovered a better approach than what's in prompts
- A security or quality issue was preventable with better standards

Then capture that improvement into the appropriate prompt file.

**Example 1: Security Issue**
During development, you wrote code vulnerable to SQL injection, then fixed it.
→ Check `~/.config/cwf/prompts/shared/security-best-practices.txt`
→ Add specific pattern to prevent this in future

**Example 2: Workflow Improvement**
During feature work, you found a better way to structure test development.
→ Check `~/.config/cwf/prompts/feature/dp.txt`
→ Add the improved pattern to testing workflow

**Example 3: Writing Style**
During PR review, you used emojis but shouldn't have.
→ Check `~/.config/cwf/prompts/shared/writing-style.txt`
→ Already has "no emojis" rule - this was a mistake, not a prompt gap

## After Creating/Updating Files

**IMPORTANT: Update the context library index**

After creating or updating ANY repository context files, you MUST update the library README:

1. Read `~/.claude/context/README.md`
2. Update the "Available Repository Context" table:
   - Add new repositories that don't exist in the table
   - Update the context files list if structure changed
   - Update the description if focus areas changed
3. This ensures `/context-knowledge` can discover available context

**Verify repository context:**
```bash
ls -la ~/.claude/context/{repo-name}/
```

**Verify library index is updated:**
```bash
# Confirm the repository is listed in the README
grep -A1 "{repo-name}" ~/.claude/context/README.md
```

**Verify cwf prompt updates:**
```bash
# Read the updated prompt to confirm changes
Read ~/.config/cwf/prompts/shared/{file}.txt

# Test that it still loads correctly in cwf
cd ~/repos/{repo-name}
bash -c 'source ~/repos/dotfiles/bin/cwf; get_repo_context_index'
```

**Update cwf-prompts-library.md if needed:**
If you added new prompts or significantly changed existing ones, update the library reference:
```bash
Read ~/.claude/context/cwf-prompts-library.md
# Add/update relevant sections
```
