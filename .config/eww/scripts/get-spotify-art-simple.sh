#!/bin/bash

art_url=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)
art_path="/tmp/spotify-album.jpg"
fallback_path="$HOME/.cache/eww/spotify/default.png"

# Create fallback image if it doesn't exist
if [ ! -f "$fallback_path" ]; then
    mkdir -p "$HOME/.cache/eww/spotify"
    # Create a simple gray square as fallback
    convert -size 400x400 xc:'#282828' "$fallback_path" 2>/dev/null || {
        # If imagemagick isn't installed, try downloading
        curl -sf "https://via.placeholder.com/400x400/282828/282828.png" -o "$fallback_path" 2>/dev/null || {
            # Last resort: create an empty file (EWW will show broken icon but won't crash)
            echo "Fallback image not created" >&2
        }
    }
fi

if [ -n "$art_url" ]; then
    # Convert Spotify URL to direct image URL
    art_url=$(echo "$art_url" | sed 's|open.spotify.com/image/|i.scdn.co/image/|g')
    
    # Download with error checking
    if curl -sf "$art_url" -o "$art_path" 2>/dev/null; then
        echo "$art_path"
    else
        echo "$fallback_path"
    fi
else
    echo "$fallback_path"
fi
