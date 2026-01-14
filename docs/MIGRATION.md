# Migration Guide: Old Structure → New Structure

If you've been using the old dotfiles structure, here's how to migrate.

## What Changed

### Directory Changes
- `scripts/` → `bin/` (and removed .sh extensions)
- Top-level dotfiles → `home/`
- `scripts/docs/` → `docs/`
- `tmux-plugins/tmux-claude-status/` → Separate repo (install via TPM)
- `wallpapers/` → `assets/wallpapers/`

### Installation Changes
- Manual symlinks → Makefile automation (`make install`)
- tmux-claude-status vendored → TPM installation

## Migration Steps

### 1. Backup Your Current Setup

```bash
# Backup existing symlinks
ls -la ~ | grep ' -> ' > ~/dotfiles-backup-symlinks.txt

# Backup current configs
cp ~/.bashrc ~/.bashrc.backup
cp ~/.zprofile ~/.zprofile.backup
cp ~/.tmux.conf ~/.tmux.conf.backup
```

### 2. Remove Old Symlinks

```bash
# Remove old dotfiles symlinks
rm ~/.bashrc ~/.zprofile ~/.tmux.conf
rm -rf ~/.config/nvim ~/.config/cwf ~/.config/gwf ~/.claude ~/.cursor
rm ~/.local/bin/cwf ~/.local/bin/gwf
```

### 3. Pull Latest Changes

```bash
cd ~/repos/dotfiles
git pull origin main
```

### 4. Install Using New Structure

```bash
make install
```

### 5. Update .tmux.conf for tmux-claude-status

Edit `~/.tmux.conf` (or `home/.tmux.conf` in repo) and replace:

```bash
# Old (vendored plugin):
run-shell ~/repos/dotfiles/tmux-plugins/tmux-claude-status/tmux-claude-status.tmux

# New (TPM plugin):
set -g @plugin 'SullivanXiong/tmux-claude-status'
```

Then in tmux: `Ctrl+A` then `I` to install plugins.

### 6. Update PATH if Needed

Ensure `~/.local/bin` is in your PATH. Check:

```bash
echo $PATH | grep "\.local/bin"
```

If not present, it's set in `.bashrc` or `.zprofile` (should be automatic).

### 7. Verify Installation

```bash
# Test shell configs
which cwf gwf  # Should show ~/.local/bin/cwf and ~/.local/bin/gwf

# Test tmux plugin
tmux new-session -d -s test
tmux list-windows -t test  # Should show Claude status in window name
tmux kill-session -t test

# Test Neovim
nvim +checkhealth +q
```

### 8. Clean Up Old Directories (Optional)

The old `scripts/` and `tmux-plugins/` directories are now gone. Git should handle cleanup, but if you have uncommitted changes:

```bash
# Check for uncommitted work-specific scripts
ls -la ~/repos/dotfiles-old/scripts/work/

# Move them to new location if needed
cp ~/repos/dotfiles-old/scripts/work/* ~/repos/dotfiles/bin/work/
```

## Troubleshooting

**Issue**: cwf or gwf not found
**Solution**: Ensure `~/.local/bin` is in PATH and symlinks exist:
```bash
ls -l ~/.local/bin/cwf ~/.local/bin/gwf
```

**Issue**: tmux-claude-status not working
**Solution**: Install via TPM (see step 5 above)

**Issue**: Configs not loading
**Solution**: Check symlinks point to correct paths:
```bash
ls -l ~/.bashrc ~/.zprofile ~/.config
```

**Issue**: Work scripts missing
**Solution**: They're now in `bin/work/` (same content, new location)

## Rollback

If you need to rollback:

```bash
cd ~/repos/dotfiles
git checkout <previous-commit-hash>
# Re-create old symlinks manually
```

## Need Help?

Open an issue in the repository with:
- What you were trying to do
- Error messages
- Output of `ls -la ~ | grep ' -> '`
