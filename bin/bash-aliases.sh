#!/bin/bash

# Linux-specific aliases
# This file contains Linux-specific aliases that are sourced by .bashrc
alias fetch="anifetch -ff ~/apps/manim/media/videos/img_to_mp4/2160p60/ImageToMP4LogoTest.mp4 -r 60 -W 25 -H 25 -c '--symbols wide --fg-only'"
alias font-cache="fc-cache -fv"
alias waybar-reload="killall waybar & hyprctl dispatch exec waybar"
# alias wayvncd="wayvnc -o=HDMI-A-1 --max-fps=30"
alias emoji="rofi -show emoji -modi emoji"
alias calc="rofi -show calc -modi calc"
alias fastfetch-small="fastfetch --config ~/.config/fastfetch/small_config.jsonc"
alias spotify-avahi-daemon="sudo systemctl start avahi-daemon"
alias password-reset="faillock --reset"

# Package management aliases
alias pkg-export="$HOME/repos/dotfiles/scripts/package-manager.sh export"
alias pkg-install="$HOME/repos/dotfiles/scripts/package-manager.sh install"
alias pkg-install-dry="$HOME/repos/dotfiles/scripts/package-manager.sh install-dry"
alias pkg-info="$HOME/repos/dotfiles/scripts/package-manager.sh info"
alias pkg-export-minimal="$HOME/repos/dotfiles/scripts/package-manager.sh export minimal"
alias pkg-export-aur="$HOME/repos/dotfiles/scripts/package-manager.sh export aur"
alias pkg-export-official="$HOME/repos/dotfiles/scripts/package-manager.sh export official"

# Quick package installation aliases
alias pkg-install-pacman="pkg-install packages-pacman.txt pacman"
alias pkg-install-aur="pkg-install packages-aur.txt yay"
alias pkg-install-dry-pacman="pkg-install-dry packages-pacman.txt pacman"
alias pkg-install-dry-aur="pkg-install-dry packages-aur.txt yay"

# Package management shortcuts
alias pkg-update="sudo pacman -Syu"
alias pkg-search="pacman -Ss"
alias pkg-search-installed="pacman -Qs"
alias pkg-remove="sudo pacman -R"
alias pkg-remove-orphans="sudo pacman -Rns \$(pacman -Qtdq)"
alias pkg-clean-cache="sudo pacman -Sc"
alias pkg-clean-all="sudo pacman -Scc"

# Package manager script help
alias pkg-help="$HOME/repos/dotfiles/scripts/package-manager.sh help"
alias pkg-export-all="pkg-export pacman packages-pacman.txt && pkg-export aur packages-aur.txt"

# Run fastfetch-small on shell startup (if fastfetch is available)
if command -v fastfetch &> /dev/null; then
    fastfetch --config ~/.config/fastfetch/small_config.jsonc
fi
