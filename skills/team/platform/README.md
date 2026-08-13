# Platform

Team skills for working on the toolchain itself — configuring a repo for the engineering flow, bringing capabilities across from other codebases, and unsticking a design. Fork-authored: upstream owns none of these bytes.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[setup-osxsystem-skills](./setup-osxsystem-skills/SKILL.md)** — Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo.
- **[port-from-repo](./port-from-repo/SKILL.md)** — Bring a capability across from another codebase — study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.

## Beta

Not promoted: no docs page, and excluded from the top-level `README.md` until it graduates. Try it and say what breaks — it can change or disappear without warning.

- **[when-stuck](./when-stuck/SKILL.md)** — Five techniques for design and architecture stuck-ness: inversion, the scale game, simplification cascades, meta-patterns, collision.
