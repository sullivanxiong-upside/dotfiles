# User aliases
alias vim="nvim"
alias ls="ls -lah"
alias sz="source ~/.zprofile"
alias cds="cd ~/repos/customer-dashboard/"
alias dp="cd ~/repos/data-pipelines/"
alias zs="cd ~/repos/zsh-tools/"
alias vz="vim ~/.zprofile"
alias ca="cursor-agent"

# Automation workflows
export DJANGO_LOG_LEVEL=DEBUG
alias start-llm-analysis-server="cd /Users/sullivanxiong/repos/data-pipelines && python -m src.jobs.datahub_llm_analysis_service.main --config_file src/jobs/datahub_llm_analysis_service/local-config.yaml 2>&1"
alias login-aws-sso="aws sso login --profile Stage_Shared_Workloads-AWSPowerUserAccess"
# Monitoring stack functions with Colima check
function ms-start() {
    # Check if colima is running
    if ! colima status 2>/dev/null | grep -q "Running"; then
        echo "Colima is not running. Starting Colima first..."
        colima start
        # Wait a moment for Colima to fully initialize
        sleep 2
    else
        echo "Colima is already running."
    fi
    
    echo "Starting monitoring-stack..."
    monitoring-stack start
}
alias ms-stop="monitoring-stack stop"
alias ms-restart="monitoring-stack stop && ms-start"
alias ms-reset="cd /Users/sullivanxiong/repos/zsh-tools/path_scripts/../local_stacks/monitoring && docker-compose down -v"
alias ms-logs="cd ~/repos/zsh-tools/local_stacks/monitoring && docker-compose ps otel-collector && docker-compose logs --tail=50 otel-collector"

# Source customer dashboard automation functions
if [[ -f ~/.zprofile_automations ]]; then
	source ~/.zprofile_automations
fi


# User Git aliases
alias git-branch-commits-diff="git fetch origin && git rev-list --left-right --count origin/main...HEAD"
alias git-rebase="git pull --rebase origin main && git push --force"
alias git-a="git add ."
alias git-c="git commit -m"
alias git-co="git checkout -b"
alias git-d='git diff $(git merge-base HEAD main)..HEAD'
alias git-d-name='git diff --name-only $(git merge-base HEAD main)..HEAD'
alias git-push='git push --set-upstream origin $(git branch --show-current)'
alias git-s="git status"

# More complex functions
function grep-recursive() {
  # Join all arguments into a single pattern to handle space-separated searches
  local pattern="$*"
  
  # Use ripgrep (rg) for much faster searching
  # Falls back to grep if rg is not installed
  if command -v rg &> /dev/null; then
    rg --line-number \
       --no-heading \
       --glob '!*.png' --glob '!*.jpg' --glob '!*.jpeg' --glob '!*.gif' --glob '!*.ico' --glob '!*.mp4' --glob '!*.avi' --glob '!*.mov' \
       --color=always \
       --smart-case \
       --fixed-strings \
       "$pattern" ./ 2>/dev/null | \
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
    grep -rn --exclude="*.png" --exclude="*.jpg" --exclude="*.jpeg" --exclude="*.gif" --exclude="*.ico" --exclude="*.mp4" --exclude="*.avi" --exclude="*.mov" --fixed-strings "$pattern" ./ 2>/dev/null | \
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
	tmux new-session -d -s $TMUX_MAIN -n "cli"
	tmux send-keys 'cd ~/repos/customer-dashboard' C-m

	tmux new-window -t $TMUX_MAIN -n "db"
	tmux send-keys 'make start-db' C-m

	tmux new-window -t $TMUX_MAIN -n "client-dev"
	tmux send-keys 'make client-dev' C-m

	tmux new-window -t $TMUX_MAIN -n "server-dev"
	tmux send-keys 'make server-run-uvicorn' C-m

	tmux new-window -t $TMUX_MAIN -n "monitoring-infra"
	tmux send-keys 'ms-start' C-m

	tmux new-window -t $TMUX_MAIN -n "xtra"
 
	tmux select-window -t $TMUX_MAIN:1
fi
if [[ -z "$TMUX" ]]; then
	if ! tmux ls | grep main | grep attached 1>/dev/null; then
		tmux attach -t $TMUX_MAIN
	fi
fi

