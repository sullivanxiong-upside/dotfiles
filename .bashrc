alias fetch="anifetch -ff ~/apps/manim/media/videos/img_to_mp4/2160p60/ImageToMP4LogoTest.mp4 -r 60 -W 25 -H 25 -c '--symbols wide --fg-only'"
alias vim="nvim"
alias font-cache="fc-cache -fv"
alias waybar-reload="killall waybar & hyprctl dispatch exec waybar"
# alias wayvncd="wayvnc -o=HDMI-A-1 --max-fps=30"
alias emoji="rofi -show emoji -modi emoji"
alias calc="rofi -show calc -modi calc"
alias fastfetch-small="fastfetch --config /home/suxiong/.config/fastfetch/small_config.jsonc"
alias spotify-avahi-daemon="sudo systemctl start avahi-daemon"
alias password-reset="faillock --reset"

fastfetch-small

TMUX_MAIN="main"
TMUX_TIME="time"
tmux has-session -t $TMUX_MAIN 2>/dev/null
if [ $? != 0 ]; then
	tmux new-session -d -s $TMUX_MAIN -n "editor"
	tmux new-session -d -s $TMUX_TIME -n "time"
	tmux clock-mode -t time
 
	# tmux send-keys -t $TMUX_MAIN:editor "cd ~/apps/" C-m

	tmux new-window -t $TMUX_MAIN -n "cli"
	tmux new-window -t $TMUX_MAIN -n "xtra"
 
	tmux select-window -t $TMUX_MAIN:editor
fi
if [ -z "$TMUX" ]; then
	tmux ls | grep main | grep attached 1>/dev/null
	if [ $? == 1 ]; then
		tmux attach -t $TMUX_MAIN
	fi
fi

# Created by `pipx` on 2025-08-19 22:32:46
export PATH="$PATH:/home/suxiong/.local/bin:/home/suxiong/.fly/bin"

eval "$(starship init bash)"
