# Secret Environment Variables Template
#
# SETUP INSTRUCTIONS:
# 1. Copy this file to ~/.config/zsh/secret.zsh:
#    cp ~/repos/dotfiles/home/.config/zsh/secret.template.zsh ~/.config/zsh/secret.zsh
#
# 2. Edit ~/.config/zsh/secret.zsh and replace placeholder values with your actual secrets
#
# 3. NEVER commit secret.zsh - it's gitignored by design
#
# This file is loaded automatically by .zshrc if it exists.

# Fireflies API Key
# Get your API key from: https://fireflies.ai/api
export FIREFLIES_API_KEY="your-fireflies-api-key-here"

# Add other secrets below as needed:
# export OPENAI_API_KEY="your-openai-key"
# export ANTHROPIC_API_KEY="your-anthropic-key"
# export AWS_SECRET_ACCESS_KEY="your-aws-secret"
# export GITHUB_TOKEN="your-github-token"
