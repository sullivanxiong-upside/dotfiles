# User aliases
alias vim="nvim"
alias ls="ls -lah"
alias sb="source ~/.bashrc"
alias vb="vim ~/.bashrc"
alias ca="cursor-agent"
# Note: cwf and gwf are available via ~/.local/bin symlinks (in PATH)

# Source Linux-specific aliases
if [[ -f ~/repos/dotfiles/bin/bash-aliases.sh ]]; then
    source ~/repos/dotfiles/bin/bash-aliases.sh
fi

# Source Git aliases
if [[ -f ~/repos/dotfiles/bin/git-aliases ]]; then
    source ~/repos/dotfiles/bin/git-aliases
fi

# Source bash path and environment
if [[ -f ~/repos/dotfiles/bin/bash-path.sh ]]; then
    source ~/repos/dotfiles/bin/bash-path.sh
fi

# Source bash TMUX initialization
if [[ -f ~/repos/dotfiles/bin/bash-tmux-init.sh ]]; then
    source ~/repos/dotfiles/bin/bash-tmux-init.sh
fi


# More complex functions
# Source shared shell functions
if [[ -f ~/repos/dotfiles/bin/grep-recursive ]]; then
    source ~/repos/dotfiles/bin/grep-recursive
fi

if [[ -f ~/repos/dotfiles/bin/cursor-agent ]]; then
    source ~/repos/dotfiles/bin/cursor-agent
fi

if [[ -f ~/repos/dotfiles/bin/python-utility ]]; then
    source ~/repos/dotfiles/bin/python-utility
fi

