# User aliases
alias vim="nvim"
alias ls="ls -lah"
alias ca="cursor-agent"

# Source work-specific configuration (private)
if [[ -f ~/scripts/work/main-work.sh ]]; then
    source ~/scripts/work/main-work.sh
fi

# Source mermaid utility
if [[ -f ~/scripts/mermaid-utility.sh ]]; then
   source ~/scripts/mermaid-utility.sh
fi

# Source Git aliases
if [[ -f ~/scripts/git-aliases.sh ]]; then
    source ~/scripts/git-aliases.sh
fi

# Source grep-recursive function
if [[ -f ~/scripts/grep-recursive.sh ]]; then
    source ~/scripts/grep-recursive.sh
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
