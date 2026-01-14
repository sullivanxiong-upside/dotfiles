#!/usr/bin/env bash
# Bash completion for gwf (Git Workflow CLI)
# To enable: source ~/scripts/gwf-completion.bash
# Or add to ~/.bashrc or ~/.zshrc

_gwf_completion() {
  local cur prev words cword
  _init_completion || return

  # Get the command components
  local category="${words[1]:-}"
  local subcommand="${words[2]:-}"

  # Complete categories (first argument)
  if [ $cword -eq 1 ]; then
    COMPREPLY=($(compgen -W "local l remote r worktree wt pr inspect i help" -- "$cur"))
    return 0
  fi

  # Expand category shortcuts
  case "$category" in
    l) category="local" ;;
    r) category="remote" ;;
    wt) category="worktree" ;;
    i) category="inspect" ;;
  esac

  # Complete subcommands (second argument)
  if [ $cword -eq 2 ]; then
    case "$category" in
      local)
        COMPREPLY=($(compgen -W "add a commit c status s diff d" -- "$cur"))
        ;;
      remote)
        COMPREPLY=($(compgen -W "push ps rebase r pull pl" -- "$cur"))
        ;;
      worktree)
        COMPREPLY=($(compgen -W "review feature cleanup list" -- "$cur"))
        ;;
      pr)
        COMPREPLY=($(compgen -W "create c checkout co list ls diff d push p" -- "$cur"))
        ;;
      inspect)
        COMPREPLY=($(compgen -W "diff d log show blame" -- "$cur"))
        ;;
    esac
    return 0
  fi

  # Complete arguments for specific subcommands (third argument and beyond)
  if [ $cword -ge 3 ]; then
    # Expand subcommand shortcuts
    case "$subcommand" in
      a) subcommand="add" ;;
      c) subcommand="commit" ;;
      s) subcommand="status" ;;
      d) subcommand="diff" ;;
      ps) subcommand="push" ;;
      r) subcommand="rebase" ;;
      pl) subcommand="pull" ;;
      co) subcommand="checkout" ;;
      ls) subcommand="list" ;;
      p) subcommand="push" ;;
    esac

    case "$category:$subcommand" in
      worktree:cleanup)
        # Complete with branch names from existing worktrees
        local branches=$(git worktree list --porcelain 2>/dev/null | awk '/^branch / {sub(/^branch refs\/heads\//, ""); print}')
        COMPREPLY=($(compgen -W "$branches" -- "$cur"))
        ;;
      worktree:review|worktree:feature)
        # Complete with all branch names (local and remote)
        local branches=$(git for-each-ref --format='%(refname:short)' refs/heads/ refs/remotes/origin/ 2>/dev/null | sed 's|^origin/||' | sort -u)
        COMPREPLY=($(compgen -W "$branches" -- "$cur"))
        ;;
      local:add)
        # Complete with modified/untracked files
        _filedir
        ;;
      inspect:blame)
        # Complete with files in repo
        _filedir
        ;;
    esac
    return 0
  fi
}

# Register completion
complete -F _gwf_completion gwf
