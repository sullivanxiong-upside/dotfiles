#!/usr/bin/env bash
#
# tmux-claude-status v2.0
# Main plugin entry point
#
# Integrates with Claude Code's statusline API to display real-time
# status in tmux window tabs.

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source helper functions
source "$CURRENT_DIR/scripts/helpers.sh"

# Ensure cache directory exists
CACHE_DIR="${CURRENT_DIR}/cache"
mkdir -p "$CACHE_DIR"

# Log plugin initialization (if debug enabled)
debug_log "tmux-claude-status v2.0 initializing"

# Configuration defaults
DEFAULT_ICON_PROCESSING="..."
DEFAULT_ICON_COMPLETED="✔"
DEFAULT_ICON_EMPTY="○"
DEFAULT_POSITION="before"
DEFAULT_SHOW_EMPTY="false"
DEFAULT_MAX_AGE="5"

# Get user configuration options
ICON_PROCESSING=$(get_tmux_option "@claude-status-icon-processing" "$DEFAULT_ICON_PROCESSING")
ICON_COMPLETED=$(get_tmux_option "@claude-status-icon-completed" "$DEFAULT_ICON_COMPLETED")
POSITION=$(get_tmux_option "@claude-status-position" "$DEFAULT_POSITION")
SHOW_EMPTY=$(get_tmux_option "@claude-status-show-empty" "$DEFAULT_SHOW_EMPTY")

debug_log "Config: processing=$ICON_PROCESSING, completed=$ICON_COMPLETED, position=$POSITION"

# Build the status script command
# This will be injected into tmux's window-status-format
STATE_READER="${CURRENT_DIR}/scripts/claude_state_reader.sh"

# Script for inactive windows (colored status)
status_script_inactive="#($STATE_READER '#{pane_id}' inactive)"

# Script for active window (white bold status)
status_script_active="#($STATE_READER '#{pane_id}' active)"

# Get current window format strings
current_format=$(tmux show-option -gqv window-status-format)
active_format=$(tmux show-option -gqv window-status-current-format)

debug_log "Current format: $current_format"
debug_log "Active format: $active_format"

# Check if formats are empty (shouldn't happen, but safety check)
if [ -z "$current_format" ]; then
    current_format="#I #W"
    debug_log "Warning: window-status-format was empty, using default"
fi

if [ -z "$active_format" ]; then
    active_format="#I #W"
    debug_log "Warning: window-status-current-format was empty, using default"
fi

# Inject status script into format strings
# Position can be "before" (between index and name) or "after" (after name)
if [ "$POSITION" = "after" ]; then
    # Place status after window name: #I #W STATUS
    new_format="${current_format} ${status_script_inactive}"
    new_active="${active_format} ${status_script_active}"
else
    # Place status before window name: #I STATUS #W
    # Use bash parameter substitution to inject after #I
    new_format="${current_format/ #I #W/ #I ${status_script_inactive} #W}"
    new_active="${active_format/ #I #W/ #I ${status_script_active} #W}"

    # Fallback if pattern doesn't match (theme might use different format)
    if [ "$new_format" = "$current_format" ]; then
        # Pattern didn't match, append instead
        new_format="${current_format} ${status_script_inactive}"
        debug_log "Warning: Could not inject before name, appending instead"
    fi

    if [ "$new_active" = "$active_format" ]; then
        new_active="${active_format} ${status_script_active}"
        debug_log "Warning: Could not inject before name (active), appending instead"
    fi
fi

debug_log "New format: $new_format"
debug_log "New active: $new_active"

# Apply the new formats
tmux set-option -gq window-status-format "$new_format"
tmux set-option -gq window-status-current-format "$new_active"

# Set up periodic cleanup of stale cache files (older than 1 day)
# This prevents accumulation of abandoned state files
cleanup_stale_cache() {
    find "$CACHE_DIR" -name '*.json' -mtime +1 -delete 2>/dev/null || true
}

# Run cleanup in background
cleanup_stale_cache &

debug_log "tmux-claude-status v2.0 loaded successfully"
