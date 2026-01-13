#!/usr/bin/env bash
#
# Claude State Reader
# Reads state from cache files written by Claude's statusline script
# and formats for display in tmux window tabs.

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_DIR="$( cd "$CURRENT_DIR/.." && pwd )"

# Load helpers
source "${PLUGIN_DIR}/scripts/helpers.sh"

# Parse arguments
PANE_ID="$1"
DISPLAY_MODE="$2"  # "active" or "inactive"

# Sanitize pane_id (remove % prefix)
PANE_ID_CLEAN="${PANE_ID//%/}"

# Cache directory (shared with statusline script)
CACHE_DIR="${PLUGIN_DIR}/cache"
STATE_FILE="${CACHE_DIR}/${PANE_ID_CLEAN}.json"

# Configuration defaults
DEFAULT_ICON_PROCESSING="..."
DEFAULT_ICON_COMPLETED="✔"
DEFAULT_ICON_EMPTY="○"
DEFAULT_SHOW_EMPTY="false"
DEFAULT_MAX_AGE="5"

# Get user configuration
ICON_PROCESSING=$(get_tmux_option "@claude-status-icon-processing" "$DEFAULT_ICON_PROCESSING")
ICON_COMPLETED=$(get_tmux_option "@claude-status-icon-completed" "$DEFAULT_ICON_COMPLETED")
ICON_EMPTY=$(get_tmux_option "@claude-status-icon-empty" "$DEFAULT_ICON_EMPTY")
SHOW_EMPTY=$(get_tmux_option "@claude-status-show-empty" "$DEFAULT_SHOW_EMPTY")
MAX_AGE=$(get_tmux_option "@claude-status-max-age" "$DEFAULT_MAX_AGE")

debug_log "Reading state for pane $PANE_ID (clean: $PANE_ID_CLEAN)"

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
    debug_log "No state file for pane $PANE_ID"

    # No Claude running in this pane
    if [ "$SHOW_EMPTY" = "true" ]; then
        # Show empty indicator
        if [ "$DISPLAY_MODE" = "active" ]; then
            echo "#[fg=white,bold]${ICON_EMPTY}#[fg=default,nobold]"
        else
            echo "#[fg=colour8]${ICON_EMPTY}#[fg=default]"
        fi
    fi
    exit 0
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    debug_log "ERROR: jq not installed"
    exit 0
fi

# Read state from file
STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
DETAIL=$(jq -r '.detail // ""' "$STATE_FILE" 2>/dev/null || echo "")
FILE_UPDATED=$(jq -r '.updated // 0' "$STATE_FILE" 2>/dev/null || echo "0")

debug_log "State: status=$STATUS, detail=$DETAIL, updated=$FILE_UPDATED"

# Check if state is fresh - use different thresholds based on status
NOW=$(date +%s)
AGE=$((NOW - FILE_UPDATED))

# Different staleness thresholds:
# - Processing: 30 seconds (if no update in 30s during processing, probably crashed)
# - Completed: 300 seconds (5 minutes - keep checkmark visible while Claude is idle)
if [ "$STATUS" = "processing" ]; then
    MAX_AGE_FOR_STATUS=30
else
    MAX_AGE_FOR_STATUS=300
fi

if [ $AGE -gt $MAX_AGE_FOR_STATUS ]; then
    debug_log "State is stale (${AGE}s old, max ${MAX_AGE_FOR_STATUS}s for status $STATUS)"

    # State is stale - Claude probably exited
    if [ "$SHOW_EMPTY" = "true" ]; then
        if [ "$DISPLAY_MODE" = "active" ]; then
            echo "#[fg=colour8,bold]${ICON_EMPTY}#[fg=default,nobold]"
        else
            echo "#[fg=colour8]${ICON_EMPTY}#[fg=default]"
        fi
    fi
    exit 0
fi

# Determine icon based on status
if [ "$STATUS" = "processing" ]; then
    ICON="$ICON_PROCESSING"
    STATUS_COLOR="yellow"
else
    ICON="$ICON_COMPLETED"
    STATUS_COLOR="green"
fi

# Format output based on display mode
if [ "$DISPLAY_MODE" = "active" ]; then
    # Active window: white bold text (high visibility)
    # Format: #[fg=white,bold]ICON#[fg=default,nobold]
    # Using fg=default,nobold preserves theme's background color
    echo "#[fg=white,bold]${ICON}#[fg=default,nobold]"
else
    # Inactive window: colored based on status
    # Processing = yellow, Completed = green
    echo "#[fg=${STATUS_COLOR}]${ICON}#[fg=default]"
fi

debug_log "Displayed: icon=$ICON, mode=$DISPLAY_MODE, color=$STATUS_COLOR"
