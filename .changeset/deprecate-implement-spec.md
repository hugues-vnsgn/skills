---
"osxsystem-skills": patch
---

`implement-spec` is deprecated in favour of `/implement-delegate`, which builds each ticket in its own worktree through an implementer subagent, reviews and merges it, and leaves every push to you instead of opening a draft PR. `implement-spec` moves to `skills/deprecated/`, drops out of the installer's picker, and still installs with `--skill=implement-spec`.
