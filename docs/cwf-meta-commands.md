# New Meta-Commands Summary

## Overview

The `new` top-level category provides meta-commands for managing and improving the cwf CLI itself. These commands help you optimize rule files and improve the workflow tools through guided conversations with Claude.

## New Commands

### 1. Improve Rules
```bash
cwf new improve-rules
```

**Purpose:** Analyze and optimize all category-specific rule files and shared prompt fragments.

**What it does:**
- Discovers all rule files (~/.claude-*-rules) and shared fragments
- Analyzes for bloat, duplication, and clarity issues
- Proposes condensed versions with higher information density
- Creates backups and applies improvements atomically
- Reports size reductions and impact

**Example:**
```bash
cwf new improve-rules
# Optimizes all rules and fragments, reducing context usage
```

### 2. Improve Workflows
```bash
cwf new improve-workflows [context]
```

**Purpose:** Improve the cwf (cwf) and gwf (git workflow) CLI tools themselves.

**What it does:**
- Asks what aspect to improve (cwf, gwf, or both)
- Identifies improvement type (new feature, refactor, bug fix, etc.)
- Analyzes relevant code and documentation
- Proposes detailed implementation plan
- Updates scripts, completion, and documentation together
- Provides testing guidance
- Includes comprehensive checklists for category/command changes

**Examples:**
```bash
# Add new feature
cwf new improve-workflows "Add a new gwf command for stashing changes"

# Fix a bug
cwf new improve-workflows "Fix template variable replacement in cwf.sh"

# Refactor
cwf new improve-workflows "Simplify the completion script generation"

# Improve documentation
cwf new improve-workflows "Add examples to the completion-setup.md"
```

### 3. Improve Repository Knowledge
```bash
cwf new improve-repo-knowledge [repo-name]
```

**Purpose:** Add or improve personal operational knowledge for repositories you work with.

**What it does:**
- Auto-detects current repository from git remote
- Helps document deployment patterns, workflows, and gotchas
- Stores context in `~/.claude/context/{repo-name}/` (hierarchical) or `{repo-name}.md` (single file)
- Provides an index via `{{REPO_CONTEXT_INDEX}}` template variable - Claude reads only what it needs
- Keeps personal knowledge separate from shared repository documentation

**What to document:**
- Deployment architecture and workflows (CI/CD patterns, release process)
- Temporary vs permanent configuration changes
- Emergency procedures (scaling, hotfixes, rollbacks)
- Non-obvious gotchas and quirks
- Integration points with other systems
- Personal workflow tips specific to your work

**Examples:**
```bash
# In data-pipelines repo - auto-detects "data-pipelines"
cwf new improve-repo-knowledge

# Explicitly specify a repo
cwf new improve-repo-knowledge argocd-application-manifests
```

**Context file location:** `~/.claude/context/{repo-name}/` or `~/.claude/context/{repo-name}.md`

**How it's used:**
- Prompts with `{{REPO_CONTEXT_INDEX}}` show an index of available context files
- Claude reads only the files it needs for the task (token efficient)
- Helps cwf understand deployment patterns, gotchas, and workflows specific to each repo
- Personal to you - not shared in team repositories

## Category-Specific Rules System

### How It Works

Each category can now have its own rules file:
- `~/.claude-review-rules` - Rules for review commands
- `~/.claude-customer-mgmt-rules` - Rules for customer-mgmt commands
- `~/.claude-feature-rules` - Rules for feature commands
- `~/.claude-prepare-release-rules` - Rules for release commands

Rules are automatically included in all commands within that category.

### Template Variables for Rules

**In prompt files:**
```text
{{CUSTOM_RULES}}        # Legacy, works the same as CATEGORY_RULES
{{CATEGORY_RULES}}      # Category-specific rules
{{CATEGORY}}            # Current category name (e.g., "review", "feature")
```

**Example prompt using rules:**
```text
Help me review this code.

{{CATEGORY_RULES}}

Additional context: {{EXTRA_DETAILS}}
```

### Adding Rules

**Method 1: Quick command (recommended)**
```bash
claude-add-rule feature "Always benchmark performance-critical code"
claude-add-rule review "Check for SQL injection vulnerabilities"
```

**Method 2: Legacy (review only)**
```bash
claude-review-add-rule "Ensure all public APIs are documented"
```

**Note:** For comprehensive rule improvements across all categories, use `cwf new improve-rules`.

## Benefits

**Rule optimization** - Analyze and improve all rule files for better performance
**Workflow improvement** - Improve cwf/gwf tools through guided conversations with Claude
**Repository knowledge** - Document and auto-load personal operational knowledge per repository
**Guided implementation** - Claude asks questions to understand requirements and proposes detailed plans
**Category-specific rules** - Each category can have its own guidelines
**Safety** - All meta-commands ask for confirmation before making changes

## Technical Details

### Files Modified

1. **cwf.sh** (scripts/work/cwf.sh:71-118)
   - Added `get_category_rules()` function
   - Updated `replace_templates()` to support category-specific rules
   - Added `new` category routing
   - Added `{{CATEGORY}}` and `{{CATEGORY_RULES}}` template variables

2. **claude-aliases.sh** (scripts/work/claude-aliases.sh:86-106)
   - Updated `claude-review-add-rule()` to use new system
   - Added `claude-add-rule()` for any category

3. **Prompt Files**
   - `~/.config/cwf/prompts/new/improve-rules.txt`
   - `~/.config/cwf/prompts/new/improve-workflows.txt`
   - `~/.config/cwf/prompts/new/improve-repo-knowledge.txt`

4. **Documentation Updated**
   - CLAUDE-WORK-README.md - Added meta-commands section
   - Added category-specific rules documentation
   - Added examples for new workflows

### Design Principles

1. **Interactive by design** - All meta-commands ask questions before acting
2. **Safe defaults** - Always confirm before making changes
3. **Validation** - Check for conflicts and suggest alternatives
4. **Guidance** - Explain best practices and conventions
5. **Consistency** - Follow existing patterns automatically
6. **Documentation** - Update docs as part of the process

## Next Steps

Now you can:
1. Use the CLI as before with all existing commands
2. Use meta-commands to extend functionality as needed
3. Add category-specific rules to customize behavior
4. Create new categories and subcommands through conversation

All the old commands still work with full backward compatibility!
