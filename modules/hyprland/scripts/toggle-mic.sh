#!/bin/bash
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "[MUTED]"; then
    hyprctl notify 1 2000 "rgb(ff5555)" "Microphone: OFF"
else
    hyprctl notify 1 2000 "rgb(55ff55)" "Microphone: ON"
fi
