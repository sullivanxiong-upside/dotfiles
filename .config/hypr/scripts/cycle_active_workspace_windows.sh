#!/bin/bash

# Get active workspaces (workspaces currently displayed on monitors)
active_workspaces=$(hyprctl monitors -j | jq -r '.[] | select(.activeWorkspace != null) | .activeWorkspace.id')

# Get all windows on active workspaces
windows=()
while IFS= read -r window; do
    windows+=("$window")
done < <(hyprctl clients -j | jq -r --argjson workspaces "$(echo "$active_workspaces" | jq -s '.')" '.[] | select(.workspace.id | IN($workspaces[])) | .address')

# Exit if no windows are found
if [ ${#windows[@]} -eq 0 ]; then
    exit 0
fi

# Get the currently focused window
current_window=$(hyprctl activewindow -j | jq -r '.address')

# Find the index of the current window in the windows array
current_index=-1
for i in "${!windows[@]}"; do
    if [[ "${windows[$i]}" == "$current_window" ]]; then
        current_index=$i
        break
    fi
done

reverse=false
if [[ "$1" == "-r" ]]; then
	reverse=true
fi

# Calculate the next window index (forward or reverse)
if [ "$reverse" = true ]; then
	 next_index=$(( (current_index - 1 + ${#windows[@]}) % ${#windows[@]} ))
else
	 next_index=$(( (current_index + 1) % ${#windows[@]} ))
fi

# Focus the next window
hyprctl dispatch focuswindow "address:${windows[$next_index]}"
