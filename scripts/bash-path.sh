#!/bin/bash

# Bash path and environment configuration
# This file contains PATH exports and shell initialization for bash

# Created by `pipx` on 2025-08-19 22:32:46
export PATH="$PATH:$HOME/.local/bin:$HOME/.fly/bin"

# Initialize starship prompt
eval "$(starship init bash)"
