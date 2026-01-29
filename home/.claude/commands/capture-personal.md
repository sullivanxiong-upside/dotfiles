---
description: Capture personal knowledge about people, relationships, and preferences to Memory MCP and personal context files
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash(ls:*)
  - Bash(mkdir:*)
  - mcp__memory__create_entities
  - mcp__memory__create_relations
  - mcp__memory__add_observations
  - mcp__memory__search_nodes
  - mcp__memory__read_graph
---

## Arguments

$ARGUMENTS

Optional: Specific topic or person to focus on (e.g., `org structure`, `Alice`, `communication preferences`)

## Your Task

Analyze this conversation and extract **personal knowledge** that should be preserved. This command focuses on relational knowledge about people, teams, and personal context - not technical/repository knowledge.

### What to Capture

**People and relationships:**
- Names, roles, and titles
- Reporting structure / org hierarchy
- Working relationships and collaborations
- Team memberships

**Communication and preferences:**
- Communication styles (prefers async, likes direct feedback, etc.)
- Work preferences (morning person, prefers written docs, etc.)
- Meeting patterns
- Feedback preferences

**Personal context:**
- Notes about yourself (your role, responsibilities, goals)
- Reminders and things to remember
- Personal workflows and habits

### 1. Memory MCP Knowledge Graph

Use the Memory MCP for structured relational knowledge.

**Entity types:**
- `Person` - People you work with or know
- `Team` - Teams and groups
- `Company` - Companies and organizations
- `Project` - Projects and initiatives

**Relation types:**
- `reports to` - Org hierarchy
- `works at` - Employment
- `works on` - Project assignments
- `leads` - Leadership roles
- `collaborates with` - Working relationships
- `member of` - Team membership

**Process:**
1. Search existing entities first: `mcp__memory__search_nodes` to avoid duplicates
2. Create new entities: `mcp__memory__create_entities`
3. Create relations: `mcp__memory__create_relations`
4. Add observations to existing entities: `mcp__memory__add_observations`

**Example - Capturing org structure:**
```json
// Entities
{"name": "Alice Smith", "entityType": "Person", "observations": ["Senior Engineer", "Reports to Bob", "Prefers async communication"]}
{"name": "Bob Jones", "entityType": "Person", "observations": ["Engineering Manager", "Direct and candid style"]}

// Relations
{"from": "Alice Smith", "to": "Bob Jones", "relationType": "reports to"}
{"from": "Alice Smith", "to": "Engineering", "relationType": "member of"}
```

**Example - Capturing preferences:**
```json
// Add to existing person
{"entityName": "Bob Jones", "contents": ["Prefers reading docs over being walked through things", "Values being challenged in discussions"]}
```

### 2. Personal Context Files

For longer-form personal notes, use `~/.claude/context-personal/`:

**File structure:**
- `~/.claude/context-personal/relationships.md` - People and org notes
- `~/.claude/context-personal/personal.md` - Personal notes and reminders
- `~/.claude/context-personal/{topic}.md` - Topic-specific notes

**Process:**
1. Read existing file if it exists
2. Update or add new sections
3. Keep it organized with clear headers

**Example - relationships.md:**
```markdown
# Relationships

## Org Structure

- Alice reports to Bob (Engineering Manager)
- Bob reports to Carol (VP Engineering)

## Communication Preferences

### Bob Jones
- Prefers async communication
- Likes direct, candid feedback
- Processes information better by reading than listening
```

### 3. Provide Summary

After capturing, list:
- Memory MCP entities created/updated
- Memory MCP relations created
- Personal context files created/updated
- Key observations added

## Guidelines

**For Memory MCP:**
- Search before creating to avoid duplicates
- Use consistent entity names (full names preferred)
- Keep observations factual and concise
- Use active voice for relations ("reports to" not "is reported to by")

**For context files:**
- Keep files focused and organized
- Use clear section headers
- Include dates if relevant (e.g., "As of Jan 2026")
- Don't duplicate what's in Memory MCP - use files for longer notes

## What NOT to Capture

- Technical knowledge (use `/capture-knowledge` instead)
- Repository-specific information
- Temporary or one-time information
- Sensitive information that shouldn't be written down

## Verification

After creating/updating:

```bash
# Check personal context files
ls -la ~/.claude/context-personal/

# Verify Memory MCP (use the tools)
mcp__memory__search_nodes with relevant query
```
