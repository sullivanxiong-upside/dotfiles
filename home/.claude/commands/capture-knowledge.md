---
description: Extract and preserve operational knowledge from conversation into context files
allowed-tools:
  - Read
  - Write
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

Please analyze this entire conversation and extract operational knowledge that should be preserved for future work.

### 1. Identify the repositories involved
Determine which repositories are discussed in this conversation.

### 2. Extract valuable operational knowledge
Including:
- Deployment patterns and workflows
- Service architectures and how components interact
- Gotchas, edge cases, and things that aren't obvious
- Common debugging approaches
- Configuration patterns
- Tool usage patterns
- Anything that would help future work in this area

### 3. Determine the appropriate file structure
- For simple topics: `~/.claude/context/{repo-name}.md`
- For complex repos: `~/.claude/context/{repo-name}/{group}/{file}.md`
- Common groups: `services/`, `jobs/`, `deployment/`, `testing/`, `infrastructure/`

### 4. Create or update the appropriate files
- If files already exist at the path, read them first
- Update existing content or add new sections as appropriate
- Keep each file focused on a single topic
- Use clear section headers and examples

### 5. Provide a summary
- What files you created/updated
- What knowledge was captured
- What full paths to use for future reading

## Guidelines

- **Focus on operational knowledge**, not implementation details
- **Capture the "why" and "how"**, not just the "what"
- **Include concrete examples** when helpful
- **Document gotchas and non-obvious behaviors**
- **Keep it concise** - future Claude should be able to quickly scan and find relevant info
- **Use hierarchical structure** for repos with multiple services/domains

## Example Output Structure

For a deployment-related session:
```
~/.claude/context/data-pipelines/deployment/
├── argocd-application-manifests.md
├── helm-charts.md
├── docker-images.md
└── ci-cd-pipeline.md
```

For a service-specific session:
```
~/.claude/context/data-pipelines/services/
├── llm-analysis-service.md
├── miniapp-serving-service.md
└── feature-generation-service.md
```

## What NOT to Include

- Temporary debugging steps that won't recur
- Implementation code (that's already in the repo)
- One-time setup instructions (those go in repo docs)
- Personal notes or task tracking

## After Creating Files

Verify the files were created correctly:
```bash
ls -la ~/.claude/context/{repo-name}/
```

And test the index generation:
```bash
cd ~/repos/{repo-name}
bash -c 'source ~/repos/dotfiles/bin/cwf; get_repo_context_index'
```
