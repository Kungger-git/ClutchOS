#!/bin/env bash

# sets wallpaper using feh
bash $HOME/.dwm/.fehbg

# starts dwmblocks
dwmblocks &

# kill if already running
killall -9 picom xfce4-power-manager dunst

# Launch notification daemon
dunst \
-geom "280x50-10+38" -frame_width "1" -font "Source Code Pro Medium 10" \
-lb "#0B0930FF" -lf "#7dc8d0FF" -lfr "#578c91FF" \
-nb "#0B0930FF" -nf "#7dc8d0FF" -nfr "#578c91FF" \
-cb "#2E3440FF" -cf "#BF616AFF" -cfr "#BF616AFF" &

# start compositor and power manager
xfce4-power-manager &
picom --config $HOME/.dwm/picom.conf &

# start polkit
if [[ ! `pidof xfce-polkit` ]]; then
    /usr/lib/xfce-polkit/xfce-polkit &
fi

# start udiskie
udiskie &
