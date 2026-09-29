#!/usr/bin/env bash
set -euo pipefail

# Dev-only, like its sibling link-skills.sh: a maintainer's local install, not
# a supported installer.
#
# Links every subagent definition in agents/ into Claude Code's user agents
# directory (~/.claude/agents), and the hook scripts they call from
# agents/hooks/ into ~/.claude/hooks. Each entry is a symlink into this repo, so a
# `git pull` keeps installed agents current. Claude Code only: no other harness
# reads this file format.
#
# A sibling rather than a change to link-skills.sh, which is upstream-authored
# and does not accept modifications.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

shopt -s nullglob

# link_tree <src_dir> <glob> <dest_dir>: symlink every <src_dir>/<glob> into
# <dest_dir>, first pruning links this script made whose target has since been
# removed or renamed. Anything in <dest_dir> not linked into <src_dir> belongs
# to the user and is left alone; a real file where a link should go stops the
# run rather than being overwritten.
link_tree() {
  local src_dir="$1" glob="$2" dest="$3" link src target

  # Same guard as link-skills.sh: if $dest resolves into this repo, the links
  # would be written back into the working copy.
  if [ -L "$dest" ]; then
    local resolved
    resolved="$(readlink -f "$dest")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $dest is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$dest\") and re-run; the script will recreate it as a real dir." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$dest"

  for link in "$dest"/$glob; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$src_dir"/*)
        if [ ! -e "$link" ]; then
          rm "$link"
          echo "pruned $(basename "$link") ($dest)"
        fi
        ;;
    esac
  done

  for src in "$src_dir"/$glob; do
    target="$dest/$(basename "$src")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "error: $target exists and is not a symlink; move it aside and re-run." >&2
      exit 1
    fi
    ln -sfn "$src" "$target"
    echo "linked $(basename "$src") -> $src ($dest)"
  done
}

link_tree "$REPO/agents" "*.md" "$HOME/.claude/agents"
# The hook scripts the agents' frontmatter calls. Each agent expects its hook
# at ~/.claude/hooks/<name> and blocks every Bash command without it.
link_tree "$REPO/agents/hooks" "*.sh" "$HOME/.claude/hooks"
