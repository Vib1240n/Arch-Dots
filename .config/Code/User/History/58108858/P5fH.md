# theme-switcher

A unified theming system for a Hyprland desktop. One command re-themes every app — GTK4 widgets, kitty, hyprland borders, hyprlock, waybar — by combining a color palette with a visual style.

## Concept

Themes are split into two independent axes:

- **Palette** — the colors only. Mocha, tokyonight, dracula, etc.
- **Visual** — radii, padding, opacities, fonts. Apple, material, kde-breeze, i3-flat, etc.

Any palette pairs with any visual. Want gruvbox colors on Material 3 shapes? `theme-apply --palette gruvbox-dark --visual material`. Want tokyonight in brutalist flat squares? `theme-apply --palette tokyonight --visual i3-flat`.

A small Python renderer reads the chosen palette + visual, fills out Jinja2 templates for each managed app, writes the output to that app's config location, and triggers a reload.

## Managed apps

| App           | Output                                       | Reload                                  |
| ------------- | -------------------------------------------- | --------------------------------------- |
| AGS bar       | `~/.config/ags/style.css`                    | restart via `run-bar.sh`                |
| rust-widgets  | `~/.config/rw/style.css`                     | `rw reload`                             |
| cliphist-gui  | `~/.config/cliphist-gui/style.css`           | `cliphist-gui --reload`                 |
| launch-gui    | `~/.config/launch-gui/style.css`             | `launch-gui --reload`                   |
| kitty         | `~/.config/kitty/colors.conf`                | `SIGUSR1`                               |
| Hyprland      | `~/.config/hypr/colors.conf`                 | `hyprctl reload`                        |
| Hyprland (layers) | `~/.config/hypr/layerrules-themed.conf`  | `hyprctl reload`                        |
| Hyprlock      | `~/.config/hypr/hyprlock-colors.conf`        | (read at next lock)                     |
| Waybar        | `~/.config/waybar/colors.css`                | `SIGUSR2`                               |

## Usage

```bash
theme-apply --palette mocha --visual apple        # set both
theme-apply --palette tokyonight                   # swap palette, keep current visual
theme-apply --visual i3-flat                       # swap visual, keep current palette
theme-apply --random                               # random palette + visual

theme-apply --list-palettes
theme-apply --list-visuals
theme-apply --list-apps
theme-apply --current                              # show what's currently applied

# Scope control
theme-apply --palette mocha --visual apple --only cliphist-gui,ags
theme-apply --palette mocha --visual apple --dry-run    # render to stdout, write nothing
theme-apply --palette mocha --visual apple --no-reload  # write files, skip reload signals

theme-apply -v ...                                 # verbose output
```

## Installation

Requires Python 3.11+ (for `tomllib`).

```bash
# Place the repository
mv theme-switcher ~/Development/theme-switcher

# Dependencies
pip install --user --break-system-packages jinja2

# PATH shim
mkdir -p ~/.local/bin
chmod +x ~/Development/theme-switcher/theme-apply.py
ln -sf ~/Development/theme-switcher/theme-apply.py ~/.local/bin/theme-apply

# Verify
theme-apply --list-palettes
theme-apply --list-visuals
```

## Wiring

theme-switcher renders configuration files but does not modify your main configs. Add these `include` / `source` / `@import` directives once.

| Main config                       | Add                                              |
| --------------------------------- | ------------------------------------------------ |
| `~/.config/kitty/kitty.conf`      | `include colors.conf`                            |
| `~/.config/hypr/hyprland.conf`    | `source = ~/.config/hypr/colors.conf`            |
| `~/.config/hypr/layerrules.conf`  | `source = ~/.config/hypr/layerrules-themed.conf` |
| `~/.config/hypr/hyprlock.conf`    | `source = ~/.config/hypr/hyprlock-colors.conf`   |
| `~/.config/waybar/style.css`      | `@import "colors.css";` (at top)                 |

The four managed GTK4 apps (ags, rust-widgets, cliphist-gui, launch-gui) read their `style.css` directly — no wiring needed.

### Conflicting layer rules

Layer rules for managed namespaces (`ags-bar`, `cliphist-gui`, `launch-gui`, `rust-widgets`, `rust-widgets-popup`) come from `layerrules-themed.conf`. Remove or comment any duplicate `blur` / `ignore_alpha` rules for these in your existing `layerrules.conf` to avoid conflicts. Non-blur rules (`animation`, `xray`) can stay in your main config.

### AGS bar — one prerequisite

The AGS bar must read its style from `~/.config/ags/style.css` (not inline). In `bar.tsx`:

```typescript
const STYLE_PATH = GLib.build_filenamev([GLib.get_home_dir(), ".config/ags/style.css"]);
let css: string;
try {
  const [ok, contents] = GLib.file_get_contents(STYLE_PATH);
  css = ok ? new TextDecoder().decode(contents) : "";
} catch (e) {
  css = "";
}
```

The `<window>` element must also have `cssClasses={["bar"]}` for the bar's container styling to apply.

## Backups

Every invocation backs up every destination file before writing. Backups go to:

```
~/Development/Logs/theme-switcher-backups/<YYYY-MM-DD_HHMMSS>/
```

with the original directory structure preserved (e.g. `.config/cliphist-gui/style.css`). The script never deletes backups; clean them out manually when desired.

## Layout

```
~/Development/theme-switcher/
├── CLAUDE.md                     # architecture notes
├── README.md
├── theme-apply.py                # renderer + dispatcher
├── state.toml                    # auto-written; current palette + visual
├── palettes/<name>.toml          # color definitions
├── visuals/<name>.toml           # radii, opacities, sizing
└── templates/<app>.<ext>.j2      # Jinja2 templates per managed app
```

## Adding themes

### New palette

Drop `palettes/<name>.toml` with all 16 color keys and a `meta.dark` flag (true/false). Pick up the schema from any existing palette.

```toml
[meta]
name = "my-palette"
dark = true

[color]
bg          = "#..."
bg_elevated = "#..."
bg_critical = "#..."
fg          = "#..."
fg_pure     = "#..."
border      = "#..."
shadow      = "#000000"
accent      = "#..."
red         = "#..."
yellow      = "#..."
green       = "#..."
blue        = "#..."
vim_normal  = "#..."
vim_insert  = "#..."
vim_bg      = "#..."
```

### New visual

Drop `visuals/<name>.toml` with `[radius]`, `[sizing]`, `[opacity.dark]`, `[opacity.light]`, and `[layer]` blocks. Both opacity modes are required.

## Adding a managed app

1. Write `templates/<app>.<ext>.j2`. Use `{{ color.* }}`, `{{ opacity.* }}`, `{{ radius.* }}`, `{{ sizing.* }}` placeholders.
2. Add an entry to the `APPS` dispatch table in `theme-apply.py` with the template name, output path, and reload command (or `None` if there's no reload).
3. Test with `--dry-run --only <app>` first.

## Troubleshooting

**App's theme didn't change after `theme-apply` ran.** Confirm the app reads its config from where theme-switcher writes it. Run with `-v` to see exactly which paths were written.

**Hyprland reports `source= globbing error: found no match`.** A `source =` line points to a file that doesn't exist yet. Run `theme-apply` at least once to generate it.

**Hyprland reports `invalid field blur: missing a value`.** Layer rules in 0.53+ require `blur on` (not bare `blur`). All generated rules use the correct syntax; check that you don't have stale rules in your main `layerrules.conf`.

**`theme-apply: command not found`.** The PATH shim wasn't created or `~/.local/bin` isn't in `$PATH`. Verify with `echo $PATH | tr ':' '\n' | grep local/bin`.

**Light palette is unreadable.** Each visual TOML has both `[opacity.dark]` and `[opacity.light]` blocks. The renderer selects automatically based on `palette.meta.dark`. If the light side looks washed out, tune `[opacity.light]` in the relevant visual.

**A render fails.** Errors are logged to stderr. The script aborts before any disk write if any template fails to render, so a broken template can't leave the system in a half-themed state.

## Constraints

- GTK4 CSS does not support `var(--name)` or `@define-color` cross-file. Templates are fully rendered every apply; nothing is loaded by reference at runtime.
- AGS bar restarts in full on reload (no live CSS swap). The restart takes <1s.
- Hyprlock has no live reload mechanism — new colors apply on next lock screen.
- Rust-widgets cliphist-gui / launch-gui have a `--theme` flag that is ephemeral (overridden on reload by config). theme-switcher bypasses this entirely by writing directly to each app's `style.css`.

## License

MIT.
