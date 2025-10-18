#!/bin/bash

# Grep recursive function with fzf integration
# This file contains the grep-recursive function for searching files

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
