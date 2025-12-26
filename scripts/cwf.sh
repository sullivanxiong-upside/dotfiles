#!/usr/bin/env bash

# cwf: A unified CLI for Claude workflow commands
# Usage: cwf [--debug] <category> <subcommand> [args...]
#
# Uses --append-system-prompt for automatic prompt caching via Claude CLI.
# Rules and templates are cached in the system prompt for ~99% token reduction.

set -euo pipefail

PROMPT_DIR="$HOME/.config/cwf/prompts"
SHARED_DIR="$PROMPT_DIR/shared"
RULES_DIR="$HOME"

# ============================================================================
# Command Metadata - Single Source of Truth
# ============================================================================

# Command registry: category:subcommand -> prompt_file
declare -A COMMAND_REGISTRY=(
  ["review:review-peer"]="review/review-peer.txt"
  ["review:address-feedback"]="review/address-feedback.txt"
  ["customer-mgmt:bump-resource"]="customer-mgmt/bump-resource.txt"
  ["customer-mgmt:regen-fields"]="customer-mgmt/regen-fields.txt"
  ["customer-mgmt:onboard"]="customer-mgmt/onboard.txt"
  ["feature:dp"]="feature/dp.txt"
  ["feature:cd"]="feature/cd.txt"
  ["feature:all"]="feature/all.txt"
  ["feature:general"]="feature/general.txt"
  ["feature:continue"]="feature/continue.txt"
  ["feature:plan"]="feature/plan.txt"
  ["agent:chat"]="agent/chat.txt"
  ["prepare-release:__main__"]="prepare-release.txt"
  ["new:add-shared"]="new/add-shared.txt"
  ["new:add-top-rule"]="new/add-top-rule.txt"
  ["new:add-top-command"]="new/add-top-command.txt"
  ["new:add-sub-command"]="new/add-sub-command.txt"
  ["new:improve-rules"]="new/improve-rules.txt"
  ["new:improve-workflows"]="new/improve-workflows.txt"
)

# Category descriptions
declare -A CATEGORY_DESC=(
  ["review"]="Code review"
  ["customer-mgmt"]="Customer management"
  ["feature"]="Feature development"
  ["agent"]="Research and learning"
  ["prepare-release"]="Generate release notes"
  ["new"]="Create new prompts"
  ["completion"]="Shell completion"
)

# Subcommand descriptions (category:subcommand -> description)
declare -A SUBCOMMAND_DESC=(
  ["review:review-peer"]="Review PR changes with ratings and issue detection"
  ["review:address-feedback"]="Address peer feedback on current branch"
  ["customer-mgmt:bump-resource"]="Handle OOM resource bump workflow"
  ["customer-mgmt:regen-fields"]="Regenerate customer SFDC query fields"
  ["customer-mgmt:onboard"]="Onboard a new customer"
  ["feature:dp"]="Work on data-pipelines feature"
  ["feature:cd"]="Work on customer-dashboard feature"
  ["feature:all"]="Work on cross-repo feature (dp + cd + sql-core-migrations)"
  ["feature:general"]="Work on general feature outside main repos"
  ["feature:continue"]="Analyze current branch and plan next steps"
  ["feature:plan"]="Plan feature implementation with detailed exploration"
  ["agent:chat"]="Research and learn about specific topics with expert guidance"
  ["prepare-release:__main__"]="Generate release notes from prod to main"
  ["new:add-shared"]="Interactively add a new shared prompt fragment"
  ["new:add-top-rule"]="Interactively add rules for a category"
  ["new:add-top-command"]="Interactively create a new top-level category"
  ["new:add-sub-command"]="Interactively add a subcommand to a category"
  ["new:improve-rules"]="Analyze and improve all rule files"
  ["new:improve-workflows"]="Improve the cwf/gwf workflow tools themselves"
)

# Commands that require extra arguments
declare -A REQUIRED_ARGS=(
  ["new:add-top-rule"]="category"
  ["new:add-sub-command"]="category"
)

# ============================================================================
# Helper Functions
# ============================================================================

# Get all subcommands for a category
function get_subcommands() {
  local category="$1"
  local subcommands=()

  for key in "${!COMMAND_REGISTRY[@]}"; do
    if [[ "$key" =~ ^${category}: ]]; then
      local subcmd="${key#*:}"
      # Skip internal markers
      [ "$subcmd" = "__main__" ] || subcommands+=("$subcmd")
    fi
  done

  printf '%s\n' "${subcommands[@]}" | sort
}

# Check if category exists
function category_exists() {
  local category="$1"
  [ -n "${CATEGORY_DESC[$category]:-}" ]
}

# Check if command exists
function command_exists() {
  local category="$1"
  local subcommand="$2"
  local key="${category}:${subcommand}"
  [ -n "${COMMAND_REGISTRY[$key]:-}" ]
}

# Load a file's contents with validation
function load_file() {
  local file="$1"
  local required="${2:-false}"

  if [ -f "$file" ]; then
    local content=$(cat "$file")
    if [ -z "$content" ] && [ "$required" = "true" ]; then
      echo "Warning: File is empty: $file" >&2
    fi
    echo "$content"
  else
    if [ "$required" = "true" ]; then
      echo "Error: Required file not found: $file" >&2
      return 1
    fi
    echo ""
  fi
}

# Lazy-load a shared fragment only if needed
function load_fragment_if_needed() {
  local prompt="$1"
  local var_name="$2"
  local file_name="$3"

  # Check if template variable exists in prompt
  if echo "$prompt" | grep -q "{{$var_name}}"; then
    local content=$(load_file "$SHARED_DIR/$file_name" false)
    echo "$content"
  else
    echo ""
  fi
}

# Load all shared fragments that are referenced in a prompt
function load_all_shared_fragments() {
  local prompt="$1"
  local all_fragments=""

  # Map of variable names to file names
  declare -A fragment_map=(
    ["DOCS_INSTRUCTIONS"]="docs-instructions.txt"
    ["DESIGN_PATTERNS"]="design-patterns.txt"
    ["API_PROTO_CHECK"]="api-proto-check.txt"
    ["FILE_READING_REMINDER"]="file-reading-reminder.txt"
    ["REVIEW_AND_UPDATE_DOCS"]="review-and-update-docs.txt"
    ["WORKFLOW_COMMANDS"]="workflow-commands.txt"
    ["PLANNING_GUIDELINES"]="planning-guidelines.txt"
    ["CODE_QUALITY_FUNDAMENTALS"]="code-quality-fundamentals.txt"
    ["RUNTIME_SAFETY"]="runtime-safety.txt"
    ["SECURITY_CHECKS"]="security-best-practices.txt"
    ["PERFORMANCE_DATABASE"]="performance-database.txt"
    ["TESTING_DOCUMENTATION"]="testing-documentation.txt"
    ["EXTRACT_REUSABLE_CODE"]="reusable-code-extraction.txt"
  )

  # Load each fragment that's referenced in the prompt
  for var_name in "${!fragment_map[@]}"; do
    if echo "$prompt" | grep -q "{{$var_name}}"; then
      local file_name="${fragment_map[$var_name]}"
      local content=$(load_file "$SHARED_DIR/$file_name" false)

      if [ -n "$content" ]; then
        # Add section header and content
        if [ -n "$all_fragments" ]; then
          all_fragments="$all_fragments

"
        fi
        all_fragments="$all_fragments# $var_name
$content"
      fi
    fi
  done

  echo "$all_fragments"
}

# Get category-specific rules
function get_category_rules() {
  local category="$1"
  local rules_file="$RULES_DIR/.claude-${category}-rules"
  local rules=""

  if [ -f "$rules_file" ]; then
    rules=$(grep -v '^#' "$rules_file" 2>/dev/null | grep -v '^$' || true)
    if [ -n "$rules" ]; then
      rules="

Category-specific rules for ${category}:
$rules"
    fi
  fi

  echo "$rules"
}

# Replace template variables in prompt text with lazy loading
function replace_templates() {
  local prompt="$1"
  local category="$2"

  # Lazy-load shared fragments only if needed
  local docs_inst=$(load_fragment_if_needed "$prompt" "DOCS_INSTRUCTIONS" "docs-instructions.txt")
  local design_pat=$(load_fragment_if_needed "$prompt" "DESIGN_PATTERNS" "design-patterns.txt")
  local api_check=$(load_fragment_if_needed "$prompt" "API_PROTO_CHECK" "api-proto-check.txt")
  local file_rem=$(load_fragment_if_needed "$prompt" "FILE_READING_REMINDER" "file-reading-reminder.txt")
  local review_doc=$(load_fragment_if_needed "$prompt" "REVIEW_AND_UPDATE_DOCS" "review-and-update-docs.txt")
  local workflow_cmd=$(load_fragment_if_needed "$prompt" "WORKFLOW_COMMANDS" "workflow-commands.txt")
  local planning_guide=$(load_fragment_if_needed "$prompt" "PLANNING_GUIDELINES" "planning-guidelines.txt")
  local code_quality=$(load_fragment_if_needed "$prompt" "CODE_QUALITY_FUNDAMENTALS" "code-quality-fundamentals.txt")
  local runtime_safety=$(load_fragment_if_needed "$prompt" "RUNTIME_SAFETY" "runtime-safety.txt")
  local security_checks=$(load_fragment_if_needed "$prompt" "SECURITY_CHECKS" "security-best-practices.txt")
  local performance_db=$(load_fragment_if_needed "$prompt" "PERFORMANCE_DATABASE" "performance-database.txt")
  local testing_docs=$(load_fragment_if_needed "$prompt" "TESTING_DOCUMENTATION" "testing-documentation.txt")
  local extract_reusable=$(load_fragment_if_needed "$prompt" "EXTRACT_REUSABLE_CODE" "reusable-code-extraction.txt")

  # Replace each template variable
  prompt="${prompt//\{\{DOCS_INSTRUCTIONS\}\}/$docs_inst}"
  prompt="${prompt//\{\{DESIGN_PATTERNS\}\}/$design_pat}"
  prompt="${prompt//\{\{API_PROTO_CHECK\}\}/$api_check}"
  prompt="${prompt//\{\{FILE_READING_REMINDER\}\}/$file_rem}"
  prompt="${prompt//\{\{REVIEW_AND_UPDATE_DOCS\}\}/$review_doc}"
  prompt="${prompt//\{\{WORKFLOW_COMMANDS\}\}/$workflow_cmd}"
  prompt="${prompt//\{\{PLANNING_GUIDELINES\}\}/$planning_guide}"
  prompt="${prompt//\{\{CODE_QUALITY_FUNDAMENTALS\}\}/$code_quality}"
  prompt="${prompt//\{\{RUNTIME_SAFETY\}\}/$runtime_safety}"
  prompt="${prompt//\{\{SECURITY_CHECKS\}\}/$security_checks}"
  prompt="${prompt//\{\{PERFORMANCE_DATABASE\}\}/$performance_db}"
  prompt="${prompt//\{\{TESTING_DOCUMENTATION\}\}/$testing_docs}"
  prompt="${prompt//\{\{EXTRACT_REUSABLE_CODE\}\}/$extract_reusable}"

  # Replace {{CATEGORY}} with actual category name
  prompt="${prompt//\{\{CATEGORY\}\}/$category}"

  # Handle category-specific rules (both legacy and new format)
  if echo "$prompt" | grep -q "{{CUSTOM_RULES}}\|{{CATEGORY_RULES}}"; then
    local category_rules=$(get_category_rules "$category")
    prompt="${prompt//\{\{CUSTOM_RULES\}\}/$category_rules}"
    prompt="${prompt//\{\{CATEGORY_RULES\}\}/$category_rules}"
  fi

  echo "$prompt"
}

# Remove template variable placeholders from prompt (for optimization)
function remove_template_placeholders() {
  local prompt="$1"

  # Remove all template variable placeholders
  prompt="${prompt//\{\{DOCS_INSTRUCTIONS\}\}/}"
  prompt="${prompt//\{\{DESIGN_PATTERNS\}\}/}"
  prompt="${prompt//\{\{API_PROTO_CHECK\}\}/}"
  prompt="${prompt//\{\{FILE_READING_REMINDER\}\}/}"
  prompt="${prompt//\{\{REVIEW_AND_UPDATE_DOCS\}\}/}"
  prompt="${prompt//\{\{WORKFLOW_COMMANDS\}\}/}"
  prompt="${prompt//\{\{PLANNING_GUIDELINES\}\}/}"
  prompt="${prompt//\{\{CODE_QUALITY_FUNDAMENTALS\}\}/}"
  prompt="${prompt//\{\{RUNTIME_SAFETY\}\}/}"
  prompt="${prompt//\{\{SECURITY_CHECKS\}\}/}"
  prompt="${prompt//\{\{PERFORMANCE_DATABASE\}\}/}"
  prompt="${prompt//\{\{TESTING_DOCUMENTATION\}\}/}"
  prompt="${prompt//\{\{EXTRACT_REUSABLE_CODE\}\}/}"
  prompt="${prompt//\{\{CUSTOM_RULES\}\}/}"
  prompt="${prompt//\{\{CATEGORY_RULES\}\}/}"

  echo "$prompt"
}

# ============================================================================
# Display Functions
# ============================================================================

# Display usage information (generated from metadata)
function show_usage() {
  cat <<EOF
Usage: cwf [--debug] <category> <subcommand> [additional context...]

Flags:
  --debug                         Show caching statistics
  -h, --help                      Show this help message

Categories and Subcommands:

EOF

  # Generate category and subcommand list from metadata
  for category in review customer-mgmt feature prepare-release new completion; do
    local desc="${CATEGORY_DESC[$category]:-}"
    echo "  $category"
    [ -n "$desc" ] && echo "    # $desc"

    if [ "$category" = "completion" ]; then
      echo "    bash                            Output bash completion script"
      echo "    zsh                             Output zsh completion script"
      echo "    install [config-file]           Install completion to shell config"
      echo ""
      continue
    fi

    # Get subcommands for this category
    local subcommands=$(get_subcommands "$category")
    if [ -n "$subcommands" ]; then
      while IFS= read -r subcmd; do
        local key="${category}:${subcmd}"
        local subcmd_desc="${SUBCOMMAND_DESC[$key]:-}"
        printf "    %-30s %s\n" "$subcmd [context]" "$subcmd_desc"
      done <<< "$subcommands"
    elif [ "$category" = "prepare-release" ]; then
      local key="prepare-release:__main__"
      local desc="${SUBCOMMAND_DESC[$key]:-Generate release notes}"
      printf "    %-30s %s\n" "[context]" "$desc"
    fi
    echo ""
  done

  cat <<EOF
Examples:
  cwf review review-peer "Focus on error handling"
  cwf customer-mgmt bump-resource
  cwf feature dp "Add new metric aggregation"
  cwf --debug feature dp "Show caching stats"
  cwf prepare-release

EOF
}

# Show error for unknown subcommand
function show_subcommand_error() {
  local category="$1"
  local subcommand="$2"

  echo "Error: Unknown $category subcommand '$subcommand'"
  echo -n "Valid subcommands: "
  get_subcommands "$category" | tr '\n' ', ' | sed 's/, $/\n/'
  return 1
}

# ============================================================================
# Core Functions (Extracted from main)
# ============================================================================

# Resolve prompt file path from category and subcommand
function resolve_prompt_file() {
  local category="$1"
  local subcommand="$2"
  local extra_context="$3"

  # Check if category exists
  if ! category_exists "$category" && [ "$category" != "completion" ]; then
    echo "Error: Unknown category '$category'" >&2
    echo "Valid categories: review, customer-mgmt, feature, prepare-release, new, completion" >&2
    return 1
  fi

  # Handle completion separately (not in registry)
  if [ "$category" = "completion" ]; then
    echo ""  # No prompt file needed
    return 0
  fi

  # Handle prepare-release (no real subcommands)
  if [ "$category" = "prepare-release" ]; then
    local key="prepare-release:__main__"
    echo "$PROMPT_DIR/${COMMAND_REGISTRY[$key]}"
    return 0
  fi

  # Check if command exists
  local key="${category}:${subcommand}"
  if ! command_exists "$category" "$subcommand"; then
    show_subcommand_error "$category" "$subcommand" >&2
    return 1
  fi

  # Check if required argument is present
  if [ -n "${REQUIRED_ARGS[$key]:-}" ] && [ -z "$extra_context" ]; then
    local arg_name="${REQUIRED_ARGS[$key]}"
    echo "Error: $subcommand requires a $arg_name argument" >&2
    echo "Usage: cwf $category $subcommand <$arg_name>" >&2
    echo "Example: cwf $category $subcommand ${category}" >&2
    return 1
  fi

  # Return full path to prompt file
  echo "$PROMPT_DIR/${COMMAND_REGISTRY[$key]}"
}

# Build system additions (rules and fragments) for caching optimization
function build_system_additions() {
  local prompt_file="$1"
  local category="$2"

  # Load the prompt file to check what templates are needed
  local base_prompt=$(load_file "$prompt_file" true) || return 1

  # Build system additions from category rules
  local system_additions=""

  # Add category-specific rules if they exist or are referenced
  if echo "$base_prompt" | grep -q "{{CUSTOM_RULES}}\|{{CATEGORY_RULES}}"; then
    local category_rules=$(get_category_rules "$category")
    if [ -n "$category_rules" ]; then
      system_additions="$category_rules"
    fi
  fi

  # Load all shared fragments referenced in the prompt
  local shared_fragments=$(load_all_shared_fragments "$base_prompt")
  if [ -n "$shared_fragments" ]; then
    if [ -n "$system_additions" ]; then
      system_additions="$system_additions

"
    fi
    system_additions="$system_additions$shared_fragments"
  fi

  echo "$system_additions"
}

# Load and process prompt file (optimized for caching)
function process_prompt() {
  local prompt_file="$1"
  local category="$2"
  local extra_context="$3"

  # Load the prompt file with validation
  local base_prompt=$(load_file "$prompt_file" true) || return 1

  # Validate prompt is not empty
  if [ -z "$base_prompt" ]; then
    echo "Error: Prompt file is empty: $prompt_file" >&2
    return 1
  fi

  # Replace {{CATEGORY}} placeholder
  base_prompt="${base_prompt//\{\{CATEGORY\}\}/$category}"

  # Remove template variable placeholders (they'll be in system prompt)
  base_prompt=$(remove_template_placeholders "$base_prompt")

  # Append extra context if provided
  if [ -n "$extra_context" ]; then
    base_prompt="$base_prompt

Additional details: $extra_context"
  fi

  echo "$base_prompt"
}

# Execute the prompt with claude using optimized caching
function execute_prompt() {
  local user_prompt="$1"
  local system_additions="$2"
  local debug_mode="${3:-0}"

  # Check if claude command exists
  if ! command -v claude &> /dev/null; then
    echo "Error: 'claude' command not found" >&2
    echo "Please ensure claude CLI is installed and in PATH" >&2
    return 1
  fi

  # Debug mode: show what's being cached
  if [ "$debug_mode" = "1" ]; then
    echo "=== cwf debug mode ===" >&2
    echo "System (cached):" >&2
    echo "  ${#system_additions} chars (~$((${#system_additions} / 4)) tokens)" >&2
    echo "User prompt:" >&2
    echo "  ${#user_prompt} chars (~$((${#user_prompt} / 4)) tokens)" >&2
    echo "===================" >&2
    echo "" >&2
  fi

  # Execute with system additions for caching (if any)
  if [ -n "$system_additions" ]; then
    # Use --append-system-prompt to add rules to Claude's system prompt
    # This enables automatic caching by Claude CLI
    claude --append-system-prompt "$system_additions" "$user_prompt"
  else
    # No system additions, execute normally
    claude "$user_prompt"
  fi
}

# ============================================================================
# Completion Commands
# ============================================================================

# Generate bash completion script from metadata
function cmd_completion_bash() {
  cat <<'EOF'
#!/usr/bin/env bash
# Bash completion for cwf (Claude Workflow CLI)

_claude_wf_completion() {
  local cur prev words cword
  _init_completion || return

  # Get the command components
  local category="${words[1]:-}"
  local subcommand="${words[2]:-}"

  # Complete categories (first argument)
  if [ $cword -eq 1 ]; then
    COMPREPLY=($(compgen -W "review customer-mgmt feature agent prepare-release new completion help" -- "$cur"))
    return 0
  fi

  # Complete subcommands (second argument)
  if [ $cword -eq 2 ]; then
    case "$category" in
      review)
        COMPREPLY=($(compgen -W "review-peer address-feedback" -- "$cur"))
        ;;
      customer-mgmt)
        COMPREPLY=($(compgen -W "bump-resource regen-fields onboard" -- "$cur"))
        ;;
      feature)
        COMPREPLY=($(compgen -W "dp cd all general continue plan" -- "$cur"))
        ;;
      agent)
        COMPREPLY=($(compgen -W "chat" -- "$cur"))
        ;;
      new)
        COMPREPLY=($(compgen -W "add-shared add-top-rule add-top-command add-sub-command improve-rules improve-workflows" -- "$cur"))
        ;;
      completion)
        COMPREPLY=($(compgen -W "bash zsh install" -- "$cur"))
        ;;
      prepare-release)
        # No subcommands, allow any text as context
        return 0
        ;;
    esac
    return 0
  fi

  # For third argument and beyond, complete with categories for add-top-rule and add-sub-command
  if [ $cword -eq 3 ]; then
    case "$category:$subcommand" in
      new:add-top-rule|new:add-sub-command)
        COMPREPLY=($(compgen -W "review customer-mgmt feature prepare-release" -- "$cur"))
        ;;
    esac
    return 0
  fi
}

# Register completion for both cwf and cwf
complete -F _claude_wf_completion cwf
complete -F _claude_wf_completion cwf
EOF
}

# Generate zsh completion script from metadata
function cmd_completion_zsh() {
  cat <<'EOF'
#compdef cwf cwf

_claude_wf() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  local -a categories subcommands

  # Define categories
  categories=(
    'review:Code review'
    'customer-mgmt:Customer management'
    'feature:Feature development'
    'agent:Research and learning'
    'prepare-release:Generate release notes'
    'new:Create new prompts'
    'completion:Shell completion'
    'help:Show help'
  )

  if (( CURRENT == 2 )); then
    _describe -t categories 'category' categories
    return 0
  fi

  local category=$words[2]

  if (( CURRENT == 3 )); then
    case $category in
      review)
        subcommands=('review-peer:Review PR with ratings' 'address-feedback:Address feedback')
        _describe -t subcommands 'subcommand' subcommands
        return 0
        ;;
      customer-mgmt)
        subcommands=('bump-resource:Handle OOM resource bump' 'regen-fields:Regenerate SFDC fields' 'onboard:Onboard new customer')
        _describe -t subcommands 'subcommand' subcommands
        return 0
        ;;
      feature)
        subcommands=('dp:Data-pipelines feature' 'cd:Customer-dashboard feature' 'all:Cross-repo feature' 'general:General feature' 'continue:Continue current work' 'plan:Plan feature implementation')
        _describe -t subcommands 'subcommand' subcommands
        return 0
        ;;
      agent)
        subcommands=('chat:Research and learn about specific topics')
        _describe -t subcommands 'subcommand' subcommands
        return 0
        ;;
      new)
        subcommands=('add-shared:Add shared prompt fragment' 'add-top-rule:Add category rules' 'add-top-command:Add top-level category' 'add-sub-command:Add subcommand' 'improve-rules:Analyze and improve rule files' 'improve-workflows:Improve cwf/gwf tools')
        _describe -t subcommands 'subcommand' subcommands
        return 0
        ;;
      completion)
        subcommands=('bash:Output bash completion' 'zsh:Output zsh completion' 'install:Install completion')
        _describe -t subcommands 'subcommand' subcommands
        return 0
        ;;
      prepare-release)
        # No subcommands, just return to allow freeform text
        return 0
        ;;
    esac
    return 0
  fi

  if (( CURRENT >= 4 )); then
    local subcommand=$words[3]

    case "$category:$subcommand" in
      new:add-top-rule|new:add-sub-command)
        local -a target_categories
        target_categories=('review' 'customer-mgmt' 'feature' 'prepare-release')
        _describe -t categories 'category' target_categories
        return 0
        ;;
    esac

    # No completion for other cases
    return 0
  fi
}

# Register for both the command and common aliases
compdef _claude_wf cwf
compdef _claude_wf cwf.sh
compdef _claude_wf cwf
EOF
}

function cmd_completion_install() {
  local shell_config="${1:-}"

  # If no config specified, detect it
  if [ -z "$shell_config" ]; then
    if [ -n "${ZSH_VERSION:-}" ]; then
      shell_config="$HOME/.zshrc"
    elif [ -n "${BASH_VERSION:-}" ]; then
      shell_config="$HOME/.bashrc"
    else
      echo "Error: Unknown shell. Please specify config file:"
      echo "  cwf completion install ~/.zshrc"
      echo "  cwf completion install ~/.bashrc"
      echo ""
      echo "Or manually add:"
      echo "  source <(cwf completion bash)"
      return 1
    fi
  fi

  # Expand ~ if present
  shell_config="${shell_config/#\~/$HOME}"

  # Check if file exists and is writable
  if [ ! -f "$shell_config" ]; then
    echo "Error: Config file does not exist: $shell_config"
    echo "Create it first or specify a different file"
    return 1
  fi

  if [ ! -w "$shell_config" ]; then
    echo "Error: Cannot write to $shell_config (permission denied)"
    echo "Try: chmod u+w $shell_config"
    return 1
  fi

  # Check if already installed
  if grep -q "cwf completion" "$shell_config" 2>/dev/null; then
    echo "✓ cwf completion already installed in $shell_config"
    return 0
  fi

  # Detect if it's a zsh or bash config
  local is_zsh=0
  if [[ "$shell_config" == *".zsh"* ]] || [[ "$shell_config" == *"zprofile"* ]]; then
    is_zsh=1
  fi

  # Add completion to config with proper guards
  {
    echo ""
    echo "# cwf completion"
    if [ $is_zsh -eq 1 ]; then
      echo "if command -v cwf &>/dev/null; then"
      echo "  # Ensure compinit is loaded"
      echo "  autoload -Uz compinit 2>/dev/null || true"
      echo "  compinit -C 2>/dev/null || true"
      echo "  source <(cwf completion zsh)"
      echo "fi"
    else
      echo "if command -v cwf &>/dev/null; then"
      echo "  source <(cwf completion bash)"
      echo "fi"
    fi
  } >> "$shell_config"

  echo "✓ cwf completion installed to $shell_config"
  echo ""
  echo "Reload your shell to activate:"
  echo "  source $shell_config"
}

# ============================================================================
# Main Command Dispatcher (Refactored)
# ============================================================================

function main() {
  # Check for minimum arguments
  if [ $# -lt 1 ]; then
    show_usage
    return 1
  fi

  # Parse global flags
  local debug_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help|help)
        show_usage
        return 0
        ;;
      --debug)
        debug_mode=1
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  # Check for category after parsing flags
  if [ $# -lt 1 ]; then
    show_usage
    return 1
  fi

  local category="$1"
  shift

  # Handle completion commands separately (no prompt file needed)
  if [ "$category" = "completion" ]; then
    if [ $# -lt 1 ]; then
      echo "Error: Missing subcommand for completion"
      echo "Valid subcommands: bash, zsh, install"
      return 1
    fi

    local subcommand="$1"
    shift

    case "$subcommand" in
      bash)
        cmd_completion_bash "$@"
        return 0
        ;;
      zsh)
        cmd_completion_zsh "$@"
        return 0
        ;;
      install)
        cmd_completion_install "$@"
        return 0
        ;;
      *)
        echo "Error: Unknown completion subcommand '$subcommand'"
        echo "Valid subcommands: bash, zsh, install"
        return 1
        ;;
    esac
  fi

  # Check for subcommand (or extra context for prepare-release)
  local subcommand="${1:-}"
  local extra_context=""

  if [ "$category" = "prepare-release" ]; then
    # prepare-release doesn't have real subcommands, everything is context
    extra_context="$*"
  else
    if [ -z "$subcommand" ]; then
      echo "Error: Missing subcommand for category '$category'"
      echo ""
      show_usage
      return 1
    fi
    shift
    extra_context="${1:-}"
  fi

  # Resolve prompt file path
  local prompt_file=$(resolve_prompt_file "$category" "$subcommand" "$extra_context") || return 1

  # Validate prompt file exists
  if [ -n "$prompt_file" ] && [ ! -f "$prompt_file" ]; then
    echo "Error: Prompt file not found: $prompt_file" >&2
    return 1
  fi

  # Build system additions (rules + fragments) for caching optimization
  # This will be appended to Claude's system prompt and automatically cached
  local system_additions=$(build_system_additions "$prompt_file" "$category")

  # Process the prompt (load, remove template placeholders, add context)
  # Template content is now in system_additions instead
  local user_prompt=$(process_prompt "$prompt_file" "$category" "$extra_context") || return 1

  # Execute with claude using optimized caching
  # Rules are in system prompt (cached), user prompt is separate
  execute_prompt "$user_prompt" "$system_additions" "$debug_mode"
}

# Export function for use as a command
main "$@"
