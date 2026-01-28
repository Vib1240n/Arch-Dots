#!/bin/bash
position=$(playerctl -p spotify position 2>/dev/null)
duration=$(playerctl -p spotify metadata mpris:length 2>/dev/null)

if [ -n "$position" ] && [ -n "$duration" ] && [ "$duration" -gt 0 ]; then
    duration=$((duration / 1000000))
    progress=$(awk "BEGIN {printf \"%.0f\", ($position / $duration) * 100}")
    echo "$progress"
else
    echo "0"
fi
