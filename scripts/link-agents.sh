#!/usr/bin/env bash
set -euo pipefail

# Dev-only, like its sibling link-skills.sh: a maintainer's local install, not
# a supported installer.
#
# Links every subagent definition in agents/ into Claude Code's user agents
# directory (~/.claude/agents). Each entry is a symlink into this repo, so a
# `git pull` keeps installed agents current. Claude Code only: no other harness
# reads this file format.
#
# A sibling rather than a change to link-skills.sh, which is upstream-authored
# and does not accept modifications.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.claude/agents"

# Same guard as link-skills.sh: if $DEST resolves into this repo, the links
# would be written back into the working copy.
if [ -L "$DEST" ]; then
  resolved="$(readlink -f "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

shopt -s nullglob

# Prune links this script made for an agent since removed or renamed: a
# symlink into this repo's agents/ whose target is gone. Anything else in
# $DEST belongs to the user and is left alone.
for link in "$DEST"/*.md; do
  [ -L "$link" ] || continue
  case "$(readlink "$link")" in
    "$REPO"/agents/*)
      if [ ! -e "$link" ]; then
        rm "$link"
        echo "pruned $(basename "$link" .md) ($DEST)"
      fi
      ;;
  esac
done

for src in "$REPO"/agents/*.md; do
  name="$(basename "$src")"
  target="$DEST/$name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "error: $target exists and is not a symlink; move it aside and re-run." >&2
    exit 1
  fi

  ln -sfn "$src" "$target"
  echo "linked ${name%.md} -> $src ($DEST)"
done
