# Architecture and Design Decisions

This document explains the structure and organization of this dotfiles repository.

## Structure Overview

```
dotfiles/
├── home/          # Files symlinked to ~/
├── bin/           # Executable scripts (in PATH)
├── macos/         # macOS-specific configs
├── linux/         # Linux-specific configs
├── assets/        # Wallpapers, images
├── packages/      # Package manager manifests
├── docs/          # All documentation
├── test/          # Test scripts
└── .github/       # CI/CD workflows
```

## Design Principles

### 1. Clear Separation of Concerns
- `home/` contains ONLY files that are symlinked to home directory
- `bin/` contains ONLY executable scripts
- Platform-specific code isolated in `macos/` and `linux/`
- Documentation centralized in `docs/`

### 2. XDG Base Directory Compliance
- All application configs in `home/.config/`
- Follows modern Linux/Unix standards
- Cross-platform compatibility

### 3. Automated Installation
- Makefile handles OS detection and symlinking
- Idempotent operations (can run multiple times safely)
- Modular targets (install just shell, just tools, etc.)

### 4. Personal vs. Reusable Components
- **Personal tools** (cwf, gwf): Kept in dotfiles, not designed for general use
- **Reusable components** (tmux-claude-status): Split into separate repos
- Clear boundary based on "independent lifecycle" rule

### 5. AI-Native Development
- Claude Code integration in `home/.claude/`
- Multiple MCP servers pre-configured
- Real-time AI status monitoring (via separate tmux plugin)

## Why This Structure?

Based on research of 11 well-known dotfiles repositories, this structure follows modern best practices:

- **webpro/dotfiles**: Inspired by organized by purpose (bin/, config/, macos/)
- **paulirish/dotfiles**: MCP integration pattern
- **erikw/dotfiles**: Comprehensive XDG compliance
- **jessfraz/dotfiles**: System-level configuration approach

## Migration from Previous Structure

**Old structure:**
- Flat with `.config/`, `scripts/`, `tmux-plugins/` at root
- Less clear boundaries

**New structure:**
- `home/` directory for all symlinked files
- `bin/` for executables (no .sh extensions)
- Clear separation

**Benefits:**
- Easier to understand at a glance
- More maintainable
- Better for automation (Makefile can target specific directories)
- Aligns with industry standards

## File Organization

### home/ Directory
Contains all files that are symlinked to `~/`:
- Shell configurations (`.bashrc`, `.zprofile`, `.tmux.conf`)
- XDG configs (`.config/`)
- AI/IDE configs (`.claude/`, `.cursor/`)

### bin/ Directory
Executable scripts added to PATH:
- No `.sh` extensions (cleaner in PATH)
- Made executable via `chmod +x`
- Built-in completion (use `gwf completion install` or `cwf completion install`)

### Platform-Specific Directories
- `macos/` - macOS-specific configs and Library/ files
- `linux/` - Linux-specific configs and installation scripts

### Documentation
All docs in `docs/`:
- Installation guides
- Architecture documentation
- Migration guides
- Tool-specific documentation

## Installation Process

The Makefile orchestrates installation:

1. **OS Detection**: Automatically detects macOS or Linux
2. **Target Selection**: User chooses what to install
3. **Symlink Creation**: Links files from repo to home directory
4. **Platform Scripts**: Runs OS-specific setup if requested

Example:
```bash
make install          # Install all components
make install-shell    # Install just shell configs
make install-tools    # Install just cwf/gwf
```

## Testing Strategy

### ShellCheck Validation
- Runs on all `.sh` files
- Checks scripts without extensions (cwf, gwf, etc.)
- Catches common shell scripting errors

### Structure Validation
- Verifies required files exist
- Checks for accidental secrets in repo
- Runs in CI/CD on every PR

### GitHub Actions
- Runs tests automatically on PR and push to main
- Prevents merging if tests fail
- Validates both shellcheck and structure

## AI Integration

### Claude Code
- Configuration in `home/.claude/`
- MCP servers for Playwright, Linear, Notion, GitHub, etc.
- Settings persist across machines

### tmux-claude-status
- Extracted to separate repository
- Installed via TPM (Tmux Plugin Manager)
- Real-time status monitoring in tmux tabs

### Workflow Tools
- `cwf` (Claude Workflow): Category-based command launcher
- `gwf` (Git Workflow): Worktree and PR management
- Both integrate with Claude Code for AI-assisted development

## Future Considerations

- **Secrets management**: May integrate 1Password or similar
- **Package management**: May add Brewfile, pacman file automation
- **Testing**: Expand test coverage beyond ShellCheck
- **Documentation**: Keep docs/ updated as structure evolves

## Related Documentation

- [Installation Guide](./INSTALLATION.md) - Setup instructions
- [Migration Guide](./MIGRATION.md) - Migrating from old structure
- [Contributing](../CONTRIBUTING.md) - How to contribute
- [License](../LICENSE) - MIT License
