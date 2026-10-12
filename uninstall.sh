#!/bin/bash
# Remove Neon Foundry: unlink the theme and put the stock unlock screen back.
#
# The lock clone itself is left in place (it is yours, and may hold other
# edits); only the view is restored. Pass --remove-lock-clone to drop it
# entirely and go back to Omarchy's built-in omarchy.lock.

set -euo pipefail

THEME_NAME="neon-foundry"
THEMES_DIR="$HOME/.config/omarchy/themes"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
LOCK_ID="${USER:-$(id -un)}.lock"

remove_clone=0
[[ ${1:-} == "--remove-lock-clone" ]] && remove_clone=1

say() { printf '\033[32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m==>\033[0m %s\n' "$*" >&2; }

target="$THEMES_DIR/$THEME_NAME"
if [[ -L $target ]]; then
  rm "$target"
  say "Unlinked $target"
elif [[ -e $target ]]; then
  warn "$target is a real directory; leaving it alone."
fi

lock_dir="$PLUGINS_DIR/$LOCK_ID"
if [[ -d $lock_dir ]]; then
  if ((remove_clone)); then
    rm -rf "$lock_dir"
    say "Removed $lock_dir — the built-in omarchy.lock takes over again"
  elif [[ -f $lock_dir/LockView.qml.orig ]]; then
    mv "$lock_dir/LockView.qml.orig" "$lock_dir/LockView.qml"
    rm -f "$lock_dir"/{FoundryPixel.qml,FoundryGrid.qml,FoundryScene.qml,FoundrySprites.js} \
      "$lock_dir"/Scene{Crew,Abduction,Menagerie,Patrol}.qml
    say "Restored the stock unlock screen in $lock_dir"
  else
    warn "No LockView.qml.orig in $lock_dir — leaving the view as it is."
  fi
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
fi

warn "You are still on this theme if it was applied. Pick another with:"
warn "  omarchy theme set <name>"
