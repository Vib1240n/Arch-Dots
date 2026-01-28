#!/bin/bash
status=$(playerctl -p spotify status 2>/dev/null)
if [ "$status" = "Playing" ]; then
    echo "⏸"
else
    echo "▶"
fi
