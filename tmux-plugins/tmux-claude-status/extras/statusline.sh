#!/usr/bin/env bash
#
# Claude Code Statusline Script
# Integrates with tmux-claude-status plugin
#
# Copy this to ~/.claude/statusline.sh and configure in ~/.claude/settings.json
#
# This script is called by Claude Code every ~300ms with JSON on stdin.
# It analyzes token changes to detect Claude's state and writes to cache files.

set -euo pipefail

# Logging (errors only - stdout is for status line display)
exec 2>> "${HOME}/.claude/statusline-errors.log"

# Configuration
# This must match the plugin cache directory
STATE_DIR="${HOME}/repos/dotfiles/tmux-plugins/tmux-claude-status/cache"
mkdir -p "$STATE_DIR" 2>/dev/null || true

# Read JSON from Claude Code (via stdin)
INPUT=$(timeout 2s cat 2>/dev/null || echo '{}')

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not installed"
    exit 1
fi

# Helper function for safe JSON extraction
jq_safe() {
    local query="$1"
    local default="$2"
    echo "$INPUT" | jq -r "$query // \"$default\"" 2>/dev/null || echo "$default"
}

# Extract data from Claude's JSON
MODEL=$(jq_safe '.model.display_name' 'Claude')
TOKENS_IN=$(jq_safe '.context_window.input_tokens' '0')
TOKENS_OUT=$(jq_safe '.context_window.output_tokens' '0')
CACHE_READS=$(jq_safe '.context_window.cache_read_input_tokens' '0')
CACHE_WRITES=$(jq_safe '.context_window.cache_creation_input_tokens' '0')
COST=$(jq_safe '.cost.total_cost_usd' '0.00')
SESSION_ID=$(jq_safe '.session_id' 'unknown')
PROJECT=$(jq_safe '.workspace.project_dir' "$PWD")
CWD=$(jq_safe '.workspace.current_dir' "$PWD")

# Determine which pane this is running in
# TMUX_PANE is set by tmux (e.g., "%0", "%1", etc.)
PANE_ID="${TMUX_PANE:-default}"

# Sanitize pane_id for filename (remove %)
PANE_ID_CLEAN="${PANE_ID//%/}"
STATE_FILE="${STATE_DIR}/${PANE_ID_CLEAN}.json"

# Load previous state for comparison
PREV_TOKENS_IN=0
PREV_TOKENS_OUT=0
PREV_CACHE_READS=0
PREV_LAST_ACTIVITY=0

if [ -f "$STATE_FILE" ]; then
    PREV_TOKENS_IN=$(jq -r '.tokens_in // 0' "$STATE_FILE" 2>/dev/null || echo "0")
    PREV_TOKENS_OUT=$(jq -r '.tokens_out // 0' "$STATE_FILE" 2>/dev/null || echo "0")
    PREV_CACHE_READS=$(jq -r '.cache_reads // 0' "$STATE_FILE" 2>/dev/null || echo "0")
    PREV_LAST_ACTIVITY=$(jq -r '.last_activity // 0' "$STATE_FILE" 2>/dev/null || echo "0")
fi

# Get current timestamp
NOW=$(date +%s)

# State detection logic with grace period
# Grace period: Keep showing "processing" for N seconds after last token change
GRACE_PERIOD=3  # seconds

STATUS="idle"
DETAIL=""
LAST_ACTIVITY=$PREV_LAST_ACTIVITY

# Check if tokens changed (activity detected)
if [ "$TOKENS_OUT" -gt "$PREV_TOKENS_OUT" ]; then
    # Output tokens increasing = Claude is generating response
    STATUS="processing"
    DETAIL="generating"
    LAST_ACTIVITY=$NOW
elif [ "$TOKENS_IN" -gt "$PREV_TOKENS_IN" ]; then
    # Input tokens increasing = Processing user input
    STATUS="processing"
    DETAIL="thinking"
    LAST_ACTIVITY=$NOW
elif [ "$CACHE_READS" -gt "$PREV_CACHE_READS" ]; then
    # Cache reads increasing = Loading context
    STATUS="processing"
    DETAIL="loading"
    LAST_ACTIVITY=$NOW
elif [ "$CACHE_WRITES" -gt 0 ] && [ "$PREV_CACHE_READS" -eq 0 ]; then
    # Initial cache write = Starting up
    STATUS="processing"
    DETAIL="starting"
    LAST_ACTIVITY=$NOW
else
    # No token changes detected
    # Check if we're within grace period of last activity
    TIME_SINCE_ACTIVITY=$((NOW - LAST_ACTIVITY))

    if [ $TIME_SINCE_ACTIVITY -lt $GRACE_PERIOD ] && [ $LAST_ACTIVITY -gt 0 ]; then
        # Still within grace period - keep processing state
        STATUS="processing"
        DETAIL="working"
    else
        # Beyond grace period or no previous activity - mark as completed
        STATUS="completed"
        DETAIL="ready"
    fi
fi

# Write state to cache file
# This file is read by the tmux plugin
cat > "$STATE_FILE" <<EOF
{
  "status": "$STATUS",
  "detail": "$DETAIL",
  "model": "$MODEL",
  "tokens_in": $TOKENS_IN,
  "tokens_out": $TOKENS_OUT,
  "cache_reads": $CACHE_READS,
  "cache_writes": $CACHE_WRITES,
  "cost": $COST,
  "project": "$PROJECT",
  "cwd": "$CWD",
  "session_id": "$SESSION_ID",
  "pane_id": "$PANE_ID",
  "updated": $NOW,
  "last_activity": $LAST_ACTIVITY
}
EOF

# Format cost nicely
COST_FORMATTED=$(printf "%.4f" "$COST")

# Determine emoji for status
case "$STATUS" in
    processing)
        case "$DETAIL" in
            generating) EMOJI="🚀" ;;
            thinking)   EMOJI="🤔" ;;
            loading)    EMOJI="⏳" ;;
            starting)   EMOJI="🔄" ;;
            *)          EMOJI="⚙️" ;;
        esac
        COLOR="\033[32m"  # Green
        ;;
    completed)
        EMOJI="✨"
        COLOR="\033[90m"  # Gray
        ;;
    *)
        EMOJI="❓"
        COLOR="\033[33m"  # Yellow
        ;;
esac

# Output for Claude's terminal status line
# This appears at the bottom of the Claude terminal
# Format: emoji status | model | tokens | cost
printf "${COLOR}${EMOJI} ${MODEL}\033[0m | 📊 %s/%stok | 💰\$%s\n" \
    "$TOKENS_IN" "$TOKENS_OUT" "$COST_FORMATTED"
