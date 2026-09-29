#!/bin/bash

# PreToolUse hook for the implementer subagents: nothing a dispatched
# implementer runs may publish. Exit 2 = blocked, exit 0 = allowed.
#
# Two layers. git is left to the fork's hardened guardrail,
# skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh, which
# already blocks `git push` in every form it knows (plain, `git -C`,
# env-prefixed, after a separator). This script then blocks what that one does
# not cover: opening or merging a pull request, and syncing the beads remote.
#
# Installed as a symlink by scripts/link-agents.sh; the guardrail is found by
# resolving that link back into the skills repo, so a `git pull` there keeps
# both current. Fails CLOSED, like the guardrail: a missing guardrail, a
# missing jq, or an unreadable payload blocks the command.

block() {
  echo "BLOCKED: $1 An implementer never publishes; the orchestrator and the user decide what leaves this machine." >&2
  exit 2
}

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
REPO="$(cd "$(dirname "$SELF")/../.." && pwd)"
GUARDRAIL="$REPO/skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh"

[ -f "$GUARDRAIL" ] || block "implementer guard cannot find the git guardrail at $GUARDRAIL."
command -v jq >/dev/null 2>&1 || block "implementer guard cannot run (jq not found on PATH)."

INPUT=$(cat)

# Any non-zero exit from the guardrail is a block: 2 is its verdict, anything
# else means it could not decide, and an undecided guard must not allow.
if ! printf '%s' "$INPUT" | bash "$GUARDRAIL"; then
  exit 2
fi

if ! COMMAND=$(printf '%s' "$INPUT" | jq -re '.tool_input.command' 2>/dev/null); then
  block "implementer guard could not read .tool_input.command from the hook payload."
fi

# The guardrail matches only the plain shapes of a command, which suits a
# human's hook. This layer normalizes harder, because an implementer that
# reaches for a workaround should still hit the wall: every control operator,
# grouping and substitution starts a new segment, and each segment is peeled
# of wrappers (`command`, `env`, `nohup`, `bash -c "..."`, `/usr/bin/git`)
# until the real tool is first. The cost is over-blocking a quoted mention
# that contains a separator (`-m "a; gh pr create"`), which is acceptable for
# an agent that is not meant to write such commands anyway.
SEGMENTS=$(printf '%s\n' "$COMMAND" | sed -E 's/\$\(|`|\|&|&&|\|\||[;|&(){}]/\n/g')

# normalize <segment>: strip, repeatedly, leading whitespace and quotes, env
# assignments, wrapper commands with their flags, `sh -c`, and a directory
# prefix on the tool, until nothing changes.
normalize() {
  local s="$1" prev=""
  while [ "$s" != "$prev" ]; do
    prev="$s"
    s=$(printf '%s' "$s" | sed -E \
      -e "s/^[[:space:]\"']+//" \
      -e "s/^[A-Za-z_][A-Za-z0-9_]*=(\"[^\"]*\"|'[^']*'|[^[:space:]]*)([[:space:]]+|$)//" \
      -e 's/^(command|builtin|exec|eval|env|time|nohup|nice|sudo|xargs|stdbuf)(([[:space:]]+-[^[:space:]]*)*)([[:space:]]+|$)//' \
      -e 's/^timeout(([[:space:]]+-[^[:space:]]*)*)[[:space:]]+[^[:space:]]+([[:space:]]+|$)//' \
      -e 's/^(ba|z|da|k)?sh(([[:space:]]+-[^[:space:]]*)*)[[:space:]]+-[[:alpha:]]*c([[:space:]]+|$)//' \
      -e 's#^[^[:space:]]*/(git|gh|bd)([[:space:]]|$)#\1\2#')
  done
  printf '%s' "$s"
}

# Global flags may sit between a tool and its subcommand (`git -c k=v push`,
# `bd --actor "x" dolt push`), so FLAGS allows any run of `-flag` or
# `--flag value` tokens there, quoted values included. A bare word is never a
# flag, so a mention (`bd create "never run bd dolt push"`) does not match.
VALUE="(\"[^\"]*\"|'[^']*'|[^-[:space:]\"'][^[:space:]]*)"
FLAGS="([[:space:]]+-[^[:space:]]*([[:space:]]+${VALUE})?)*"
END="([[:space:]\"']|$)"
PUBLISHING_PATTERNS=(
  "git${FLAGS}[[:space:]]+push"
  "gh${FLAGS}[[:space:]]+pr${FLAGS}[[:space:]]+(create|merge)"
  "bd${FLAGS}[[:space:]]+dolt${FLAGS}[[:space:]]+(push|pull)"
)
# `gh api` reads are fine; any write (a non-GET method, or fields, which make
# gh send a POST) can open or merge a pull request by another route.
GH_API="^gh${FLAGS}[[:space:]]+api${END}"
GH_API_WRITE="(^|[[:space:]])((-X|--method)(=|[[:space:]]+)[\"']?(POST|PUT|PATCH|DELETE)|(-f|-F|--field|--raw-field|--input)([[:space:]=]|$))"
# bd pushes on its own when `dolt.auto-push` is on, so an ordinary write would
# sync the remote without any command above. `--sandbox` turns that off, and an
# implementer must pass it on every bd call.
BD="^bd${END}"
BD_SANDBOX="(^|[[:space:]])--sandbox([[:space:]]|=true|$)"

while IFS= read -r segment; do
  segment=$(normalize "$segment")
  [ -z "$segment" ] && continue

  for pattern in "${PUBLISHING_PATTERNS[@]}"; do
    if printf '%s' "$segment" | grep -qE "^${pattern}${END}"; then
      block "'$COMMAND' runs a publishing command ('${segment%% *} ...')."
    fi
  done
  if printf '%s' "$segment" | grep -qE "$GH_API" && printf '%s' "$segment" | grep -qE "$GH_API_WRITE"; then
    block "'$COMMAND' writes through the GitHub API."
  fi
  if printf '%s' "$segment" | grep -qE "$BD" && ! printf '%s' "$segment" | grep -qE "$BD_SANDBOX"; then
    echo "BLOCKED: '$COMMAND' runs bd without --sandbox, which would let Dolt auto-push sync the tracker remote. Re-run it with --sandbox (for example 'bd --sandbox update <id> --claim')." >&2
    exit 2
  fi
done <<< "$SEGMENTS"

exit 0
