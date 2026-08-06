# Maintaining this fork

This repo (`osxsystem/skills`) is a team fork of [`mattpocock/skills`](https://github.com/mattpocock/skills), customized for mobile development with **Kotlin Multiplatform + Compose Multiplatform** (Android + iOS/Swift).

## What the fork adds

| Path | What |
|---|---|
| `skills/mobile/` | Team KMP/CMP skills (see [skills/mobile/README.md](./skills/mobile/README.md)) |
| `docs/mobile/` | Docs pages for the mobile bucket (fork-local; not published to aihero.dev) |
| `research/` | The source research (prompts + reports from official kotlinlang.org docs, 2026-08) each mobile skill's `reference.md` was distilled from |
| `MAINTENANCE.md` | This file |
| Upstream files touched | `README.md` (Mobile section), `CLAUDE.md` (mobile bucket), `.claude-plugin/plugin.json` (mobile skills), `skills/engineering/tdd/SKILL.md` (KMP section at the end) |

## Syncing with upstream

```bash
git remote add upstream https://github.com/mattpocock/skills   # once
git fetch upstream
git merge upstream/main        # prefer merge over rebase — keeps fork history honest
```

Conflicts will cluster in the four upstream files we touched (table above); our changes are appended sections/entries, so resolution is usually "keep both". After every sync:

1. `claude plugin validate . --strict` — both manifests still valid.
2. Confirm the Mobile section survived in `README.md` and `plugin.json`.
3. Skim upstream's `CHANGELOG.md` for renamed/moved skills our mobile skills cross-reference (`tdd`, `code-review`).

## Adding or changing a mobile skill

Follow upstream's conventions (see `CLAUDE.md`), plus:

1. Skill lives at `skills/mobile/<name>/SKILL.md`; heavy material goes in `reference.md` files next to it, distilled from `research/` or fresh doc research — always against **official kotlinlang.org docs**, dated.
2. Verify with a retrieval test: dispatch a subagent that may read *only* the skill directory and must answer realistic task questions; gaps in its answers are the findings to fix before shipping.
3. Register it in: `skills/mobile/README.md`, top-level `README.md` (Mobile section), `.claude-plugin/plugin.json`, and add `docs/mobile/<name>.md` (What it does / When to reach for it / one substance section / It's working if).
4. Re-run `scripts/link-skills.sh` so local harnesses pick it up.

## Keeping content current

The mobile skills encode fast-moving facts (Kotlin/CMP versions, Swift Export status, Central Portal workflow). Refresh cadence: **each Kotlin language release (~every 6 months)** — re-run doc research against the reference URLs listed at the bottom of each `reference.md`, update the skills, and note the research date in `skills/mobile/README.md`.
