#!/bin/bash
# Install Neon Foundry: the theme, and optionally the animated unlock screens.
#
#   ./install.sh              theme + lock screens
#   ./install.sh --theme-only just the palette, borders and wallpapers
#   ./install.sh --no-apply   install but do not switch to it
#
# The theme is linked rather than copied, so editing this repo updates the
# installed theme in place. Omarchy treats a symlinked theme directory as the
# user's own, which is what keeps the .lua in it from being stripped.

set -euo pipefail

THEME_NAME="neon-foundry"
THEME_DISPLAY="Neon Foundry"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$HOME/.config/omarchy/themes"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
LOCK_ID="${USER:-$(id -un)}.lock"

install_lock=1
apply=1
for arg in "$@"; do
  case "$arg" in
  --theme-only) install_lock=0 ;;
  --no-apply) apply=0 ;;
  -h | --help)
    sed -n '2,12p' "$0" | sed 's/^# \?//'
    exit 0
    ;;
  *)
    echo "install.sh: unknown option: $arg" >&2
    exit 1
    ;;
  esac
done

say() { printf '\033[32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m==>\033[0m %s\n' "$*" >&2; }

# --- the theme --------------------------------------------------------------
mkdir -p "$THEMES_DIR"
target="$THEMES_DIR/$THEME_NAME"

if [[ -e $target && ! -L $target ]]; then
  warn "$target exists and is a real directory, not a link."
  warn "Move it aside first if you want this repo to drive the theme."
  exit 1
fi

ln -nsf "$SOURCE_DIR" "$target"
say "Linked $target -> $SOURCE_DIR"

if [[ ! -d $SOURCE_DIR/backgrounds ]] || ! compgen -G "$SOURCE_DIR/backgrounds/*.png" >/dev/null; then
  warn "No wallpapers found. Generating them now."
  python3 -I "$SOURCE_DIR/tools/gen_backgrounds.py"
fi

# --- the lock screen --------------------------------------------------------
# The unlock screen is a Quickshell plugin, not hyprlock. Cloning Omarchy's
# built-in omarchy.lock gives a copy this theme can paint on; only the view is
# replaced, so the PAM flows in Service.qml stay exactly as Omarchy ships them.
if ((install_lock)); then
  lock_dir="$PLUGINS_DIR/$LOCK_ID"

  if [[ ! -d $lock_dir ]]; then
    say "Cloning omarchy.lock -> $LOCK_ID"
    omarchy plugin clone omarchy.lock
  else
    say "Using existing clone at $lock_dir"
  fi

  if [[ ! -f $lock_dir/Service.qml ]]; then
    warn "$lock_dir has no Service.qml — not a lock clone. Skipping lock install."
  else
    # Keep a pristine copy of the stock view once, so uninstall can restore it.
    if [[ ! -f $lock_dir/LockView.qml.orig ]]; then
      cp "$lock_dir/LockView.qml" "$lock_dir/LockView.qml.orig"
    fi

    for f in LockView.qml FoundryPixel.qml FoundryGrid.qml FoundryScene.qml \
      FoundrySprites.js SceneCrew.qml SceneAbduction.qml SceneMenagerie.qml \
      ScenePatrol.qml; do
      cp "$SOURCE_DIR/lock/$f" "$lock_dir/$f"
    done
    say "Installed the Neon Foundry unlock screens into $lock_dir"

    # Plugin code reloads on save, but nudge it in case the watcher missed it.
    omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  fi
fi

# --- apply ------------------------------------------------------------------
if ((apply)); then
  say "Applying $THEME_DISPLAY"
  omarchy theme set "$THEME_NAME"
fi

cat <<DONE

$THEME_DISPLAY is installed.

  omarchy theme set "$THEME_DISPLAY"   apply it
  omarchy theme bg next                 cycle the six wallpapers
  omarchy system lock                   see a random unlock scene

To pin one unlock scene instead of a random draw, set the variant property (0-3) on
FoundryScene in ~/.config/omarchy/plugins/$LOCK_ID/LockView.qml.
DONE
