# Platform

House skills for the workbench rather than the code: the workspace a change is built in, the repo configured for the engineering flow, capabilities brought across from other codebases, and unsticking a design. Fork-authored, so upstream owns none of these bytes.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[setup-osxsystem-skills](./setup-osxsystem-skills/SKILL.md)**: Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo.
- **[port-from-repo](./port-from-repo/SKILL.md)**: Bring a capability across from another codebase. Study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[use-git-worktree](./use-git-worktree/SKILL.md)**: Start a feature or a fix in its own worktree under `.worktrees/`, on a `feat/` or `fix/` branch, so the main checkout keeps its branch and its uncommitted state.

## Beta

Not promoted: no docs page, and excluded from the top-level `README.md` until they graduate. Try them and say what breaks, because they can change or disappear without warning.

- **[sync-upstream](./sync-upstream/SKILL.md)**: Drive a merge of mattpocock/skills into this fork. Not shipped in the installer: it only works in this repo.
- **[when-stuck](./when-stuck/SKILL.md)**: Five techniques for design and architecture stuck-ness: inversion, the scale game, simplification cascades, meta-patterns, collision.
- **[herdr](./herdr/SKILL.md)**: Drive Herdr, a terminal multiplexer for coding agents: inspect and control panes, tabs, workspaces and commands. Requires `HERDR_ENV=1`.
