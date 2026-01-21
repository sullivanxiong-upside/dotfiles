# Workflow Commands - Mid-Session Mode Switching

## Overview

The workflow commands feature allows you to switch between different workflow modes **within an existing Claude session** without exiting and starting a new command.

## What Problem Does This Solve?

Previously, if you were working on a feature and wanted to do a peer review, you had to:
1. Exit the current session
2. Run `cwf review review-peer`
3. Start over

Now you can just say **"do a peer review"** in your existing session and Claude will switch modes!

## How It Works

When you start a feature session with:
```bash
cwf feature dp "implement new metric"
```

The `{{WORKFLOW_COMMANDS}}` shared prompt is automatically included, teaching Claude to recognize workflow trigger phrases.

## Available Workflow Commands

### Review Workflows

#### Peer Review
**Triggers:** "do a peer review" | "review these changes" | "review this PR"

**What happens:**
- Reviews every modified file with ratings (1-5)
- Spots issues but doesn't make changes
- Explains changes as if you're seeing them for the first time
- Checks for inline imports (should be minimal)
- Verifies API/proto updates if needed
- Checks documentation is up to date

**Example:**
```
You: do a peer review
Claude: I'll perform a comprehensive peer review...
[Reviews all files with ratings and detailed feedback]
```

#### Address Feedback
**Trigger:** "address feedback: [feedback text]"

**What happens:**
- Reads your feedback carefully
- Makes the requested changes
- Explains what was changed and why

**Example:**
```
You: address feedback: The migration is missing a trailing newline and the docs need updating
Claude: I'll address both issues...
[Makes changes and explains]
```

### Feature Development

#### Continue Feature Work
**Trigger:** "continue feature work"

**What happens:**
- Checks git status and diff
- Identifies what's been done
- Asks clarifying questions before proceeding
- Plans remaining work

**Example:**
```
You: continue feature work
Claude: Let me analyze the current state of this branch...
[Analyzes commits and changes, asks questions]
```

### Release Management

#### Prepare Release Notes
**Trigger:** "prepare release notes"

**What happens:**
- Gets commits between prod and main
- Categorizes as: Customer Impacting / Operational / Bug Fixes
- Formats with PR numbers and Linear tickets

**Example:**
```
You: prepare release notes
Claude: I'll generate release notes from recent commits...
```

### Customer Management

#### Bump Resource
**Trigger:** "bump resource for [customer]"

**What happens:** Handles OOM resource bump workflow

#### Onboard Customer
**Trigger:** "onboard [customer]"

**What happens:** Guides through customer onboarding

#### Regenerate Fields
**Trigger:** "regen fields for [customer]"

**What happens:** Regenerate SFDC query fields

## Real-World Example

```bash
# Start working on a feature
$ cwf feature dp "Add processing_environment to task tables"

Claude: I'll help implement this feature...
[Works on feature]

# Mid-session, you want to review your changes
You: do a peer review

Claude: I'll perform a comprehensive peer review following your cwf review-peer standards...

**Overall Rating: 4.9/5** ⭐⭐⭐⭐⭐
[Detailed review of all files]

# Address the feedback
You: address feedback: Add trailing newline to migration file

Claude: I'll fix the trailing newline issue...
[Makes the change]

# Continue working
You: continue feature work

Claude: The feature is mostly complete. Should we add integration tests?
```

## Technical Details

### Implementation

1. **Shared Prompt:** `~/.config/claude-wf/prompts/shared/workflow-commands.txt`
   - Lists all available workflow modes
   - Explains trigger phrases
   - Describes behavior for each mode

2. **Script Updates:** `~/scripts/claude-wf.sh`
   - Added `WORKFLOW_COMMANDS` to `load_shared_fragments()`
   - Added template replacement for `{{WORKFLOW_COMMANDS}}`

3. **Feature Prompts Updated:**
   - `feature/dp.txt` - data-pipelines
   - `feature/cd.txt` - customer-dashboard
   - `feature/all.txt` - cross-repo
   - `feature/general.txt` - general features
   - `feature/continue.txt` - continue work

### How Claude Recognizes Commands

The `workflow-commands.txt` prompt teaches Claude to recognize specific trigger phrases and apply the appropriate workflow rules when it sees them. It's like having a menu of workflows Claude can switch to on demand.

## Benefits

**No context loss** - Stay in the same session, keep all context
**Faster workflow** - No need to exit and restart
**Natural language** - Just describe what you want to do
**Maintains quality** - Applies full workflow rules, not shortcuts
**Flexible** - Can switch modes multiple times in one session

## Adding New Workflow Commands

To add a new workflow command, edit:
```
~/.config/claude-wf/prompts/shared/workflow-commands.txt
```

Add your new workflow following this pattern:

```text
**Workflow Name:**
- "trigger phrase" → Switch to mode:
  - Behavior 1
  - Behavior 2
  - Behavior 3
```

Claude will automatically recognize new workflows added to this file!

## Tips

1. **Be explicit:** Use the exact trigger phrases for best results
2. **Context matters:** Claude remembers what you've been working on
3. **Combine workflows:** You can use multiple workflows in one session
4. **Ask questions:** Claude can clarify what a workflow does before applying it

## Relationship to Other cwf Features

This complements, not replaces, the standard cwf commands:

- **Use `cwf review review-peer`** when starting a fresh review session
- **Use "do a peer review"** when you're mid-work and want to review
- **Use `cwf feature continue`** to start a planning session
- **Use "continue feature work"** when you're already in a feature session

Both approaches work! Choose based on your context.
