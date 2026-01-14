# User aliases
alias vim="nvim"
alias ls="ls -lah"
alias ca="cursor-agent"
# Note: cwf and gwf are symlinked in ~/.local/bin (no aliases needed)

# Source work-specific configuration (private)
if [[ -f ~/scripts/work/main-work.sh ]]; then
    source ~/scripts/work/main-work.sh
fi

# Source mermaid utility
if [[ -f ~/repos/dotfiles/bin/mermaid-utility ]]; then
   source ~/repos/dotfiles/bin/mermaid-utility
fi

# Source Git aliases
if [[ -f ~/repos/dotfiles/bin/git-aliases ]]; then
    source ~/repos/dotfiles/bin/git-aliases
fi

# Source grep-recursive function
if [[ -f ~/repos/dotfiles/bin/grep-recursive ]]; then
    source ~/repos/dotfiles/bin/grep-recursive
fi

# Source python-utility
if [[ -f ~/repos/dotfiles/bin/python-utility ]]; then
    source ~/repos/dotfiles/bin/python-utility
fi

# Path
export PATH="$HOME/.local/bin:$PATH"
export WORDCHARS="${WORDCHARS//\//}"

# Disable OSC color queries
printf '\e]10;?\a' 2>/dev/null | cat > /dev/null
printf '\e]11;?\a' 2>/dev/null | cat > /dev/null

# Source TMUX initialization
if [[ -f ~/scripts/work/tmux-init.sh ]]; then
    source ~/scripts/work/tmux-init.sh
fi

