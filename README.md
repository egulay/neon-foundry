# Neon Foundry

An [Omarchy](https://omarchy.org/) theme with a pixel-art cast — nine workers,
a flying saucer, a black cat, a lamb, a devil, a snake and a handful of
beetles — gradient window borders, six wallpapers, and a boot and login screen
to match.

![Neon Foundry](preview.png)

## Install

```bash
omarchy theme install https://github.com/egulay/neon-foundry
```

That is the whole theme: palette, gradient borders, wallpapers, boot and login
screen. Omarchy's gallery lists repositories that carry no code, so everything
that runs lives in a repository of its own:

**[neon-foundry-tools](https://github.com/egulay/neon-foundry-tools)** — four
animated unlock screens, the generators behind the wallpapers and the boot
screen, and scripts that put GTK apps and browsers on the theme's colours. Its
`./install.sh` sets up the theme and the unlock screens together.

## The palette

Six foundational colours, authored in oklch and converted to sRGB. The accents
are the colours the sprites are painted in.

| `colors.toml` | oklch | Hex |
|------|-------|-----|
| `background` | `0.13 0.005 260` | `#060709` |
| `lighter_background` | `0.17 0.006 260` | `#0e0f12` |
| `foreground` | `0.94 0.008 90` | `#edebe5` |
| `dark_foreground` | `0.66 0.01 260` | `#8f9298` |
| `selection` | `0.28 0.008 260` | `#27292d` |
| `accent` | `0.90 0.24 125` | `#baf700` |
| `cyan` | `0.85 0.13 200` | `#44e7ef` |

Sprite palette: `#c8ff00` acid · `#ff5a1f` orange · `#31e5ff` cyan ·
`#ff2e8b` magenta · `#f5f2ea` cream. Terminal red is the devil's `#ff3b3b`,
yellow the cat's halo gold `#f2c14e`, blue the lamb's aura `#a8ecff`.

## Gradient borders

Declared in `colors.toml`, not in `hyprland.lua`:

```toml
hyprland_active_border = "rgba(c8ff00ee) rgba(31e5ffee) rgba(ff2e8bee) 45deg"
```

This matters. Omarchy strips every `.lua` from a theme installed from a git
repo — a theme's `hyprland.lua` is loaded at login, so it is not allowed to
ship code — and regenerates it from `colors.toml`. Putting the gradient in the
palette is the form that survives `omarchy theme install`. The same value feeds
the shell, which is what puts the gradient on the bar's popups and on the lock
screen's password field.

`hyprland.lua.example` carries the one thing no template can express: a glow
under the focused window, with the border's three stops on the same 45-degree
sweep, so the corner that is magenta on the border is magenta underneath it too.

It ships with the `.example` suffix deliberately: named `hyprland.lua` it would
do nothing for anyone who ran `omarchy theme install`, while appearing to work
for whoever wrote it. The `install.sh` in neon-foundry-tools copies it into
place for a linked theme, where Omarchy treats the theme as the user's own and
does load it; that copy is ignored by git here. **The gradient border does not
depend on any of this** — it lives in `colors.toml` and reaches every install.

## Wallpapers

Six, in `backgrounds/`, at 2880×1800. Cycle with `omarchy theme bg next`, or
`SUPER + CTRL + SPACE` for the switcher.

| File | Scene |
|------|-------|
| `01-quarry.png` | Stock on the left, lattice rising right, the crew hauling between them |
| `02-abduction.png` | The saucer has a beetle off the ground; the rest scatter |
| `03-crew.png` | All nine, mid-shift, across three lanes |
| `04-lattice.png` | The finished snowflake, centred and lit |
| `05-patrol.png` | The snake winding across the frame, out of an open wormhole |
| `06-off-shift.png` | The cat, the lamb and the devil, each in their own light |

They are generated, not hand-drawn, by `gen_backgrounds.py` in
neon-foundry-tools, from the same sprite data the unlock screens animate; every
snowflake is a fresh draw from a seed. After regenerating into this directory,
re-apply the theme with `omarchy theme set neon-foundry`: Omarchy copies the
theme into `~/.local/state/omarchy/current/theme/` and the desktop reads from
that copy.

## Unlock screens

![Unlock](preview-lock.png)

Four scenes, one at random per lock — a work crew, a saucer abducting a
beetle, a cat and lamb and devil, a snake out of a wormhole. No logo, no
clock, no user card: the password field with the gradient's glow, and the
characters moving behind it. They are a Quickshell plugin, which a theme
install cannot deliver, so
[neon-foundry-tools](https://github.com/egulay/neon-foundry-tools) installs
them.

## Boot and login screen

Omarchy's Plymouth boot splash and its SDDM login screen are set from a theme
by

```bash
omarchy plymouth switcher
```

which needs two files here:

| File | What it is |
|------|-----------|
| `unlock.png` | the mark, centred above the password entry — the lattice. Copied to both themes as `logo.png` and never recoloured. |
| `preview-unlock.png` | a 1920×1080 mock of that screen; its presence is what lists the theme in the switcher. |

The background and entry colours are not stored in either: Omarchy reads
`background` and `foreground` out of `colors.toml` when it applies them. Both
files are generated by `gen_logo.py` in neon-foundry-tools.

`preview-unlock.png` previews the *boot* screen; `preview-lock.png` is the
lock screen.

## Layout

```
colors.toml          the palette, and the gradient borders
hyprland.lua.example focused-window glow; neon-foundry-tools puts it in place
icons.theme          Yaru-olive
chromium.theme       6,7,9
backgrounds/         six wallpapers
preview.png          theme picker
unlock.png           boot/login mark (Plymouth + SDDM)
preview-unlock.png   boot/login screen preview
preview-lock.png     lock screen preview
```

`btop.theme`, `neovim.lua`, the terminal configs and the rest are not shipped
on purpose: Omarchy generates them from `colors.toml`, and a file shipped here
would win over a template that gets fixed upstream.

## Licence

MIT — see [LICENSE](LICENSE). Nothing here is derived from anything else; the
one Omarchy-derived file, the lock view, lives in neon-foundry-tools with its
notice.

## Credit

Built for Omarchy.
