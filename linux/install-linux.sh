#!/usr/bin/env bash
# Linux-specific installation steps

set -euo pipefail

echo "→ Running Linux-specific setup..."

# Detect distribution
if command -v pacman &> /dev/null; then
    echo "  Detected: Arch Linux"
    # pacman -S --needed - < packages/pacman.txt
elif command -v apt &> /dev/null; then
    echo "  Detected: Ubuntu/Debian"
    # apt install $(cat packages/ubuntu.txt)
fi

echo "  ✓ Linux setup complete"
