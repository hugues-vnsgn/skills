# Deprecated

Skills I no longer use. Each stays here so `--skill=<name>` still installs it, but the installer's picker hides it and `scripts/link-skills.sh` skips it. Each entry names what replaced it.

- **[implement-spec](./implement-spec/SKILL.md)**: Implement a whole spec on one branch as a task graph of tickets, landing one PR. Replaced by `/implement-delegate`, which builds each ticket in its own worktree through an implementer subagent, reviews and merges it, and leaves every push to you. User-invoked.
