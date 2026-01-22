---
description: Summarize current Claude session and save to Documents folder
allowed-tools:
  - Read
  - Write(~/Documents/*)
  - Write(~/Desktop/*)
  - Write(/tmp/*)
  - Bash(test:*)
  - Bash(tmux:*)
  - Bash(date:*)
  - Bash(pwd:*)
  - Bash(mkdir:*)
  - Bash(git:*)
  - Bash(jq:*)
  - Bash(wc:*)
  - Bash(head:*)
  - Bash(tail:*)
  - Bash(cat:*)
---

## Context

- In tmux?: !`test -n "$TMUX" && echo "yes" || echo "no"`
- Tmux window name: !`test -n "$TMUX" && tmux display-message -p '#W' || echo "N/A"`
- Current working directory: !`pwd`
- Current repository: !`git rev-parse --show-toplevel 2>/dev/null || echo "Not in git repo"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "N/A"`
- Git status: !`git status --short 2>/dev/null | head -10 || echo "N/A"`
- Current timestamp: !`date '+%Y-%m-%d %H:%M:%S'`
- Recent session history: !`tail -n 30 ~/.claude/history.jsonl 2>/dev/null | jq -r 'select(.type == "user_message") | .timestamp + " | " + (.text | split("\n")[0] | .[0:80])' || echo "History not available"`

## Arguments

$ARGUMENTS

**Filename Resolution Priority:**
1. If `$ARGUMENTS` provided → Use as filename
2. Else if in tmux → Use tmux window name
3. Else → Prompt user interactively

**Sanitization:**
- Replace spaces with hyphens
- Remove special characters (keep alphanumeric, hyphens, underscores)
- Lowercase
- If result is empty → Use `claude-summary-<timestamp>`

**Output Path:**
- Default: `~/Documents/<filename>.md`
- Fallback if `~/Documents` unwritable: `~/Desktop/<filename>.md`
- Final fallback: `/tmp/<filename>.md`

## Your Task

Generate a comprehensive summary of the current Claude session and save it to the appropriate location. The summary should be detailed enough for a new Claude session to pick up exactly where this one left off.

### Step 1: Determine Output Filename

1. Apply filename resolution priority (from Arguments section)
2. If prompting user, use clear format:
   ```
   Not in tmux and no filename provided.
   Please provide a filename for the summary (without .md extension):
   ```
3. Sanitize the filename according to rules above
4. Construct full path: `~/Documents/<sanitized-filename>.md`
5. Ensure `~/Documents/` directory exists:
   ```bash
   mkdir -p ~/Documents
   ```
6. Test write access, use fallback paths if needed

### Step 2: Analyze Session Context

Review the entire conversation in memory and identify:

- What the user was trying to accomplish
- What work was completed
- What commands were run
- What files were modified
- What research was done
- What problems were encountered
- What decisions were made and why
- What's left to do

Also extract key information from the Context section above (git repo, branch, working directory, etc.)

### Step 3: Generate Comprehensive Summary

Create a markdown document with the following structure. Be thorough and detailed - aim for 3000-5000 words for complex sessions.

**Template:**

```markdown
# Claude Session Summary

**Date:** <timestamp from context>
**Working Directory:** <pwd from context>
**Repository:** <git repo from context>
**Branch:** <git branch from context>

---

## 1. Overview

Write 2-3 paragraphs summarizing:
- What this session was about
- What the user was trying to accomplish
- What was achieved
- Current state at end of session

Be specific - mention key files, features, or issues discussed.

---

## 2. Goals and Objectives

List the main goals the user expressed or that emerged during the session:

- Goal 1: Description
- Goal 2: Description
- ...

Mark completed goals with ✅, incomplete with ⬜, partially complete with 🔄

---

## 3. Work Completed

### Files Created
- `path/to/file1.ext` - Brief description of purpose
- `path/to/file2.ext` - Brief description of purpose

### Files Modified
- `path/to/file3.ext` - What changed and why
- `path/to/file4.ext` - What changed and why

### Commands Run
```bash
# Command 1 - Purpose
command args

# Command 2 - Purpose
command args
```

### Key Code Changes

Include 2-5 most important code snippets (10-30 lines each) that represent the core work:

**File: `path/to/file.ext` (lines X-Y)**
```language
<code snippet>
```
*Significance: Why this code matters / what it does*

---

## 4. Research and Exploration

What areas were investigated during the session:

- **Topic 1:** What was researched, what was learned
- **Topic 2:** What was researched, what was learned
- ...

Include any codebase exploration, documentation reading, or investigation done.

---

## 5. Attempts and Failures

**CRITICAL SECTION** - Document what didn't work to avoid repeating mistakes:

### Attempt 1: [Brief Title]
- **What was tried:** Description
- **Why it failed:** Specific error or issue
- **Lesson learned:** What to avoid

### Attempt 2: [Brief Title]
- **What was tried:** Description
- **Why it failed:** Specific error or issue
- **Lesson learned:** What to avoid

---

## 6. Key Decisions and Rationale

Document important decisions made during the session:

### Decision 1: [Title]
- **Context:** Why the decision was needed
- **Options considered:**
  - Option A: Pros/cons
  - Option B: Pros/cons
- **Decision:** What was chosen
- **Rationale:** Why this choice was made

### Decision 2: [Title]
- (Same structure)

---

## 7. Outstanding Issues

### Open Questions
- Question 1: Description
- Question 2: Description

### Known Bugs
- Bug 1: Description and current status
- Bug 2: Description and current status

### Incomplete Work
- Task 1: What's left to do
- Task 2: What's left to do

---

## 8. Next Steps

### Immediate Actions (Do First)
1. Action 1 - Clear description
2. Action 2 - Clear description

### Medium-Term Goals
- Goal 1: Description
- Goal 2: Description

### Long-Term Considerations
- Consideration 1: Description
- Consideration 2: Description

---

## 9. Context for New Session

**What a new Claude session needs to know:**

### Current State
- Describe the exact state of the project/feature at session end
- List key files to review first
- Note any temporary state or setup

### Setup Commands
```bash
# Commands to run to get environment ready
cd /path/to/repo
source .envrc
# etc.
```

### Key Files to Review
1. `path/to/file1.ext` - Why this file is important
2. `path/to/file2.ext` - Why this file is important

### Mental Model
Explain the architecture or approach so a new session can understand the design:
- How components interact
- Key patterns being used
- What to keep in mind when continuing work

---

## 10. User Prompts Log

Chronological record of user prompts from `~/.claude/history.jsonl`:

1. `<timestamp>` - <first line of prompt>
2. `<timestamp>` - <first line of prompt>
3. ...

(Include last 20-30 prompts, or all if session was short)

---

## 11. Additional Notes

Any other relevant information that doesn't fit above sections:
- Links to documentation
- Related PRs or issues
- Team members consulted
- External resources used
- Tips for future work

---

**End of Summary**
```

### Step 4: Handle File Appending

1. Check if output file already exists:
   ```bash
   test -f ~/Documents/<filename>.md && echo "exists" || echo "new"
   ```

2. If file exists:
   - Read the existing content
   - Add a clear separator:
   ```markdown

   ---
   ---

   # NEW SESSION: <timestamp>

   ---
   ---

   ```
   - Append the new summary below
   - Write the combined content back

3. If file is new:
   - Write the summary directly

### Step 5: Provide User Feedback

After successfully writing the file:

1. **Show the file path:**
   ```
   ✅ Session summary saved to: ~/Documents/<filename>.md
   ```

2. **Display statistics:**
   ```bash
   # Word count
   wc -w ~/Documents/<filename>.md

   # Line count
   wc -l ~/Documents/<filename>.md

   # Number of prompts analyzed
   tail -30 ~/.claude/history.jsonl | jq -s 'map(select(.type == "user_message")) | length'
   ```

   Format as:
   ```
   📊 Summary statistics:
   - Words: <count>
   - Lines: <count>
   - Prompts analyzed: <count>
   ```

3. **Show preview:**
   ```bash
   head -30 ~/Documents/<filename>.md
   ```

   Format as:
   ```
   📄 Preview (first 30 lines):

   <preview content>

   ...
   ```

4. **Suggest usage:**
   ```
   💡 To use this summary in a new session:

   1. Copy the file path: ~/Documents/<filename>.md
   2. In new Claude session, attach the file or paste relevant sections
   3. Say: "Please review this summary and continue where we left off"

   Or use shell command:
   cat ~/Documents/<filename>.md | claude --resume
   ```

## Edge Cases and Error Handling

### Case: Not in tmux, no argument provided
- Prompt user for filename interactively
- Wait for user input
- If user provides empty input, use `claude-summary-<timestamp>`

### Case: history.jsonl unavailable
- Note in summary: "Session history unavailable, prompts log incomplete"
- Use conversation context in memory for summary
- Continue with summary generation

### Case: Cannot write to ~/Documents
- Try fallback: `~/Desktop/<filename>.md`
- If that fails, try: `/tmp/<filename>.md`
- Report actual path used in feedback

### Case: File exists but unreadable
- Offer timestamped filename: `<original>-<timestamp>.md`
- Or try alternative location
- Report issue to user

### Case: Filename only special characters
- After sanitization results in empty string
- Use fallback: `claude-summary-<timestamp>.md`
- Inform user of filename change

### Case: Very long session (>100 prompts)
- Prioritize recent work in summary
- Condense repetitive prompts in log
- Note: "Long session - focused on recent work"

### Case: No git repository
- Skip git-related sections
- Use absolute file paths instead of repo-relative
- Note: "Not in git repository" in metadata

### Case: Multiple working directories used
- Organize work by directory in summary
- Specify which directory for each file/command
- Note directory changes in context section

## Philosophy

**Never fail completely.** If any part of the process encounters an error:
- Note the limitation in the summary
- Continue with remaining sections
- Use fallback values where appropriate
- Always provide *some* output with clear notes about what's missing

The goal is to capture as much context as possible, even if not perfect. A 90% complete summary is far more valuable than no summary at all.

## Quality Guidelines

- **Be thorough:** 3000-5000 words is appropriate for complex sessions
- **Include code:** Liberally include relevant code snippets
- **Capture failures:** The "Attempts and Failures" section is critical
- **Think about continuity:** What would you want to know if picking this up tomorrow?
- **Use absolute paths:** Always use full paths, not relative
- **Be specific:** "Modified auth logic in src/auth.py:45-67" not "Fixed auth"
- **Explain decisions:** Not just what was done, but why
- **Note blockers:** What's preventing progress on incomplete tasks
- **Link context:** How does this work relate to larger project goals

Remember: This summary is for your future self (or another Claude session). Write what you would want to read.
