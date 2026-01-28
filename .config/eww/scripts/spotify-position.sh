#!/bin/bash
position=$(playerctl -p spotify position 2>/dev/null | cut -d'.' -f1)
if [ -n "$position" ]; then
    printf "%d:%02d" $((position/60)) $((position%60))
else
    echo "0:00"
fi
