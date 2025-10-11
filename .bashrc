alias fetch="anifetch -ff ~/apps/manim/media/videos/img_to_mp4/2160p60/ImageToMP4LogoTest.mp4 -r 60 -W 25 -H 25 -c '--symbols wide --fg-only'"
alias vim="nvim"
alias font-cache="fc-cache -fv"
alias waybar-reload="killall waybar & hyprctl dispatch exec waybar"
# alias wayvncd="wayvnc -o=HDMI-A-1 --max-fps=30"
alias emoji="rofi -show emoji -modi emoji"
alias calc="rofi -show calc -modi calc"
alias fastfetch-small="fastfetch --config /home/suxiong/.config/fastfetch/small_config.jsonc"
alias spotify-avahi-daemon="sudo systemctl start avahi-daemon"
alias password-reset="faillock --reset"
alias ls="ls -lah"
alias git-branch-commits-diff="git fetch origin && git rev-list --left-right --count origin/main...HEAD"

fastfetch-small

TMUX_MAIN="main"
TMUX_TIME="time"
tmux has-session -t $TMUX_MAIN 2>/dev/null
if [ $? != 0 ]; then
	tmux new-session -d -s $TMUX_MAIN -n "editor"
	tmux new-session -d -s $TMUX_TIME -n "time"
	tmux clock-mode -t time
 
	# tmux send-keys -t $TMUX_MAIN:editor "cd ~/apps/" C-m

	tmux new-window -t $TMUX_MAIN -n "cli"
	tmux new-window -t $TMUX_MAIN -n "xtra"
 
	tmux select-window -t $TMUX_MAIN:editor
fi
if [ -z "$TMUX" ]; then
	tmux ls | grep main | grep attached 1>/dev/null
	if [ $? == 1 ]; then
		tmux attach -t $TMUX_MAIN
	fi
fi

# Created by `pipx` on 2025-08-19 22:32:46
export PATH="$PATH:/home/suxiong/.local/bin:/home/suxiong/.fly/bin"

eval "$(starship init bash)"

# More complex functions
grep-recursive() {
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

# Cursor Agent with Custom Rules Function
cursor-agent() {
    local current_dir=$(pwd)
    local cursor_rules_dir="$current_dir/.cursor/rules"
    
    # Check if .cursor/rules directory exists and has .mdc files
    if [ -d "$cursor_rules_dir" ] && [ "$(find "$cursor_rules_dir" -name "*.mdc" -type f | wc -l)" -gt 0 ]; then
        echo "🔧 Found .cursor/rules/*.mdc files in $(basename "$current_dir")"
        echo "📋 Available rules:"
        find "$cursor_rules_dir" -name "*.mdc" -type f | while read -r rule_file; do
            echo "   - $(basename "$rule_file")"
        done
        echo ""
        echo "🚀 Starting cursor-agent with custom rules..."
        
        # Read all .mdc files and pass them as context
        local rules_content=""
        find "$cursor_rules_dir" -name "*.mdc" -type f | while read -r rule_file; do
            rules_content+="\n\n=== $(basename "$rule_file") ===\n"
            rules_content+="$(cat "$rule_file")"
        done
        
        # Export rules as environment variable for cursor-agent to use
        export CURSOR_CUSTOM_RULES="$rules_content"
        
        # Run cursor-agent with the rules context
        command cursor-agent "$@"
        
        # Clean up environment variable
        unset CURSOR_CUSTOM_RULES
    else
        echo "📁 No .cursor/rules/*.mdc files found in $(basename "$current_dir")"
        echo "🚀 Starting cursor-agent normally..."
        command cursor-agent "$@"
    fi
}
