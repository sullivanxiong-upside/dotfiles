# Shell Completion Setup for cwf and gwf

This guide explains the elegant, cross-platform completion setup following shell best practices.

## Design Philosophy

Our completion system follows these principles:
- **Cross-platform**: Native support for both Bash and Zsh (no translation layers)
- **Lazy loading**: Completions load on-demand for faster shell startup (Zsh)
- **Simple**: Minimal configuration, maximum reliability
- **Best practices**: Based on official shell documentation and community standards

## How It Works

### Zsh (Lazy Loading)

Zsh uses a **lazy loading pattern** where completion functions are loaded only when you first press TAB, not at shell startup. This dramatically improves init performance.

**Pattern:**
1. Register a lightweight "lazy loader" function with `compdef`
2. On first TAB press, the lazy loader:
   - Removes itself to avoid recursion
   - Loads the full completion script
   - Calls the real completion function
3. Subsequent completions use the now-loaded real function

**Reference:** [Lazy loading completions - Frederic Hemberger](https://frederic-hemberger.de/notes/speeding-up-initial-zsh-startup-with-lazy-loading/)

### Bash (Immediate Loading)

Bash loads completions immediately at startup since it doesn't have a native lazy loading mechanism like zsh's `compdef` system.

## Installation

### Commands in PATH (Required)

Both `cwf` and `gwf` must be available in your `$PATH`:

```bash
# Already done via symlinks:
~/.local/bin/cwf -> ~/repos/dotfiles/bin/cwf
~/.local/bin/gwf -> ~/repos/dotfiles/bin/gwf
```

Verify:
```bash
which cwf  # Should show: ~/.local/bin/cwf
which gwf  # Should show: ~/.local/bin/gwf
```

### Zsh Setup

Add to your `.zshrc` or sourced config file (e.g., `~/.config/zsh/user.zsh`):

```bash
# Lazy load gwf completion
if command -v gwf &>/dev/null; then
  _gwf_lazy_load() {
    unfunction _gwf_lazy_load
    source <(gwf completion zsh) 2>/dev/null
    _gwf "$@"
  }
  compdef _gwf_lazy_load gwf
fi

# Lazy load cwf completion
if command -v cwf &>/dev/null; then
  _cwf_lazy_load() {
    unfunction _cwf_lazy_load
    source <(cwf completion zsh) 2>/dev/null
    _claude_wf "$@"
  }
  compdef _cwf_lazy_load cwf
fi
```

**Important:** This must load AFTER `compinit` is called (usually in `.zshrc`).

### Bash Setup

Add to your `.bashrc`:

```bash
# Source bash completions if config file exists
if [ -f ~/.config/bash/completions.bash ]; then
  source ~/.config/bash/completions.bash
fi
```

The `~/.config/bash/completions.bash` file contains:

```bash
# Load gwf completion if command exists
if command -v gwf &>/dev/null; then
  source <(gwf completion bash) 2>/dev/null || true
fi

# Load cwf completion if command exists
if command -v cwf &>/dev/null; then
  source <(cwf completion bash) 2>/dev/null || true
fi
```

## Testing

### Verify Installation

**Zsh:**
```bash
# Check lazy loaders are registered
echo $_comps[cwf]  # Should show: _cwf_lazy_load
echo $_comps[gwf]  # Should show: _gwf_lazy_load

# Test completion (press TAB)
cwf <TAB>
gwf <TAB>

# After first TAB, verify real completion loaded
echo $_comps[cwf]  # Should show: _claude_wf
echo $_comps[gwf]  # Should show: _gwf
```

**Bash:**
```bash
# Check completion is registered
complete -p cwf
complete -p gwf

# Test completion (press TAB)
cwf <TAB>
gwf <TAB>
```

### Performance Testing (Zsh)

Measure shell startup time:

```bash
# Time 10 shell startups
for i in {1..10}; do time zsh -ic exit; done
```

With lazy loading, completion scripts don't execute until first use, saving ~50-200ms per script at startup.

## Architecture Benefits

### ✅ Cross-Platform Native
- Zsh uses native `compdef` (not bashcompinit wrapper)
- Bash uses native `complete` (no translation layer)
- Each shell gets optimal, idiomatic completions

### ✅ Performance Optimized
- Zsh: Lazy loading means faster startup (0ms cost until first TAB)
- Bash: Single load at startup (typical ~10-30ms per script)
- No redundant `compinit` calls

### ✅ Reliable
- Commands in PATH (not aliases) ensures consistent availability
- Error handling with `2>/dev/null || true` prevents failures
- Works in all shell contexts (login, non-login, interactive, scripts)

### ✅ Maintainable
- Single source of truth: completion generators in cwf/gwf scripts
- Self-documenting: inline comments explain the pattern
- Standards-based: follows official shell documentation

## Troubleshooting

### Zsh: Completion doesn't work

1. **Check lazy loader is registered:**
   ```bash
   echo $_comps[cwf]  # Should show _cwf_lazy_load
   ```

2. **Verify compinit was called:**
   ```bash
   type compdef  # Should show it's a function
   ```

3. **Check load order:** Ensure user.zsh loads AFTER compinit in .zshrc

4. **Clear completion cache:**
   ```bash
   rm ~/.zcompdump*
   exec zsh
   ```

### Bash: Completion doesn't work

1. **Check bash_completion is available:**
   ```bash
   type _init_completion
   ```

2. **Verify completion is registered:**
   ```bash
   complete -p cwf
   ```

3. **Source completions manually:**
   ```bash
   source ~/.config/bash/completions.bash
   ```

### Commands not found

Ensure symlinks exist and are executable:
```bash
ls -la ~/.local/bin/{cwf,gwf}
chmod +x ~/.local/bin/{cwf,gwf}
```

Ensure `~/.local/bin` is in PATH:
```bash
echo $PATH | tr ':' '\n' | grep local/bin
```

## References

**Zsh Best Practices:**
- [zsh Completion System Documentation](https://zsh.sourceforge.io/Doc/Release/Completion-System.html)
- [Lazy loading completions](https://frederic-hemberger.de/notes/speeding-up-initial-zsh-startup-with-lazy-loading/)
- [Fixing Zsh Tab Completion](https://blog.tannerb.dev/blog/zsh-tab-completion-fix)
- [Speed up zsh compinit](https://gist.github.com/ctechols/ca1035271ad134841284)

**Cross-Platform:**
- [Writing Your Own Simple Tab-Completions for Bash and Zsh](https://mill-build.org/blog/14-bash-zsh-completion.html)
- [zsh-bash-completions-fallback](https://github.com/3v1n0/zsh-bash-completions-fallback)

**Bash Completion:**
- [bash-completion Documentation](https://github.com/scop/bash-completion)
- [Programmable Completion](https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html)
