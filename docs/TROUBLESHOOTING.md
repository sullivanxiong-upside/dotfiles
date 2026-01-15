# Troubleshooting Guide

Common issues and solutions for dotfiles setup.

## Broken Symlinks After Reorganization

If you upgraded from a previous version of this dotfiles repository (before the reorganization), you may have broken symlinks in your home directory.

### Identifying Broken Symlinks

Find all broken symlinks in your home directory:

```bash
find ~ -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null
```

### Common Broken Symlinks

#### ~/.claude/settings.json

**Problem**: This symlink points to old path that no longer exists after reorganization:
- Old: `~/repos/dotfiles/.claude/settings.json`
- New: `~/repos/dotfiles/home/.claude/settings.json`

**Fix**:

```bash
# Remove broken symlink
rm ~/.claude/settings.json

# Create new symlink to correct location
ln -sf ~/repos/dotfiles/home/.claude/settings.json ~/.claude/settings.json
```

**Note**: Ensure `~/.claude` is a **directory**, not a symlink. Claude Code needs it to be a real directory for runtime data (history, cache, projects, etc.).

#### MCP Server Configuration (mcp.json)

**Problem**: You may have had `~/.claude/mcp.json` symlinked, but Claude Code doesn't read from this file.

**Reality**: Claude Code reads MCP servers from `~/.claude.json` (not a separate `mcp.json` file). The dotfiles repo provides a template at `home/.claude/mcp.json.template` that must be merged into `~/.claude.json`.

**Fix**:

```bash
# Remove old mcp.json symlink if it exists
rm ~/.claude/mcp.json 2>/dev/null

# Merge template into ~/.claude.json
jq --argjson mcp "$(cat ~/repos/dotfiles/home/.claude/mcp.json.template | jq .)" \
   '. + $mcp' ~/.claude.json > ~/.claude.json.tmp && \
   mv ~/.claude.json.tmp ~/.claude.json

# Verify MCP servers loaded
claude mcp list
```

**Why merge instead of symlink?**
- `~/.claude.json` contains both configuration AND runtime state (session data, OAuth tokens, feature flags)
- Claude Code actively writes to this file during operation
- Symlinking would lose your session state or create conflicts
- Template merging separates version-controlled config from runtime state

#### ~/.claude/commands/debug-ci.md and ~/.cursor/commands/debug-ci.md

**Problem**: Symlinks pointing to non-existent files in external repositories.

**Fix**:

```bash
# Remove broken symlinks
rm ~/.claude/commands/debug-ci.md
rm ~/.cursor/commands/debug-ci.md
```

If you need these files, recreate them from the source repository or remove the symlinks if no longer needed.

### Verifying Symlinks Are Fixed

After fixing, verify there are no remaining broken symlinks:

```bash
find ~/.claude ~/.cursor ~/.config -type l ! -exec test -e {} \; -print 2>/dev/null
```

Should return empty output if all symlinks are valid.

## Makefile Installation Issues

### "~/.claude is not a symlink" Warning

**Problem**: Makefile tries to create `~/.claude` as a symlink, but it should be a directory.

**Why**: Claude Code stores runtime data in `~/.claude/` (history, cache, debug logs, projects, etc.). If you symlink the entire directory, you'll lose this data or create conflicts.

**Solution**: Keep `~/.claude` as a regular directory and configure settings properly:

```bash
# Ensure ~/.claude is a directory (not a symlink)
if [[ -L ~/.claude ]]; then
    rm ~/.claude
    mkdir -p ~/.claude
fi

# Symlink settings.json only
ln -sf ~/repos/dotfiles/home/.claude/settings.json ~/.claude/settings.json

# Merge MCP template into ~/.claude.json (do NOT symlink)
jq --argjson mcp "$(cat ~/repos/dotfiles/home/.claude/mcp.json.template | jq .)" \
   '. + $mcp' ~/.claude.json > ~/.claude.json.tmp && \
   mv ~/.claude.json.tmp ~/.claude.json

# Verify
claude mcp list
```

### work/ Scripts Not Found

**Problem**: References to `~/scripts/work/` fail after reorganization.

**Why**: The `work/` directory remains in `~/repos/dotfiles/scripts/work/` (gitignored for private work scripts), and the `~/scripts` symlink makes it accessible.

**Verification**:

```bash
# Check symlink exists
ls -la ~/scripts
# Should show: lrwxr-xr-x ... ~/scripts -> /Users/.../repos/dotfiles/scripts

# Check work directory exists
ls -la ~/scripts/work/
# Should show work-specific scripts
```

If the symlink is missing:

```bash
ln -sf ~/repos/dotfiles/scripts ~/scripts
```

## Shell Configuration Not Loading

### cwf/gwf Commands Not Found

**Problem**: `cwf` or `gwf` commands not found after installation.

**Solution**:

1. Verify symlinks exist:
   ```bash
   ls -la ~/.local/bin/cwf ~/.local/bin/gwf
   ```

2. Ensure `~/.local/bin` is in your PATH:
   ```bash
   echo $PATH | grep ".local/bin"
   ```

3. If not in PATH, add to shell config (should already be in `.zprofile` or `.bashrc`):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

4. Reload shell:
   ```bash
   source ~/.zprofile  # or ~/.bashrc
   ```

### TMUX Configuration Not Loading

**Problem**: TMUX doesn't load configuration after installation.

**Solution**:

1. Verify symlink:
   ```bash
   ls -la ~/.tmux.conf
   # Should point to: ~/repos/dotfiles/home/.tmux.conf
   ```

2. Reload TMUX config in existing session:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

3. Or restart TMUX completely:
   ```bash
   tmux kill-server
   tmux
   ```

## Path Reference Issues

### "No such file or directory" for Dotfiles Paths

**Problem**: Scripts or configs reference old dotfiles paths from before reorganization.

**Common old paths**:
- `~/repos/dotfiles/.config/` → Now: `~/repos/dotfiles/home/.config/`
- `~/repos/dotfiles/scripts/` → Now: `~/repos/dotfiles/bin/`
- `~/repos/dotfiles/.claude/` → Now: `~/repos/dotfiles/home/.claude/`

**Find remaining old references**:

```bash
cd ~/repos/dotfiles
grep -r "repos/dotfiles/\\.config" .
grep -r "repos/dotfiles/scripts" .
grep -r "repos/dotfiles/\\.claude" .
```

Update any found references to the new paths.

## Getting Help

If you encounter issues not covered here:

1. Check the [INSTALLATION.md](INSTALLATION.md) guide
2. Review [MIGRATION.md](MIGRATION.md) for upgrade instructions
3. Open an issue in the repository with:
   - Output of `ls -la ~ | grep ' -> '` (show symlinks)
   - Output of `echo $PATH`
   - Description of the error
   - Steps you've already tried
