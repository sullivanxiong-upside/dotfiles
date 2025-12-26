# User aliases
alias vim="nvim"
alias ls="ls -lah"
alias sb="source ~/.bashrc"
alias vb="vim ~/.bashrc"
alias ca="cursor-agent"
# Note: cwf and gwf are available via ~/.local/bin symlinks (in PATH)

# Source Linux-specific aliases
if [[ -f ~/repos/dotfiles/scripts/bash-aliases.sh ]]; then
    source ~/repos/dotfiles/scripts/bash-aliases.sh
fi

# Source Git aliases
if [[ -f ~/repos/dotfiles/scripts/git-aliases.sh ]]; then
    source ~/repos/dotfiles/scripts/git-aliases.sh
fi

# Source bash path and environment
if [[ -f ~/repos/dotfiles/scripts/bash-path.sh ]]; then
    source ~/repos/dotfiles/scripts/bash-path.sh
fi

# Source bash TMUX initialization
if [[ -f ~/repos/dotfiles/scripts/bash-tmux-init.sh ]]; then
    source ~/repos/dotfiles/scripts/bash-tmux-init.sh
fi


# More complex functions
# Source shared shell functions
if [[ -f ~/repos/dotfiles/scripts/grep-recursive.sh ]]; then
    source ~/repos/dotfiles/scripts/grep-recursive.sh
fi

if [[ -f ~/repos/dotfiles/scripts/cursor-agent.sh ]]; then
    source ~/repos/dotfiles/scripts/cursor-agent.sh
fi

if [[ -f ~/repos/dotfiles/scripts/python-utility.sh ]]; then
    source ~/repos/dotfiles/scripts/python-utility.sh
fi

