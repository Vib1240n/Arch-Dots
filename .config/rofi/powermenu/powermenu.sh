#!/usr/bin/env bash
# ----------------------------------------------------- 
# Configuration
# ----------------------------------------------------- 
THEME="$HOME/.config/rofi/powermenu/powermenu.rasi"
# ----------------------------------------------------- 
# Toggle Logic
# ----------------------------------------------------- 
if pgrep -f "rofi -dmenu -theme $THEME" > /dev/null; then
    pkill -f "rofi -dmenu -theme $THEME"
    exit 0
fi
# ----------------------------------------------------- 
# Logic: Output options with specific icons
# ----------------------------------------------------- 
rofi_cmd() {
    rofi -dmenu \
        -theme "$THEME" \
        -p "Goodbye ${USER}" \
        -markup-rows \
        -format i \
        -theme-str 'configuration {show-icons: false;}' \
        -theme-str 'listview {columns: 6; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'element {padding: 15px 5px;}' \
        -theme-str 'window {width: 750px;}' \
        -theme-str 'inputbar {enabled: false;}'
}

run_rofi() {
    echo "<span size='x-large'>󰌾</span>  Lock"
    echo "<span size='x-large'>󰤄</span>  Sleep"
    echo "<span size='x-large'>󰒲</span>  Hibernate"
    echo "<span size='x-large'>󰍃</span>  Logout"
    echo "<span size='x-large'>󰜉</span>  Reboot"
    echo "<span size='x-large'>󰐥</span>  Shutdown"
}

# Run Rofi and capture choice
chosen=$(run_rofi | rofi_cmd)

# ----------------------------------------------------- 
# Actions
# ----------------------------------------------------- 
case "$chosen" in
    0) hyprlock ;;
    1) systemctl suspend ;;
    2) systemctl hibernate ;;
    3) hyprctl dispatch exit ;;
    4) systemctl reboot ;;
    5) systemctl poweroff ;;
esac
