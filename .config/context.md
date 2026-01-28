# Arch Linux Configuration Context

**User:** vib1240n
**Last Updated:** 2026-01-08
**Purpose:** Quick context for AI models to understand this Arch Linux rice setup

---

## System Overview

### Operating System
- **Distribution:** Arch Linux
- **Kernel:** 6.18.3-arch1-1
- **Display Protocol:** Wayland
- **Window Manager:** Hyprland (v0.53+ syntax)

### Hardware Configuration
- **Laptop Display:** eDP-1 (1920x1080@60Hz, 1.5 scale) - Currently disabled
- **Primary Monitor:** Dell AW3423DWF Ultrawide - DP-3 (3440x1440@164.90Hz, 1.25 scale)
- **Secondary Monitor:** HP OMEN 27qs - DP-4 (2560x1440@240Hz, vertical orientation, transform 3)

---

## Window Manager: Hyprland

### Core Configuration Files
- **Main:** `~/.config/hypr/hyprland.conf`
- **Keybinds:** `~/.config/hypr/keybinds.conf`
- **Monitors:** `~/.config/hypr/monitors.conf`
- **Lock Screen:** `~/.config/hypr/hyprlock.conf`
- **Idle Management:** `~/.config/hypr/hypridle.conf`

### Visual Style: "SeaGlass"
- **Border:** Animated gradient (cyan to blue to purple) - 3px width
- **Gaps:** Inner 3px, Outer 5px
- **Rounding:** 15px corners
- **Opacity:** Active 0.75, Inactive 0.65
- **Blur:** Enabled (size 8, 4 passes, with vibrancy)
- **Animations:** Custom bezier curves (myBezier: 0.05, 0.9, 0.1, 1.05)
- **Layout:** Dwindle (default), with Master layout available

### Key Binding Philosophy
This setup uses **macOS-inspired modifier combinations** to avoid conflicts:

- **HYPER** (Super+Ctrl+Alt+Shift) - Window focus, workspace switching, main launchers
- **MEH** (Ctrl+Alt+Shift) - Window movement, workspace movement
- **SUPER** - Mouse bindings, lock screen, launcher
- **SUPER+SHIFT** - Screenshots, audio device switching

#### Critical Keybinds
| Action | Binding |
|--------|---------|
| Window Focus (hjkl) | HYPER + H/J/K/L |
| Window Swap | MEH + H/J/K/L |
| Workspace Switch | HYPER + 1-8 |
| Move to Workspace | MEH + 1-8 |
| App Launcher | Super + Space |
| Terminal | HYPER + T |
| Browser (Zen) | HYPER + B |
| Code Editor (Zed) | HYPER + Z |
| Discord (Vesktop) | HYPER + D |
| File Manager | HYPER + Return |
| Kill Window | HYPER + Q |
| Lock Screen | Super + L |
| Screenshot Full | Super + Shift + 3 |
| Screenshot Area | Super + Shift + 4 |
| Clipboard Manager | HYPER + O |
| Toggle Special Workspace | HYPER + U |

#### Submodes
- **Resize Mode** (HYPER + R): HJKL for resizing, B for smart balance, T for toggle split
- **Service Mode** (HYPER + ;): R to reload Hyprland, W to restart Waybar

### Workspace Organization
- **Workspaces 1-5:** Primary monitor (DP-3)
  - WS 1: Terminals, Code editors (Kitty, Alacritty, Code, Zed)
  - WS 2: Browsers (Firefox, Zen, Chromium)
  - WS 3: Communication (Discord, Vesktop, Slack)
  - WS 5: BambuStudio (3D printing)
- **Workspaces 6-8:** Secondary monitor (DP-4)

### Idle & Lock Behavior
- **5 min:** Dim screen to 10%
- **10 min:** Lock session (hyprlock)
- **11 min:** Turn off displays (DPMS)
- **20 min:** Suspend system

### Autostart Applications
```bash
waybar              # Status bar
swaync              # Notification daemon
swww-daemon         # Wallpaper daemon
hypridle            # Idle management
gnome-keyring       # Secrets management
cliphist            # Clipboard history (text & images)
```

### Custom Scripts (`~/.config/hypr/scripts/`)
- `Screenshot.sh` - Grim + Slurp screenshot tool
- `WallpaperSelect.sh` - Interactive wallpaper selector
- `Volume.sh` - Volume control with notifications
- `Brightness.sh` - Brightness control
- `SubMapEnter.sh` / `SubMapExit.sh` - Visual mode indicators
- `toggle-layout.sh` - Switch between dwindle/master layouts
- `smart-balance.sh` - Intelligent window balancing

---

## Terminal & Shell

### Terminal: Kitty
**Config:** `~/.config/kitty/kitty.conf`

- **Font:** JetBrainsMono Nerd Font Mono, 14pt
- **Theme:** Tokyo Night inspired colors
- **Background:** #0d0d0d with 0.7 opacity, 40px blur
- **Cursor:** Underline style, orange (#fea639), no blink
- **Shell:** zsh with oh-my-zsh
- **Special Features:**
  - macOS/keyd compatibility (Ctrl+C copies, Ctrl+Shift+C interrupts)
  - 100,000 line scrollback
  - Window padding: 15px
  - Tab bar: Top, powerline style

### Shell: Zsh
**Config:** `~/.zshrc`

- **Framework:** oh-my-zsh
- **Theme:** robbyrussell (base)
- **Prompt:** oh-my-posh with peru.omp.json theme
- **Plugins:** git, nvm
- **Extensions:**
  - zsh-autosuggestions
  - zsh-syntax-highlighting
- **Startup:** fastfetch system info

---

## Status Bar: Waybar

**Config:** `~/.config/waybar/config.jsonc`
**Style:** `~/.config/waybar/style.css`

### Layout
- **Position:** Top
- **Height:** 10px
- **Margins:** 2px top, 5px sides
- **Modules:**
  - Left: Window title, Workspaces, Custom mode indicator
  - Center: Clock (12-hour format)
  - Right: CPU, Memory, Disk, Network speed, PulseAudio, Network, Battery

### Features
- Click clock to toggle SwayNC
- Click CPU/Memory to open btop in kitty
- Click network icon to toggle wifi menu (eww)
- Click audio to open custom audio selector
- Right-click audio for pavucontrol

---

## Application Launcher & Notifications

### Rofi
**Config:** `~/.config/rofi/config.rasi`

- **Font:** JetBrainsMono Nerd Font 12
- **Icon Theme:** Kora
- **Theme:** Custom style.rasi
- **Launch Scripts:**
  - `launcher.sh` - App launcher (Super + Space)
  - `clipboard.sh` - Clipboard manager (HYPER + O)
  - `powermenu.sh` - Power menu (Super + P)
  - `wp-audio.py` - Audio device selector

### SwayNC (Notification Center)
**Config:** `~/.config/swaync/config.json`

- **Position:** Center top, 45px margin
- **Size:** 400x600px
- **Timeout:** 5s normal, 3s low priority, infinite critical
- **Widgets:** Title, buttons grid, MPRIS, volume, backlight, DND, notifications
- **Quick Actions:** Network manager, Bluetooth, Wlogout, Pavucontrol

---

## Theme & Aesthetics

### GTK Theme
**Settings:** `~/.config/gtk-3.0/settings.ini` & `~/.config/gtk-4.0/settings.ini`

- **Theme:** Dracula
- **Icons:** Papirus-Dark
- **Font:** JetBrainsMono Nerd Font 11
- **Cursor:** Bibata-Modern-Ice (size 20)
- **Dark Mode:** Enabled
- **Window Decorations:** Custom CSS modules

### Color Scheme
Primary theme is a mix of:
- **Dracula** (GTK/base theme)
- **Tokyo Night** (Terminal colors)
- **Custom SeaGlass** (Hyprland borders - cyan/blue/purple gradient)

### Wallpapers
- **Location:** `~/Pictures/wallpapers/`
- **Current:** Tracked in `~/.cache/current-wallpaper`
- **Manager:** swww (Wayland wallpaper daemon)
- **Collections:** Space(Landscape), various 4K wallpapers

---

## System Monitor: btop

**Config:** `~/.config/btop/btop.conf`

- **Theme:** Default with truecolor
- **Graph Symbol:** Braille (highest resolution)
- **Shown Boxes:** mem, net, proc (no CPU box)
- **Update Rate:** 2000ms
- **Features:** Rounded corners, vim keys disabled, process gradients enabled

---

## Text Editor: Neovim

**Config:** `~/.config/nvim/`

- **Distribution:** AstroNvim (lazy.nvim based)
- **Plugin Manager:** Lazy.nvim
- **Structure:**
  - `init.lua` - Bootstrap
  - `lua/lazy_setup.lua` - Plugin configuration
  - `lua/polish.lua` - Final customizations
  - `lua/plugins/` - Plugin-specific configs (treesitter, astroui, astrolsp, mason, etc.)

---

## Clipboard Management

### Primary: Cliphist
- **Storage:** Wayland native (wl-paste/wl-copy)
- **Types:** Text and images
- **Access:** Via Rofi script (HYPER + O)

### Secondary: Clipse
**Config:** `~/.config/clipse/config.json`

- **Floating Window:** 900x700, centered, 0.85 opacity
- **Custom Theme:** `~/.config/clipse/custom_theme.json`

---

## File Manager & Associations

### Default File Manager: Nemo
- **Launch:** HYPER + Return
- **Config:** `~/.config/nemo/`

### MIME Associations (`~/.config/mimeapps.list`)
- **Web Browser:** Zen Browser
- **File Manager:** Nemo
- **Image Viewer:** imv (floating, macOS Quick Look style)

### IMV (Image Viewer) Styling
- Floating, centered, 60% width, 70% height
- 0.9 opacity with dim around effect
- Custom blue border (#00aaff)

---

## Audio & Media

### Volume Control
- **GUI:** PavuControl (floating window)
- **CLI Scripts:** `~/.config/hypr/scripts/Volume.sh`
- **Waybar Integration:** PulseAudio module with device selector
- **Device Switchers:** Custom bash scripts
  - Audio output: Super + Shift + O (`~/Development/bash_scripts/audio-switcher.sh`)
  - Mic input: Super + Shift + I (`~/Development/bash_scripts/mic-switcher.sh`)

### Media Keys
- XF86AudioRaiseVolume/LowerVolume/Mute - Volume control
- XF86AudioPlay/Next/Prev - Playerctl integration
- XF86MonBrightnessUp/Down - Brightness control

---

## Custom Utilities

### Fastfetch
**Config:** `~/.config/fastfetch/config.jsonc`

- **Logo:** Custom figlet banner "vib1240n"
- **Modules:** OS, Kernel, Uptime, WM, Terminal, Shell, CPU, GPU, Memory, Disk
- **Separator:** " → "

### EWW (ElKowars wacky widgets)
**Config:** `~/.config/eww/`

- Widget scripts for workspace info
- WiFi menu toggle integration
- Custom SCSS styling

---

## Development Environment

### Preferred Applications
- **Code Editor:** Zed (`zed`)
- **Browser:** Zen Browser (`zen-browser`)
- **Terminal:** Kitty
- **Communication:** Vesktop (Discord client)

### Environment Variables
```bash
CONFIG=$HOME/.config
DEV=$HOME/Development/
PATH includes: /home/vib1240n/.local/bin
XDG_DATA_DIRS includes Flatpak paths
```

---

## Package Management

### AUR Helper: Yay
**Config:** `~/.config/yay/`

---

## Cloud Storage

### Nextcloud
**Config:** `~/.config/Nextcloud/`

### Rclone
**Config:** `~/.config/rclone/`

---

## 3D Printing

### BambuStudio
**Config:** `~/.config/BambuStudio/`
- Dedicated to workspace 5
- Extensive filament profiles for BBL printers

---

## Important Notes for AI Models

### When Modifying Configs:

1. **Hyprland Syntax:** This uses v0.53+ syntax
   - Window rules: `windowrule = match:class ^(foo)$, action`
   - Layer rules: `layerrule = blur on, match:namespace foo`

2. **Keybind Philosophy:** Avoid single-key or simple modifier binds to prevent conflicts. Stick to HYPER/MEH convention.

3. **Transparency & Blur:** Nearly everything uses transparency + blur for the "SeaGlass" aesthetic. Adjust opacity values carefully.

4. **Monitor Setup:** Dual monitor (one vertical). Be aware of workspace assignments.

5. **Scripts First:** Many actions are handled by custom scripts in `~/.config/hypr/scripts/` - check these before modifying core config.

6. **Dracula + Tokyo Night:** Color scheme mixes these two themes. Don't assume pure Dracula or pure Tokyo Night.

7. **Nerd Fonts Required:** JetBrainsMono Nerd Font is essential for icons in terminal, waybar, rofi, etc.

### Common Tasks:

- **Change wallpaper:** HYPER + W (runs WallpaperSelect.sh)
- **Take screenshot:** Super + Shift + 3 (full) or 4 (area)
- **Lock screen:** Super + L
- **Reload Hyprland:** HYPER + ; → R
- **Restart Waybar:** HYPER + ; → W
- **Switch layouts:** HYPER + Y (dwindle ↔ master)
- **Resize windows:** HYPER + R (enters resize mode)

### File Locations Reference:

```
~/.config/
├── hypr/                 # Hyprland WM
│   ├── hyprland.conf    # Main config
│   ├── keybinds.conf    # All keybindings
│   ├── monitors.conf    # Display setup
│   ├── hyprlock.conf    # Lock screen
│   ├── hypridle.conf    # Idle/suspend
│   └── scripts/         # Custom automation
├── kitty/               # Terminal
├── waybar/              # Status bar
├── rofi/                # App launcher
├── swaync/              # Notifications
├── nvim/                # Text editor (AstroNvim)
├── btop/                # System monitor
├── fastfetch/           # System info
├── gtk-3.0/             # GTK3 theme
├── gtk-4.0/             # GTK4 theme
├── clipse/              # Clipboard manager
└── eww/                 # Custom widgets

~/.zshrc                 # Shell config
~/Pictures/wallpapers/   # Wallpaper collection
~/.cache/current-wallpaper  # Active wallpaper path
```

---

## Aesthetic Goals

This rice prioritizes:
1. **Transparency & Blur:** "SeaGlass" visual style
2. **Functionality:** macOS-inspired keybinds for productivity
3. **Minimal Distractions:** Clean interfaces, centered notifications
4. **Consistency:** Same fonts (JetBrainsMono NF) and color philosophy throughout
5. **Performance:** Wayland native, hardware acceleration, optimized blur settings

---

**End of Context Document**
