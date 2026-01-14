#!/usr/bin/env bash
# Run ShellCheck on all shell scripts

set -euo pipefail

echo "→ Running ShellCheck on all .sh scripts..."

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    echo "ERROR: shellcheck not found. Install it first:"
    echo "  macOS: brew install shellcheck"
    echo "  Linux: pacman -S shellcheck (or apt install shellcheck)"
    exit 1
fi

# Find and check all shell scripts
FAIL=0
while IFS= read -r -d '' script; do
    echo "  Checking: $script"
    if ! shellcheck "$script"; then
        FAIL=1
    fi
done < <(find bin/ macos/ linux/ -type f -name "*.sh" -print0)

# Check scripts without .sh extension
for script in bin/cwf bin/gwf bin/git-aliases bin/grep-recursive bin/python-utility bin/mermaid-utility bin/cursor-agent bin/export-packages bin/package-manager bin/is-macos bin/is-linux; do
    if [[ -f "$script" ]]; then
        echo "  Checking: $script"
        if ! shellcheck "$script"; then
            FAIL=1
        fi
    fi
done

if [[ $FAIL -eq 0 ]]; then
    echo "✓ All scripts passed ShellCheck"
    exit 0
else
    echo "✗ Some scripts failed ShellCheck"
    exit 1
fi
