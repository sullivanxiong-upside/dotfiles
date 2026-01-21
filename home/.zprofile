# ============================================================================
# Fix macOS path_helper reordering
# ============================================================================
# macOS's path_helper (run in /etc/zprofile) reorders PATH to put system paths
# first, even though user/package-manager paths were prepended earlier.
# This breaks tools like cwf that need bash 5.3 (from nix) instead of bash 3.2 (system).
# Solution: Move system paths to end while preserving relative order of user paths.

if [[ "$(uname -s)" == "Darwin" ]]; then
    # Split PATH into user/package-manager paths vs system paths
    local user_paths=()
    local system_paths=()

    # Parse current PATH
    local IFS=':'
    local path_array=("${(@s/:/)PATH}")

    for p in "${path_array[@]}"; do
        # User/package-manager paths: $HOME, /opt/homebrew, /nix
        if [[ "$p" == "$HOME"* ]] || [[ "$p" == "/opt/homebrew"* ]] || [[ "$p" == "/nix"* ]]; then
            user_paths+=("$p")
        else
            # System paths: /usr, /bin, /System, /Applications, etc.
            system_paths+=("$p")
        fi
    done

    # Rebuild PATH: user paths first, system paths last
    export PATH="${(j/:/)user_paths}:${(j/:/)system_paths}"
    unset user_paths system_paths path_array IFS
fi

# User aliases
alias vim="nvim"
alias ls="ls -lah"
alias ca="cursor-agent"
alias .f="cd ~/repos/dotfiles"
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

# Shell reload aliases
alias sz='source ~/.zprofile'  # Quick refresh - use for aliases/functions
alias rzsh='exec zsh -l'       # Full reset - use for PATH/environment changes

