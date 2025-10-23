#!/bin/bash

# Git aliases and utilities
# This file contains Git-related aliases and functions

# User Git aliases
alias git-branch-commits-diff="git fetch origin && git rev-list --left-right --count origin/main...HEAD"
alias git-rebase="git pull --rebase origin main && git push --force-with-lease"
alias git-ac="git add . && git commit -m"
alias git-a="git add ."
alias git-c="git commit -m"
alias git-co="git checkout -b"
alias git-d='git diff main HEAD'
alias git-d-name='git diff --name-only main HEAD'
alias git-push='git push --set-upstream origin $(git branch --show-current)'
alias git-revert-file-to-main="git checkout main -- "
alias git-s="git status"
