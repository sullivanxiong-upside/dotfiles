# User aliases
alias vim="nvim"
alias git-branch-commits-diff="git fetch origin && git rev-list --left-right --count origin/main...HEAD"
alias ls="ls -lah"
alias start-llm-analysis-server="cd /Users/sullivanxiong/repos/data-pipelines && python -m src.jobs.datahub_llm_analysis_service.main --config_file src/jobs/datahub_llm_analysis_service/local-config.yaml 2>&1"
alias login-aws-sso="aws sso login --profile Stage_Shared_Workloads-AWSPowerUserAccess"

# More complex functions
function grep-recursive() {
  local pattern="$1"
  shift  # Remove the pattern from arguments to pass remaining args to rg
  
  # Use ripgrep (rg) for much faster searching
  # Falls back to grep if rg is not installed
  if command -v rg &> /dev/null; then
    rg --line-number \
       --no-heading \
       --type ts --type js --type py \
       --color=always \
       --smart-case \
       "$pattern" "$@" ./ 2>/dev/null | \
      fzf --ansi \
          --delimiter=':' \
          --preview 'file={1}; line={2}; bat --color=always --theme="Nord" --highlight-line=$line --line-range=$((line > 5 ? line - 5 : 1)):$((line + 15)) --style=numbers,changes "$file" 2>/dev/null || head -100 "$file"' \
          --preview-window=right:60%:wrap \
          --bind 'enter:execute(file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); cursor "$file")+abort' \
          --bind 'ctrl-o:execute(file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); cursor "$file")' \
          --bind 'ctrl-y:execute(echo {} | pbcopy)' \
          --header 'ENTER: open in Cursor | CTRL-O: open without closing | CTRL-Y: copy | ESC: exit'
  else
    # Fallback to grep if ripgrep is not installed
    grep -rn --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" "$pattern" "$@" ./ 2>/dev/null | \
      fzf --delimiter=':' \
          --preview 'file={1}; line={2}; bat --color=always --theme="Nord" --highlight-line=$line --line-range=$((line > 5 ? line - 5 : 1)):$((line + 15)) --style=numbers,changes "$file" 2>/dev/null || head -100 "$file"' \
          --preview-window=right:60%:wrap \
          --bind 'enter:execute(file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); cursor "$file:$line")+abort' \
          --bind 'ctrl-o:execute(file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); cursor "$file:$line")' \
          --bind 'ctrl-y:execute(echo {} | pbcopy)' \
          --header 'ENTER: open in Cursor | CTRL-O: open without closing | CTRL-Y: copy | ESC: exit'
  fi
}

# Path
export PATH="$HOME/.local/bin:$PATH"
export WORDCHARS="${WORDCHARS//\//}"

# Disable OSC color queries
printf '\e]10;?\a' 2>/dev/null | cat > /dev/null
printf '\e]11;?\a' 2>/dev/null | cat > /dev/null

# TMUX init
TMUX_MAIN="main"
if ! tmux has-session -t $TMUX_MAIN 2>/dev/null; then
	tmux new-session -d -s $TMUX_MAIN -n "editor"
 
	tmux new-window -t $TMUX_MAIN -n "cli"
	tmux new-window -t $TMUX_MAIN -n "xtra"
 
	tmux select-window -t $TMUX_MAIN:1
fi
if [[ -z "$TMUX" ]]; then
	if ! tmux ls | grep main | grep attached 1>/dev/null; then
		tmux attach -t $TMUX_MAIN
	fi
fi

