#!/bin/bash

current=$(setxkbmap -query | grep layout | awk '{print $2}')

if [ "$current" = "us" ]; then
  setxkbmap -layout ara,us -option grp:alt_shift_toggle -option grp:win_space_toggle
else
  setxkbmap -layout us,ara -option grp:alt_shift_toggle -option grp:win_space_toggle
fi
