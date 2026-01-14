#!/usr/bin/env bash
# SwiftBar plugin — updates every 10 seconds

PT=$(TZ="America/Los_Angeles" date +"%H:%M")
UTC=$(date -u +"%H:%M")

# Use FULL-WIDTH vertical bar (U+FF5C) between PT and UTC
# It looks like a normal pipe but avoids SwiftBar pipe parsing.
printf "PT %s ｜ UTC %s\n" "$PT" "$UTC"
