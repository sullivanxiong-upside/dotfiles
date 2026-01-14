#!/bin/bash
IMAGE_NAME="$(date '+%Y%m%d_%Hh%Mm%Ss_grim.png')"
IMAGE_PATH="$HOME/Pictures/$IMAGE_NAME"

# Screenshot
grim -g "$(slurp -w 0)" $IMAGE_PATH

# Copy to clipboard
wl-copy < $IMAGE_PATH

