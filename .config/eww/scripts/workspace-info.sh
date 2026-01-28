#!/bin/bash

get_icon() {
    case "$1" in
        kitty|Alacritty|WezTerm) echo "" ;;
        firefox|Firefox|zen|chromium|Google-chrome) echo "" ;;
        discord|Discord|vesktop|Vesktop) echo "󰙯" ;;
        Code|code|VSCodium) echo "" ;;
        Spotify|spotify) echo "" ;;
        *) echo "" ;;
    esac
}

output_workspace() {
    local ws_id=$(hyprctl activeworkspace -j | jq -r '.id')
    
    local windows=$(hyprctl clients -j | jq -r --arg ws "$ws_id" '
        [.[] | select(.workspace.id == ($ws | tonumber))] | 
        map({class: .class, title: .title})
    ')
    
    if [ "$windows" = "[]" ]; then
        echo "{\"id\": $ws_id, \"windows\": [{\"icon\": \"\", \"title\": \"Empty workspace\"}]}"
    else
        local result="{\"id\": $ws_id, \"windows\": ["
        local first=true
        
        while IFS= read -r line; do
            local class=$(echo "$line" | jq -r '.class')
            local title=$(echo "$line" | jq -r '.title' | head -c 50)
            local icon=$(get_icon "$class")
            
            if [ "$first" = true ]; then
                first=false
            else
                result+=","
            fi
            
            result+="{\"icon\": \"$icon\", \"title\": \"$title\"}"
        done < <(echo "$windows" | jq -c '.[]')
        
        result+="]}"
        echo "$result"
    fi
}

output_workspace

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
    while read -r line; do
        if [[ "$line" == workspace* ]] || [[ "$line" == openwindow* ]] || [[ "$line" == closewindow* ]]; then
            output_workspace
        fi
    done
