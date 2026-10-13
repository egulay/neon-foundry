# Neon Foundry

An [Omarchy](https://omarchy.org/) theme with a pixel-art cast — nine workers,
a flying saucer, a black cat, a lamb, a devil, a snake and a handful of
beetles — gradient window borders, six wallpapers, and four animated unlock
screens.

![Neon Foundry](preview.png)

## Install

```bash
omarchy theme install https://github.com/egulay/neon-foundry
```

That gets you the palette, the gradient borders and the wallpapers. The
animated unlock screens are a shell plugin and need one more step, so for the
whole thing clone and run the installer instead:

```bash
git clone https://github.com/egulay/neon-foundry
cd neon-foundry
./install.sh
```

`install.sh` links the repo into `~/.config/omarchy/themes/neon-foundry`, so
editing it here updates the installed theme in place. Options:
`--theme-only` (skip the unlock screens), `--no-apply` (install without
switching). `./uninstall.sh` reverses it and restores the stock unlock screen.

## The palette

Six foundational colours, authored in oklch and converted to sRGB. The accents
are the colours the sprites are painted in.

| Role | Token | Hex |
|------|-------|-----|
| Background | `--bg` | `#060709` |
| Raised background | `--bg-raised` | `#0e0f12` |
| Foreground | `--fg` | `#edebe5` |
| Muted foreground | `--fg-muted` | `#8f9298` |
| Lines | `--line` | `#27292d` |
| Accent | `--accent` | `#baf700` |
| Links | `--link` | `#44e7ef` |

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

It ships with the `.example` suffix deliberately. Omarchy drops every `*.lua`
from a theme installed out of a git clone — a theme's `hyprland.lua` is loaded
at login, and a theme is not allowed to ship code — so a file named
`hyprland.lua` here would do nothing for anyone who ran `omarchy theme install`
while appearing to work for whoever wrote it. `install.sh` copies it into place
for a linked install, where Omarchy treats the theme as the user's own and does
load it; that copy is gitignored. **The gradient border does not depend on any
of this** — it lives in `colors.toml` and reaches every install.

## Wallpapers

Six, in `backgrounds/`, generated at 2880×1800. Cycle with
`omarchy theme bg next`.

| File | Scene |
|------|-------|
| `01-quarry.png` | Stock on the left, lattice rising right, the crew hauling between them |
| `02-abduction.png` | The saucer has a beetle off the ground; the rest scatter |
| `03-crew.png` | All nine, mid-shift, across three lanes |
| `04-lattice.png` | The finished snowflake, centred and lit |
| `05-patrol.png` | The snake winding across the frame, out of an open wormhole |
| `06-off-shift.png` | The cat, the lamb and the devil, each in their own light |

They are generated, not hand-drawn — `tools/gen_backgrounds.py` renders the
sprite matrices directly:

```bash
python3 -I tools/gen_backgrounds.py                 # all six, native size
python3 -I tools/gen_backgrounds.py --size 3840x2160 --seed 7
python3 -I tools/gen_backgrounds.py --only 04-lattice
```

`--seed` changes the snowflake and the scatter; every flake is a fresh draw —
one arm, mirrored through the eight symmetries of the square.

After regenerating, re-apply the theme:

```bash
omarchy theme set neon-foundry
```

`omarchy theme set` copies the theme into `~/.local/state/omarchy/current/theme/`
and the desktop reads from that copy, not from this directory. Linking the theme
keeps `colors.toml` and the lock screen's QML live, but a regenerated wallpaper
sits in the repo unseen until the theme is applied again.

`tools/` has no third-party dependencies: `canvas.py` is a small RGB buffer and
a PNG writer, because Pillow is not installed on a stock Omarchy box and every
shape here is an axis-aligned fill. ImageMagick, which Omarchy already ships,
lays the captions on afterwards.

## Unlock screens

![Unlock](preview-lock.png)

Four scenes, drawn at random each time the screen locks:

| | Scene |
|---|---|
| 0 | **Crew** — the crew hauling blocks along a lane near the foot of the screen |
| 1 | **Abduction** — the saucer crossing with its beam down, beetles bolting below |
| 2 | **Menagerie** — the cat crossing and settling, the lamb grazing, the devil ambling |
| 3 | **Patrol** — the snake working the grid, a wormhole turning at either end |

No logo, no clock, no user card — just the password field, as asked for. The
field carries the same gradient glow as a focused window. Hyprland's shadow
cannot reach it — the lock screen is a Quickshell surface, not a window it
manages — so `LockView.qml` draws it: the border's three stops on a blurred
rect behind the field. To pin
one scene instead of a random draw, set `variant` on the `FoundryScene` in
`~/.config/omarchy/plugins/<user>.lock/LockView.qml`:

```qml
FoundryScene {
    anchors.fill: parent
    variant: 2          // always the menagerie
    active: root.loadBackground
}
```

### How it works, and what is deliberately untouched

Omarchy's lock screen is **not hyprlock** — it is the Quickshell plugin
`omarchy.lock`. (The `unlock.png` that stock themes still ship is a dead
legacy asset; nothing reads it.) `install.sh` clones that plugin to
`~/.config/omarchy/plugins/<user>.lock` and replaces one file, `LockView.qml`,
between two marked comment blocks.

`Service.qml` — the PAM flows, the password and fingerprint handling — is left
byte-identical to Omarchy's. Authentication is not somewhere to be clever for
the sake of a wallpaper. The scene loader also swallows its own errors: if a
scene ever fails to load, the lock screen still comes up with its field.

The scene is only built while the lock is actually up
(`active: root.loadBackground`, which the service binds to `locked`).

It does **not** stop when the display blanks. Omarchy turns the backlight off
five seconds after locking (`idleBlankTimer` in `Service.qml`, which runs
`omarchy-brightness-display off`), but that only darkens the panel — the
compositor carries on, and so do these animations. The cost is a few dozen
animated rectangles, not a repainting canvas, so it is small; it is not zero.
To make the blank delay longer, raise that `interval` in your own clone's
`Service.qml` — at the price of diverging from the stock service.

If you edit a scene by hand, run `omarchy restart shell` afterwards. Saving a
file under `~/.config/omarchy/plugins/` reloads the plugin's service code, but
the `LockView` the shell already built stays cached: the lock screen goes on
rendering the previous view and reports no error at all. `install.sh` restarts
the shell for this reason.

If Omarchy's own `LockView.qml` gains features, re-clone it and re-apply that
one block rather than keeping this copy frozen.

## Boot and login screen

Separate from the lock screen above: Omarchy's Plymouth boot splash and its
SDDM login screen are set from a theme by

```bash
omarchy plymouth switcher        # pick a theme's boot/login screen
```

which needs two files, and fails with `Logo file not found` without the first:

| File | What it is |
|------|-----------|
| `unlock.png` | the mark, centred above the password entry. Copied to both themes as `logo.png` and **not** recoloured, so it keeps its colours. Must be a real file, never a symlink. |
| `preview-unlock.png` | a 1920x1080 mock of that screen; its presence is what lists the theme in the switcher. |

Both are generated from the lattice — the one piece of this theme's art that
carries no text:

```bash
python3 -I tools/gen_logo.py [--seed N]
```

The background and entry colours are not stored in either file: Omarchy reads
`background` and `foreground` straight out of `colors.toml` when it applies
them.

Note that `preview-unlock.png` previews the *boot* screen. The Quickshell lock
screen's own preview is `preview-lock.png`.

## Layout

```
colors.toml          the palette, and the gradient borders
hyprland.lua.example focused-window glow; install.sh puts it in place
icons.theme          Yaru-olive
chromium.theme       6,7,9
backgrounds/         six wallpapers
preview.png          theme picker
unlock.png           boot/login mark (Plymouth + SDDM)
preview-unlock.png   boot/login screen preview
preview-lock.png     lock screen preview
lock/                the unlock screens
  LockView.qml       stock view + one Neon Foundry block
  FoundryScene.qml   picks a scene at random
  FoundryPixel.qml   one pixel-art character
  FoundryGrid.qml    the grid they move on
  FoundrySprites.js  every sprite matrix, and the curve helpers
  Scene*.qml         the four scenes
tools/               wallpaper and login-asset generators
```

`btop.theme`, `neovim.lua`, the terminal configs and the rest are not shipped
on purpose: Omarchy generates them from `colors.toml`, and a file shipped here
would win over a template that gets fixed upstream.

## Licence

MIT — see [LICENSE](LICENSE).

`lock/LockView.qml` is a derivative of the `LockView.qml` that ships with
[Omarchy](https://github.com/basecamp/omarchy) (MIT, Copyright (c) David
Heinemeier Hansson). Most of that one file is Omarchy's; the Neon Foundry
change is the block marked inside it. Its licence is reproduced in `LICENSE`
under THIRD-PARTY NOTICES. Everything else here — the palette, the sprite
data, the wallpaper generator, the scenes — is this repository's own.

## Credit

Built for Omarchy.
