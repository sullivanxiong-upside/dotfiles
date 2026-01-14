#!/usr/bin/env bash
# macOS-specific installation steps

set -euo pipefail

echo "→ Running macOS-specific setup..."

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages if desired
# brew bundle --file=packages/Brewfile

echo "  ✓ macOS setup complete"
