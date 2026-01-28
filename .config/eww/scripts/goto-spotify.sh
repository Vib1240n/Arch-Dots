#!/bin/bash
spotify_workspace=$(hyprctl clients -j | jq -r '.[] | select(.class=="Spotify" or .class=="spotify") | .workspace.id' | head -1)
if [ -n "$spotify_workspace" ]; then
    hyprctl dispatch workspace "$spotify_workspace"
    eww close spotify-popup
else
    notify-send "Spotify not found" "Spotify is not running"
fi
