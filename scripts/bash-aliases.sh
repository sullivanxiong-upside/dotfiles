#!/bin/bash

# Linux-specific aliases
# This file contains Linux-specific aliases that are sourced by .bashrc
alias fetch="anifetch -ff ~/apps/manim/media/videos/img_to_mp4/2160p60/ImageToMP4LogoTest.mp4 -r 60 -W 25 -H 25 -c '--symbols wide --fg-only'"
alias font-cache="fc-cache -fv"
alias waybar-reload="killall waybar & hyprctl dispatch exec waybar"
# alias wayvncd="wayvnc -o=HDMI-A-1 --max-fps=30"
alias emoji="rofi -show emoji -modi emoji"
alias calc="rofi -show calc -modi calc"
alias fastfetch-small="fastfetch --config /home/suxiong/.config/fastfetch/small_config.jsonc"
alias spotify-avahi-daemon="sudo systemctl start avahi-daemon"
alias password-reset="faillock --reset"

# Package management aliases
alias pkg-export="~/repos/dotfiles/scripts/package-manager.sh export"
alias pkg-install="~/repos/dotfiles/scripts/package-manager.sh install"
alias pkg-info="~/repos/dotfiles/scripts/package-manager.sh info"
alias pkg-export-minimal="~/repos/dotfiles/scripts/package-manager.sh export minimal"
alias pkg-export-aur="~/repos/dotfiles/scripts/package-manager.sh export aur"
alias pkg-export-official="~/repos/dotfiles/scripts/package-manager.sh export official"

# Run fastfetch-small on shell startup
fastfetch-small