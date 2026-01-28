#!/bin/bash
art_url=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)
art_path="/tmp/spotify-album.jpg"

if [ -n "$art_url" ]; then
    # Convert Spotify URL to direct image URL
    art_url=$(echo "$art_url" | sed 's|open.spotify.com/image/|i.scdn.co/image/|g')
    
    # Download with error checking
    if curl -sf "$art_url" -o "$art_path" 2>/dev/null; then
        echo "file://$art_path"
    else
        echo ""
    fi
else
    echo ""
fi
