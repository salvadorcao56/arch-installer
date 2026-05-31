#!/bin/sh
#

pkill conky
# (sleep 6 ; conky -c $HOME/.config/i3/conky) &
# (sleep 6 ; conky -c $HOME/.config/i3/conky.conkyrc) &

autotiling &

######## DO NOT REMOVE THIS BLOCK ########
systemctl --user restart utilities
######## DO NOT REMOVE THIS BLOCK ########
