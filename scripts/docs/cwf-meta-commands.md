# New Meta-Commands Summary

## Overview

Added a new `new` top-level category with interactive meta-commands for managing the cwf CLI itself. This allows you to extend the CLI through guided conversations with Claude.

## New Commands

### 1. Add Shared Prompt Fragment
```bash
cwf new add-shared
```

**Purpose:** Interactively create a new shared prompt fragment that can be reused across multiple commands.

**What it does:**
- Asks you what the fragment should contain
- Checks if similar functionality already exists
- Helps you choose a template variable name (e.g., `{{NEW_VARIABLE}}`)
- Creates the fragment file in `~/.config/cwf/prompts/shared/`
- Suggests which commands should use the new fragment

### 2. Add Category-Specific Rules
```bash
cwf new add-top-rule <category>
```

**Purpose:** Interactively add rules that apply to all commands within a specific category.

**What it does:**
- Shows existing rules for the category
- Asks what new rule(s) you want to add
- Validates the rule makes sense for that category
- Appends to `~/.claude-<category>-rules`

**Available categories:** `review`, `customer-mgmt`, `feature`, `prepare-release`

**Examples:**
```bash
cwf new add-top-rule review
cwf new add-top-rule feature
```

**Shortcut aliases:**
```bash
# For review category (backward compatible)
claude-review-add-rule "Your rule here"

# For any category
claude-add-rule feature "Always consider performance"
claude-add-rule customer-mgmt "Verify org ID first"
```

### 3. Add Top-Level Category
```bash
cwf new add-top-command
```

**Purpose:** Interactively create a new top-level category (like `review`, `feature`, etc.).

**What it does:**
- Asks what the category should be called
- Asks what its purpose is
- Helps plan initial subcommands
- Creates the directory structure
- Updates `cwf.sh` with routing logic
- Updates documentation
- Creates category-specific rules support

### 4. Add Subcommand
```bash
cwf new add-sub-command <category>
```

**Purpose:** Interactively add a new subcommand to an existing category.

**What it does:**
- Shows existing subcommands in the category
- Asks what the new subcommand should do
- Identifies relevant shared fragments to include
- Creates the prompt file with proper template variables
- Updates `cwf.sh` routing
- Updates documentation

**Examples:**
```bash
cwf new add-sub-command feature
cwf new add-sub-command review
cwf new add-sub-command customer-mgmt
```

### 5. Improve Rules
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

### 6. Improve Workflows
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

**Method 1: Interactive (recommended)**
```bash
cwf new add-top-rule feature
# Claude will guide you through adding the rule
```

**Method 2: Quick command**
```bash
claude-add-rule feature "Always benchmark performance-critical code"
claude-add-rule review "Check for SQL injection vulnerabilities"
```

**Method 3: Legacy (review only)**
```bash
claude-review-add-rule "Ensure all public APIs are documented"
```

## Benefits

✓ **Self-extending CLI** - Extend the CLI through conversation instead of manual editing
✓ **Guided creation** - Claude asks questions to ensure good design
✓ **Validation** - Checks for conflicts with existing commands/fragments
✓ **Consistent patterns** - Follows established conventions automatically
✓ **Category-specific rules** - Each category can have its own guidelines
✓ **Safety** - All meta-commands ask for confirmation before making changes

## Example Workflows

### Adding a New Shared Fragment
```bash
$ cwf new add-shared

Claude: What should this shared fragment contain?
You: Instructions for checking test coverage

Claude: What's the use case for this fragment?
You: I want all feature commands to remind about test coverage

Claude: What should the template variable be called?
You: {{TEST_COVERAGE_CHECK}}

Claude: [Shows proposed content and which commands should use it]
Claude: Do you want to proceed?
You: Yes

Claude: ✓ Created ~/.config/cwf/prompts/shared/test-coverage-check.txt
Claude: Suggested commands to update:
- feature/dp.txt
- feature/cd.txt
- feature/all.txt
```

### Adding a Rule to Feature Category
```bash
$ cwf new add-top-rule feature

Claude: Current rules for feature category:
[Shows existing rules if any]

Claude: What new rule do you want to add?
You: Always consider backward compatibility when modifying APIs

Claude: [Validates and shows proposed rule]
Claude: This rule will apply to: dp, cd, all, general, continue
Claude: Confirm?
You: Yes

Claude: ✓ Added rule to ~/.claude-feature-rules
```

### Adding a New Subcommand
```bash
$ cwf new add-sub-command feature

Claude: Current feature subcommands: dp, cd, all, general, continue
Claude: What should the new subcommand be called?
You: sql

Claude: What should this subcommand do?
You: Work on sql-core-migrations repository features

Claude: [Analyzes and proposes prompt with template variables]
Claude: Should include:
- {{DOCS_INSTRUCTIONS}}
- {{API_PROTO_CHECK}}
- {{REVIEW_AND_UPDATE_DOCS}}

Claude: Confirm this plan?
You: Yes

Claude: ✓ Created ~/.config/cwf/prompts/feature/sql.txt
Claude: ✓ Updated cwf.sh routing
Claude: ✓ Updated documentation
Claude:
Usage: cwf feature sql "Add new migration"
```

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

3. **Prompt Files Created**
   - `~/.config/cwf/prompts/new/add-shared.txt`
   - `~/.config/cwf/prompts/new/add-top-rule.txt`
   - `~/.config/cwf/prompts/new/add-top-command.txt`
   - `~/.config/cwf/prompts/new/add-sub-command.txt`

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
