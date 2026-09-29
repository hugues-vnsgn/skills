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

# Global flags may sit between the tool and its subcommand
# (`bd --actor implementer-x dolt push`), so each pattern allows any run of
# `-flag` or `--flag value` tokens there. A quoted argument is never a flag, so
# a mere mention (`bd create "never run bd dolt push"`) does not match.
FLAGS="([[:space:]]+-[^[:space:]]*([[:space:]]+[^-[:space:]\"'][^[:space:]]*)?)*"
PUBLISHING_PATTERNS=(
  "gh${FLAGS}[[:space:]]+pr[[:space:]]+(create|merge)"
  "bd${FLAGS}[[:space:]]+dolt[[:space:]]+(push|pull)"
)

# Same segmenting as the guardrail: split on shell separators, then strip
# leading env assignments, so `cd x && gh pr create` and `FOO=1 bd dolt push`
# are both caught.
SEGMENTS=$(printf '%s' "$COMMAND" | sed -E 's/(\&\&|\|\||;|\|)/\n/g')

while IFS= read -r segment; do
  segment="${segment#"${segment%%[![:space:]]*}"}"
  segment=$(printf '%s' "$segment" | sed -E 's/^([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)+//')
  [ -z "$segment" ] && continue

  for pattern in "${PUBLISHING_PATTERNS[@]}"; do
    if printf '%s' "$segment" | grep -qE "^${pattern}([[:space:]]|$)"; then
      block "'$COMMAND' matches publishing pattern '$pattern'."
    fi
  done
done <<< "$SEGMENTS"

exit 0
