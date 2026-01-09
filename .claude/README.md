# Claude Code Configuration

This directory contains configuration files for [Claude Code](https://code.claude.com/).

## Files

### settings.json
Core Claude Code settings:
- **includeCoAuthoredBy**: Set to `false` to disable "Co-Authored-By" footers in git commits
- **statusLine**: Custom status line configuration (displays Claude processing status in tmux)

### mcp.json
MCP (Model Context Protocol) server configurations. This file is used as a template for setting up MCP servers in your environment.

**Note**: MCP servers are configured per-user in `~/.claude.json` (managed by Claude Code). This `mcp.json` file serves as a reference configuration that was migrated from Cursor.

## MCP Servers

The following MCP servers are configured:

### Playwright
- **Type**: stdio
- **Command**: `npx -y @playwright/mcp@latest`
- **Purpose**: Browser automation and testing
- **Status**: ✓ Ready

### Linear
- **Type**: SSE (Server-Sent Events)
- **URL**: https://mcp.linear.app/sse
- **Purpose**: Linear issue tracking integration
- **Authentication**: Requires authentication via `/mcp` command in Claude Code
- **Status**: ⚠ Needs authentication

### Notion
- **Type**: HTTP
- **URL**: https://mcp.notion.com/mcp
- **Purpose**: Notion workspace integration
- **Authentication**: Requires authentication via `/mcp` command in Claude Code
- **Status**: ⚠ Needs authentication

### GitHub
- **Type**: stdio
- **Command**: `npx -y @modelcontextprotocol/server-github`
- **Purpose**: GitHub repository operations, issue management, PR workflows
- **Authentication**: May require `GITHUB_TOKEN` environment variable for private repos
- **Status**: Requires GitHub Personal Access Token

### Grafana (Staging & Production)
- **Type**: stdio
- **Command**: `uv run --directory ~/repos/data-pipelines scripts/grafana_mcp_server/server.py --environment <stage|prod>`
- **Purpose**: Query AWS Managed Grafana dashboards, datasources, PromQL, and CloudWatch Logs
- **Prerequisites**:
  - VPN connection required
  - AWS CLI with SSO configured (`awslogin`)
  - `uv` (Python package manager)
  - data-pipelines repository cloned at `~/repos/data-pipelines`
- **Available Tools**:
  - Dashboard search and inspection
  - Datasource listing
  - PromQL query execution (instant and range)
  - CloudWatch Logs Insights queries
  - Log group discovery and log context retrieval
- **Environments**:
  - `grafana-staging`: Staging environment
  - `grafana-prod`: Production environment
- **Status**: ✓ Staging connected (when VPN + AWS authenticated)

## Setup Instructions

### 1. Install Configuration Files

```bash
# Create Claude directory and symlink settings
mkdir -p ~/.claude
ln -sf ~/repos/dotfiles/.claude/settings.json ~/.claude/settings.json
```

### 2. Configure MCP Servers

**Option A: Using CLI (Recommended)**

Add MCP servers using the `claude mcp add` command:

```bash
# Add Playwright (stdio transport)
claude mcp add --transport stdio --scope user playwright -- npx -y @playwright/mcp@latest

# Add Linear (SSE transport)
claude mcp add --transport sse --scope user linear https://mcp.linear.app/sse

# Add Notion (HTTP transport)
claude mcp add --transport http --scope user notion https://mcp.notion.com/mcp

# Add GitHub (requires GITHUB_TOKEN environment variable)
claude mcp add --transport stdio --scope user github -- npx -y @modelcontextprotocol/server-github

# Add Grafana staging (requires VPN + AWS auth)
claude mcp add --transport stdio --scope user grafana-staging -- uv run --directory ~/repos/data-pipelines scripts/grafana_mcp_server/server.py --environment stage

# Add Grafana production (requires VPN + AWS auth)
claude mcp add --transport stdio --scope user grafana-prod -- uv run --directory ~/repos/data-pipelines scripts/grafana_mcp_server/server.py --environment prod
```

**Option B: Manual Configuration**

Edit `~/.claude.json` and add the `mcpServers` section. However, using the CLI is recommended as it handles the configuration format correctly.

### 3. Authenticate MCP Servers

#### Linear and Notion
For OAuth-based authentication:

```bash
# In Claude Code, use the /mcp command
/mcp

# Or authenticate via CLI
claude mcp auth linear
claude mcp auth notion
```

#### GitHub
Create a GitHub Personal Access Token and add it to your shell profile:

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Select scopes: `repo`, `read:org`, `read:user`
4. Copy the token
5. Add to your `~/.bashrc` or `~/.zprofile`:
   ```bash
   export GITHUB_TOKEN="your_token_here"
   ```
6. Reload your shell: `source ~/.bashrc` or `source ~/.zprofile`

#### Grafana
Requires AWS CLI authentication and VPN connection:

```bash
# Authenticate with AWS SSO
awslogin

# Ensure you're connected to VPN
# Then Claude Code will automatically use your AWS credentials
```

### 4. Verify Configuration

```bash
# List configured MCP servers and check their status
claude mcp list

# Get details for a specific server
claude mcp get playwright
```

## Managing MCP Servers

### List all servers
```bash
claude mcp list
```

### Get server details
```bash
claude mcp get <server-name>
```

### Remove a server
```bash
claude mcp remove <server-name>
```

### Update a server
```bash
# Remove the old configuration
claude mcp remove <server-name>

# Add the new configuration
claude mcp add --transport <type> --scope user <server-name> <command-or-url>
```

## Configuration Scopes

Claude Code supports three configuration scopes:

- **user** (recommended): Available across all projects for this user (`~/.claude.json`)
- **project**: Shared with team, checked into version control (`.mcp.json` at project root)
- **local** (default): Private to your local project (`~/.claude.json` in project directory)

## Troubleshooting

### MCP server not connecting
1. Check server status: `claude mcp list`
2. Verify the command/URL is correct: `claude mcp get <server-name>`
3. Check authentication status for HTTP servers
4. Restart Claude Code

### Authentication issues
- Use `/mcp` command within Claude Code
- Or use `claude mcp auth <server-name>` from terminal
- Some servers may require API keys set via environment variables

#### GitHub-specific issues
```bash
# If GitHub MCP fails to connect, check GITHUB_TOKEN
echo $GITHUB_TOKEN  # Should output your token

# If empty, add to your shell profile:
export GITHUB_TOKEN="your_token_here"
source ~/.bashrc  # or ~/.zprofile
```

#### Grafana-specific issues
```bash
# Check VPN connection
# Grafana requires private network access

# Verify AWS authentication
awslogin
aws sts get-caller-identity

# Check data-pipelines repository exists
ls ~/repos/data-pipelines/scripts/grafana_mcp_server/

# Test Grafana server manually
uv run --directory ~/repos/data-pipelines scripts/grafana_mcp_server/server.py --environment stage
```

### Server needs updating
```bash
# For stdio servers using npx, the @latest tag auto-updates
# For HTTP servers, they're managed by the service provider

# To manually update a server:
claude mcp remove <server-name>
claude mcp add --transport <type> --scope user <server-name> <updated-command-or-url>
```

## Resources

- [Claude Code Documentation](https://code.claude.com/)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/)
- [Playwright MCP](https://github.com/microsoft/playwright)
- [Linear MCP](https://linear.app/)
- [Notion MCP](https://www.notion.so/)
- [GitHub MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [Grafana MCP Server](~/repos/data-pipelines/scripts/grafana_mcp_server/README.md) (internal)
