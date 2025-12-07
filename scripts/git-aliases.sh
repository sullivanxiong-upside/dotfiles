#!/bin/bash

# Git aliases and utilities
# This file contains Git-related aliases and functions

# User Git aliases
alias git-ac="git add . && git commit -m"
alias git-a="git add ."
alias git-branch-commits-diff="git fetch origin && git rev-list --left-right --count origin/main...HEAD"
alias git-c="git commit -m"
alias git-co="git checkout -b"
alias git-d='git diff main HEAD'
alias git-d-name='git diff --name-only main HEAD'
alias git-d-name='git diff --name-only main HEAD'
alias git-fm="git fetch origin main"
alias git-push='git push --set-upstream origin $(git branch --show-current)'
alias git-push-fwl='git push --force-with-lease'
alias git-rebase="git pull --rebase origin main"
alias git-revert-file-to-main="git checkout main -- "
alias git-s="git status"

# Git worktree aliases
alias git-wt-list="git worktree list"
alias git-wt-remove="git worktree remove"
alias git-wt-prune="git worktree prune"

# Create a review worktree in a sibling directory
# Usage: git-wt-review <branch-name> [worktree-name]
# Example: git-wt-review claude/issue-1367-20251106-1724
# Creates: ../data-pipelines-review-1367
git-wt-review() {
    if [ -z "$1" ]; then
        echo "Usage: git-wt-review <branch-name> [worktree-name]"
        echo "Example: git-wt-review claude/issue-1367-20251106-1724"
        return 1
    fi

    local branch="$1"
    local worktree_name="$2"

    # If no worktree name provided, derive it from branch name
    if [ -z "$worktree_name" ]; then
        # Extract last part after last slash and sanitize
        worktree_name=$(echo "$branch" | sed 's/.*\///' | sed 's/[^a-zA-Z0-9-]/-/g')
        worktree_name="review-${worktree_name}"
    fi

    # Get the repo base name
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local worktree_path="../${repo_name}-${worktree_name}"

    echo "Creating worktree at: $worktree_path"
    echo "Branch: $branch"

    git worktree add "$worktree_path" "$branch"

    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ Worktree created successfully!"
        echo "Navigate with: cd $worktree_path"
    fi
}

# Create a feature worktree in a sibling directory
# Usage: git-wt-feature <new-branch-name> [base-branch]
# Example: git-wt-feature my-new-feature
# Creates: ../data-pipelines-feature-my-new-feature on new branch 'my-new-feature'
git-wt-feature() {
    if [ -z "$1" ]; then
        echo "Usage: git-wt-feature <new-branch-name> [base-branch]"
        echo "Example: git-wt-feature my-new-feature"
        echo "Example: git-wt-feature my-new-feature origin/main"
        return 1
    fi

    local branch_name="$1"
    local base_branch="${2:-main}"

    # Sanitize branch name for directory
    local dir_suffix=$(echo "$branch_name" | sed 's/[^a-zA-Z0-9-]/-/g')

    # Get the repo base name
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local worktree_path="../${repo_name}-feature-${dir_suffix}"

    echo "Creating worktree at: $worktree_path"
    echo "New branch: $branch_name (based on $base_branch)"

    git worktree add "$worktree_path" -b "$branch_name" "$base_branch"

    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ Worktree created successfully!"
        echo "Navigate with: cd $worktree_path"
    fi
}

# Quick cleanup: remove a worktree by name pattern
# Usage: git-wt-cleanup <pattern>
# Example: git-wt-cleanup review-1367
git-wt-cleanup() {
    if [ -z "$1" ]; then
        echo "Usage: git-wt-cleanup <pattern>"
        echo "Example: git-wt-cleanup review-1367"
        echo ""
        echo "Current worktrees:"
        git worktree list
        return 1
    fi

    local pattern="$1"
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local worktree_path="../${repo_name}-${pattern}"

    if [ -d "$worktree_path" ]; then
        echo "Removing worktree: $worktree_path"
        git worktree remove --force "$worktree_path"
    else
        echo "Worktree not found: $worktree_path"
        echo ""
        echo "Current worktrees:"
        git worktree list
        return 1
    fi
}
