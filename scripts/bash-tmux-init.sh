#!/bin/bash

# Bash TMUX initialization script
# This file contains TMUX session setup specific to bash shell

# TMUX init
TMUX_MAIN="main"
TMUX_TIME="time"
tmux has-session -t $TMUX_MAIN 2>/dev/null
if [ $? != 0 ]; then
	tmux new-session -d -s $TMUX_MAIN -n "bash"
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
