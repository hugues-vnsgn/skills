---
"osxsystem-skills": patch
---

The `implementer` and `implementer-kmp` subagents now run a `PreToolUse` guard that reuses the git guardrail to block `git push`, and also blocks `gh pr create`, `gh pr merge`, `gh api` writes, `bd dolt push`, `bd dolt pull` and any `bd` call without `--sandbox`, through wrappers such as `bash -c`, subshells and global flags, so a dispatched implementer cannot publish. `scripts/link-agents.sh` installs the guard into `~/.claude/hooks`, and an implementer without it blocks every command.
