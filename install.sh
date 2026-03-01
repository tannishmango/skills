#!/usr/bin/env bash
# install.sh — symlink all skills in this repo into ~/.cursor/skills/
#
# Usage:
#   ./install.sh           # symlink all skills
#   ./install.sh --dry-run # preview what would be linked
#
# Safe to re-run: existing symlinks pointing to this repo are updated,
# real directories are left untouched (won't clobber marketplace installs).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_SKILLS="$HOME/.cursor/skills"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[dry-run] No changes will be made."
fi

mkdir -p "$CURSOR_SKILLS"

for skill_dir in "$REPO_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$CURSOR_SKILLS/$skill_name"

  # Skip non-skill entries (hidden dirs, files)
  [[ "$skill_name" == .* ]] && continue
  [[ ! -d "$skill_dir" ]] && continue

  if [ -L "$target" ]; then
    existing="$(readlink "$target")"
    if [[ "$existing" == "$skill_dir" || "$existing" == "${skill_dir%/}" ]]; then
      echo "  ok       $skill_name (already linked)"
      continue
    else
      # Symlink exists but points elsewhere — update it
      if $DRY_RUN; then
        echo "  update   $skill_name ($existing -> $skill_dir)"
      else
        rm "$target"
        ln -s "$skill_dir" "$target"
        echo "  updated  $skill_name"
      fi
    fi
  elif [ -d "$target" ]; then
    # Real directory — don't clobber (likely a marketplace install)
    echo "  skip     $skill_name (real directory exists, not overwriting)"
  else
    # Nothing there — create symlink
    if $DRY_RUN; then
      echo "  link     $skill_name -> $skill_dir"
    else
      ln -s "$skill_dir" "$target"
      echo "  linked   $skill_name"
    fi
  fi
done

echo ""
echo "Done. Skills directory: $CURSOR_SKILLS"
