---
"osxsystem-skills": patch
---

The `implementer` and `implementer-kmp` subagents now run a `PreToolUse` guard that reuses the git guardrail to block `git push`, and also blocks `gh pr create`, `gh pr merge`, `bd dolt push` and `bd dolt pull`, so a dispatched implementer cannot publish. `scripts/link-agents.sh` installs the guard into `~/.claude/hooks`, and an implementer without it blocks every command.
