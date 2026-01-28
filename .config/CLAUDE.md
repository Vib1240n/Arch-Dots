# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **dotfiles repository** for an Arch Linux rice configuration using Hyprland (Wayland compositor). The configuration implements a "SeaGlass" aesthetic with transparency, blur effects, and a cohesive macOS-inspired workflow.

**Key Reference:** See `context.md` for comprehensive system details, hardware setup, and aesthetic philosophy.

## Architecture & Configuration Structure

### Modular Hyprland Configuration
The Hyprland config is split across multiple files sourced from `hypr/hyprland.conf`:
- `hyprland.conf` - Main config (appearance, animations, window rules, autostart)
- `keybinds.conf` - All keybindings and submodes
- `monitors.conf` - Display configuration (dual monitor: ultrawide + vertical)
- `hyprlock.conf` - Lock screen styling
- `hypridle.conf` - Idle/suspend timers

**Critical:** When modifying Hyprland configs, use **v0.53+ syntax**:
- Window rules: `windowrule = match:class ^(foo)$, action`
- Layer rules: `layerrule = blur on, match:namespace foo`

### Script Architecture Pattern

All custom scripts follow this pattern:
```
~/.config/<component>/scripts/<script-name>.sh
```

Scripts communicate via:
- **Waybar integration:** Scripts called via `on-click` handlers in `waybar/config.jsonc`
- **State files:** `/tmp/hypr_mode` for submode indicators (read by Waybar custom module)
- **Cache files:** `~/.cache/current-wallpaper` for persistence across sessions
- **Hyprland IPC:** `hyprctl` commands for dynamic config changes
- **Notifications:** `notify-send` for user feedback

### Critical Dependencies

**Required system utilities:**
- `swww` - Wallpaper daemon (NOT swaybg)
- `wpctl` (WirePlumber) - Audio control (NOT pactl)
- `grim` + `slurp` - Screenshots
- `cliphist` - Clipboard manager
- `notify-send` - Notifications
- `hyprctl` - Hyprland IPC
- `jq` - JSON parsing in scripts

## Testing & Validation

### Reload Configuration Changes

**Hyprland config:**
```bash
hyprctl reload
# OR via keybind: HYPER + ; → R (enter service mode, press R)
```

**Waybar:**
```bash
pkill waybar && waybar &
# OR via keybind: HYPER + ; → W
```

**Theme changes (GTK):**
```bash
# Changes require app restart or:
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
```

### Test Scripts Individually

Scripts can be run directly for testing:
```bash
~/.config/hypr/scripts/Volume.sh up
~/.config/hypr/scripts/WallpaperSelect.sh
~/.config/rofi/scripts/clipboard.sh
```

**Important:** Scripts assume `notify-send`, `hyprctl`, and other utilities are in PATH.

### Validate Hyprland Syntax

```bash
# Check for syntax errors (Hyprland will output to stderr):
hyprctl reload 2>&1 | grep -i error
```

## Critical Design Patterns

### Keybind Philosophy: HYPER/MEH Modifiers

This config uses **macOS-style modifier combinations** to avoid conflicts:
- **HYPER** = Super+Ctrl+Alt+Shift (window focus, workspace switch, launchers)
- **MEH** = Ctrl+Alt+Shift (window/workspace movement)
- Single modifiers (Super, Ctrl+Shift) reserved for system/media keys

**When adding keybinds:**
1. Never use single keys or common shortcuts (Ctrl+C, etc.) - they conflict with applications
2. Prefer HYPER/MEH for consistency
3. Check `keybinds.conf` for existing bindings
4. Media keys (XF86Audio*, XF86Mon*) use `bindl`/`bindel` (no repeat/repeat edge)

### Submode System (Modal Keybindings)

Hyprland uses "submodes" like Vim modes:
- **Resize mode** (HYPER+R): HJKL resize, B balance, T toggle split
- **Service mode** (HYPER+;): R reload, W restart waybar

**Submode flow:**
1. `SubMapEnter.sh <mode-name>` → writes mode name to `/tmp/hypr_mode`
2. Waybar `custom/mode` module displays current mode
3. Actions execute then call `SubMapExit.sh` → clears `/tmp/hypr_mode` + `submap reset`

**When creating new submodes:**
```bash
# In keybinds.conf:
bind = HYPER, X, exec, ~/.config/hypr/scripts/SubMapEnter.sh mymode
bind = HYPER, X, submap, mymode

submap = mymode
bind = , A, exec, my-action
bind = , A, exec, ~/.config/hypr/scripts/SubMapExit.sh
bind = , escape, exec, ~/.config/hypr/scripts/SubMapExit.sh
submap = reset
```

### State Persistence Pattern

**Wallpaper persistence:**
1. User selects wallpaper → `WallpaperSelect.sh`
2. Script saves path to `~/.cache/current-wallpaper`
3. On boot, `hyprland.conf` autostart reads cache: `swww img "$(cat ~/.cache/current-wallpaper)"`

**Use this pattern for other stateful configs** (last layout, last audio device, etc.)

### Rofi Script Pattern

All Rofi scripts follow this toggle pattern:
```bash
# Kill existing instance if running
if pgrep -x "rofi" > /dev/null; then
    pkill -x rofi
    exit 0
fi

# Launch rofi with specific config
rofi -show drun -theme "$THEME"
```

### Notification Standardization

Use consistent notification styling:
```bash
notify-send -h string:x-canonical-private-synchronous:<category> \
            -h int:value:<percentage> \
            -u low \
            "Title" \
            "Body" \
            -i <icon-name>
```

`x-canonical-private-synchronous` ensures notifications replace previous ones (for volume, brightness).

## Common Modifications

### Adding a New Keybind

1. **Edit** `hypr/keybinds.conf`
2. **Choose modifier:** HYPER for main actions, MEH for movement
3. **Add bind:**
   ```
   bind = SUPER CTRL ALT SHIFT, X, exec, your-command
   ```
4. **Reload:** `hyprctl reload`

### Adding a New Script

1. **Create script:** `~/.config/hypr/scripts/my-script.sh`
2. **Make executable:** `chmod +x ~/.config/hypr/scripts/my-script.sh`
3. **Wire to keybind** in `keybinds.conf`
4. **Test:** Run script directly, check for errors

### Changing Theme Colors

**Hyprland borders:**
- Edit `hypr/hyprland.conf` → `general { col.active_border = ... }`
- Current: Animated gradient `rgb(00b8ff) rgb(001eff) rgb(bd00ff) rgb(d600ff) 30deg`

**GTK theme:**
- Edit `gtk-3.0/settings.ini` and `gtk-4.0/settings.ini`
- Change `gtk-theme-name=` or `gtk-icon-theme-name=`

**Terminal (Kitty):**
- Edit `kitty/kitty.conf` → color0-color15 section

**Waybar:**
- Edit `waybar/style.css` for colors/styling
- Edit `waybar/config.jsonc` for modules/layout

### Adding Waybar Module

1. **Edit** `waybar/config.jsonc`:
   ```json
   "modules-right": [..., "custom/mymodule"]
   ```
2. **Define module:**
   ```json
   "custom/mymodule": {
       "format": "{}",
       "exec": "~/.config/waybar/scripts/my-script.sh",
       "interval": 5
   }
   ```
3. **Create script** in `waybar/scripts/`
4. **Restart:** `pkill waybar && waybar &`

### Modifying Window Rules

**Auto-assign app to workspace:**
```conf
# In hyprland.conf:
windowrule = match:class ^(myapp)$, workspace 4 silent
```

**Float specific windows:**
```conf
windowrule = match:class ^(myapp)$, float on
windowrule = match:class ^(myapp)$, size 800 600
windowrule = match:class ^(myapp)$, center on
```

**Find window class:**
```bash
hyprctl clients | grep -i "class"
```

### Changing Monitor Configuration

**Edit** `hypr/monitors.conf`:
```conf
# Format: monitor = NAME, WIDTHxHEIGHT@REFRESH, POS_X x POS_Y, SCALE, transform, ROTATION
monitor = DP-3, 3440x1440@164.90, 0x1408, 1.25

# Disable a monitor:
monitor = eDP-1, disable
```

**Find monitor names:**
```bash
hyprctl monitors
```

## Important Constraints

### DO NOT Break These Patterns

1. **Keybind conflicts:** Never use Ctrl+C, Ctrl+V, or other standard shortcuts - they're remapped for macOS compatibility in Kitty
2. **Script execution:** Always use full paths in configs (`~/.config/...`) - relative paths fail in autostart
3. **Wallpaper daemon:** Use `swww`, NOT `swaybg` - different syntax/features
4. **Audio control:** Use `wpctl`, NOT `pactl` - this system uses WirePlumber
5. **Notification sync:** Always include `x-canonical-private-synchronous` for volume/brightness
6. **Submode exit:** Submodes MUST have escape/return binds calling `SubMapExit.sh`
7. **Hyprland syntax:** Window/layer rules use v0.53+ syntax with `match:` prefix
8. **Opacity values:** SeaGlass aesthetic requires transparency - don't set opaque windows unless necessary

### File Watching Caveats

- `/tmp/hypr_mode` - Waybar polls this every 1s, don't write too frequently
- `~/.cache/current-wallpaper` - Only written on user wallpaper change

## Environment & Paths

**Key environment variables** (from `~/.zshrc`):
```bash
CONFIG=$HOME/.config
DEV=$HOME/Development/
PATH includes: $HOME/.local/bin
```

**Refer to these in scripts:**
```bash
WALL_DIR="$HOME/Pictures/wallpapers"  # Wallpaper storage
CACHE_DIR="$HOME/.cache"              # Persistence
```

## External Script Dependencies

Some keybinds reference scripts outside `~/.config`:
- `~/Development/bash_scripts/audio-switcher.sh` - Audio device menu (Super+Shift+O)
- `~/Development/bash_scripts/mic-switcher.sh` - Mic device menu (Super+Shift+I)

**Check existence before modifying related configs.**

## Quick Diagnostics

**Hyprland not starting:**
```bash
# Check logs:
cat /tmp/hypr/$(ls -t /tmp/hypr | head -1)/hyprland.log
```

**Waybar not showing:**
```bash
# Check if running:
pgrep waybar
# Check logs:
waybar 2>&1 | grep -i error
```

**Script not executing:**
```bash
# Check permissions:
ls -la ~/.config/hypr/scripts/
# Test directly:
bash -x ~/.config/hypr/scripts/Volume.sh up
```

**Keybind not working:**
```bash
# Check for conflicts:
hyprctl binds | grep -i "your-key"
```
