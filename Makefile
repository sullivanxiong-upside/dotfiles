# Makefile for dotfiles installation
# Supports: macOS, Linux (Arch, Ubuntu)

.PHONY: help install install-shell install-tmux install-neovim install-tools install-desktop test clean

# Default target
help:
	@echo "Dotfiles Installation"
	@echo ""
	@echo "Usage:"
	@echo "  make install          Install all components"
	@echo "  make install-shell    Install shell configs only"
	@echo "  make install-tmux     Install TMUX config"
	@echo "  make install-neovim   Install Neovim config"
	@echo "  make install-tools    Install cwf/gwf CLI tools"
	@echo "  make install-desktop  Install Linux desktop (Linux only)"
	@echo "  make test             Run tests (ShellCheck)"
	@echo "  make clean            Remove symlinks"
	@echo ""
	@echo "Detected OS: $(shell uname)"

# Detect OS
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	OS := macos
else ifeq ($(UNAME), Linux)
	OS := linux
else
	OS := unknown
endif

# Full installation
install: install-shell install-tmux install-neovim install-tools
	@echo "✓ Installation complete for $(OS)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Restart your shell or run: source ~/.bashrc (or ~/.zprofile)"
	@echo "  2. Install TMUX Plugin Manager: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
	@echo "  3. In TMUX, press Ctrl+A followed by I to install plugins"
	@echo "  4. For Claude Code MCP servers, see docs/INSTALLATION.md"
ifeq ($(OS), linux)
	@echo "  5. For Linux desktop environment, run: make install-desktop"
endif

# Shell configuration
install-shell:
	@echo "→ Installing shell configuration..."
	@ln -sf $(PWD)/home/.bashrc ~/.bashrc
	@ln -sf $(PWD)/home/.zprofile ~/.zprofile
	@echo "  ✓ Shell configs linked"

# TMUX configuration
install-tmux:
	@echo "→ Installing TMUX configuration..."
	@ln -sf $(PWD)/home/.tmux.conf ~/.tmux.conf
	@echo "  ✓ TMUX config linked"
	@echo "  ⚠ Remember to install TPM and tmux-claude-status plugin"

# Neovim configuration
install-neovim:
	@echo "→ Installing Neovim configuration..."
	@mkdir -p ~/.config
	@ln -sf $(PWD)/home/.config/nvim ~/.config/nvim
	@echo "  ✓ Neovim config linked"

# CLI tools (cwf, gwf)
install-tools:
	@echo "→ Installing CLI tools..."
	@mkdir -p ~/.local/bin ~/.config
	@ln -sf $(PWD)/bin/cwf ~/.local/bin/cwf
	@ln -sf $(PWD)/bin/gwf ~/.local/bin/gwf
	@chmod +x ~/.local/bin/cwf ~/.local/bin/gwf
	@ln -sf $(PWD)/home/.config/cwf ~/.config/cwf
	@ln -sf $(PWD)/home/.config/gwf ~/.config/gwf
	@ln -sf $(PWD)/home/.config/cursor ~/.config/cursor
	@ln -sf $(PWD)/home/.config/kitty ~/.config/kitty
	@ln -sfn $(PWD)/home/.cursor ~/.cursor
	@echo "  ✓ cwf and gwf installed to ~/.local/bin"
	@echo "  ✓ Config directories linked"
	@echo ""
	@echo "  NOTE: ~/.claude must remain a directory (not a symlink) for Claude Code runtime data."
	@echo "  To use dotfiles settings:"
	@echo "    1. Symlink settings: ln -sf $(PWD)/home/.claude/settings.json ~/.claude/settings.json"
	@echo "    2. Merge MCP template: jq --argjson mcp \"\$$(cat $(PWD)/home/.claude/mcp.json.template | jq .)\" '. + \$$mcp' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json"
	@echo "    3. Verify MCP: claude mcp list"
	@echo ""
	@echo "  ⚠ Ensure ~/.local/bin is in your PATH"

# Linux desktop environment (Linux only)
install-desktop:
ifeq ($(OS), macos)
	@echo "⚠ Desktop environment installation is Linux-only"
else
	@echo "→ Installing Linux desktop environment..."
	@ln -sf $(PWD)/home/.config/hypr ~/.config/hypr
	@ln -sf $(PWD)/home/.config/waybar ~/.config/waybar
	@ln -sf $(PWD)/home/.config/rofi ~/.config/rofi
	@ln -sf $(PWD)/home/.config/swaync ~/.config/swaync
	@ln -sf $(PWD)/home/.config/kitty ~/.config/kitty
	@ln -sf $(PWD)/home/.config/cava ~/.config/cava
	@echo "  ✓ Desktop configs linked"
	@echo "  ⚠ Install required packages: see docs/INSTALLATION.md"
endif

# macOS-specific installation
install-macos:
ifeq ($(OS), macos)
	@echo "→ Installing macOS-specific configs..."
	@mkdir -p ~/Library/Application\ Support
	@ln -sf $(PWD)/macos/Library/* ~/Library/
	@echo "  ✓ macOS configs linked"
	@bash macos/install-macos.sh
else
	@echo "⚠ macOS installation only available on macOS"
endif

# Run tests
test:
	@echo "→ Running tests..."
	@bash test/shellcheck.sh

# Clean (remove symlinks)
clean:
	@echo "→ Removing symlinks..."
	@rm -f ~/.bashrc ~/.zprofile ~/.tmux.conf
	@rm -f ~/.local/bin/cwf ~/.local/bin/gwf
	@rm -f ~/.config/nvim ~/.config/cwf ~/.config/gwf ~/.config/cursor ~/.config/kitty
	@rm -f ~/.claude ~/.cursor
	@echo "  ✓ Symlinks removed"
