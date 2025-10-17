#!/bin/bash

# TMUX initialization script
# This file contains TMUX session setup and management

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
