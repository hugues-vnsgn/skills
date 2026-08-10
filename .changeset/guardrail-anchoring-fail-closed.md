---
"osxsystem-skills": patch
---

Fix two bugs in `git-guardrails-claude-code`'s hook script, and add the missing
`## Common questions` section to five docs pages.

**The guardrail no longer blocks commands that merely mention a dangerous one.**
Patterns were matched anywhere in the command string, so `git pushd /tmp`,
`git commit -m "docs: explain git push safety"`, and `grep -r "git push" docs/`
were all blocked. Patterns are now anchored to the start of each command
segment, so a mention runs and an invocation still blocks.

**The guardrail now fails closed.** Previously, unparseable hook input made `jq`
error, left the command string empty, matched nothing, and exited `0` — allowing
the command. A missing `jq` did the same. Both now block (exit 2). If you relied
on the old behaviour to slip commands past the hook, they will now be refused.

Dangerous commands are still caught when they are not the leading command in a
chain (`cd foo && git push`), behind an env-var prefix, or via `git -C <path>`.

Also in this release: `docs/mobile/*` (all four) and
`docs/productivity/wait-what.md` gained the `## Common questions` section
required by `.agents/writing-docs.md`, and the stale claim in `CLAUDE.md` and
`.agents/writing-docs.md` that only `engineering/` and `productivity/` are
promoted now names `mobile/` too.
