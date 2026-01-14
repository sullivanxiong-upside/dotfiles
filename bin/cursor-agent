#!/bin/bash

# cursor-agent function - shared across shell configurations
# This function provides enhanced cursor-agent functionality with custom rules support
# It automatically detects .cursor/rules/*.mdc files and passes them as context

function cursor-agent() {
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