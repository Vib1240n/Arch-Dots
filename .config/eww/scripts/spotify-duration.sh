#!/bin/bash
duration=$(playerctl -p spotify metadata mpris:length 2>/dev/null)
if [ -n "$duration" ]; then
    duration=$((duration / 1000000))
    printf "%d:%02d" $((duration/60)) $((duration%60))
else
    echo "0:00"
fi
