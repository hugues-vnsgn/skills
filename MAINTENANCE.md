# Maintaining this fork

This repo (`hugues-vnsgn/skills`) is a personal fork of [`mattpocock/skills`](https://github.com/mattpocock/skills), customized for mobile development with **Kotlin Multiplatform + Compose Multiplatform** (Android + iOS/Swift).

## What the fork adds

| Path | What |
|---|---|
| `skills/house/mobile/` | House KMP/CMP skills (see [skills/house/mobile/README.md](./skills/house/mobile/README.md)) |
| `docs/house/mobile/` | Docs pages for the mobile domain (fork-local; not published to aihero.dev) |
| `research/` | The source research (prompts + reports from official kotlinlang.org docs, 2026-08) each mobile skill's `reference.md` was distilled from |
| `skills/house/platform/` | House skills for the toolchain itself (see [skills/house/platform/README.md](./skills/house/platform/README.md)): the fork's `setup-osxsystem-skills`, plus `port-from-repo` and `when-stuck` re-authored from external patterns (ClaudeKit's `xia`; Microsoft Amplifier via ClaudeKit's `problem-solving`) — see [the adoption spec](./docs/superpowers/specs/2026-08-10-claudekit-adoption-design.md). |
| `docs/house/platform/` | Docs pages for the platform domain (fork-local; not published to aihero.dev) |
| `.fork/` | The fork control plane: the sidecar [catalog](./.fork/catalog.yaml), the [last-synced upstream SHA](./.fork/upstream.lock), the [divergence record](./.fork/divergence.md), the [sanctioned-edits list](./.fork/sanctioned-edits.txt) CI reads, and the [sync playbook](./.fork/sync-playbook.md) |
| `.github/CODEOWNERS` | PR approval authority — a team per `skills/house/<domain>/`, maintainers over upstream territory and the control plane |
| `MAINTENANCE.md` | This file |
| Upstream files touched | `README.md` (reframed as fork README + house sections), `CLAUDE.md` (the house tree, plugin route removed), `skills/engineering/tdd/SKILL.md` (KMP section at the end); upstream's `setup-matt-pocock-skills/` deleted, and `.claude-plugin/` reduced to a generated `marketplace.json` — grouping metadata for the skills.sh picker, never an install route, with `plugin.json` still deleted. On conflict, regenerate ours (`python3 scripts/generate-marketplace.py`); never take upstream's. The full record, with a resolution recipe per divergence, is [.fork/divergence.md](./.fork/divergence.md). |

## Syncing with upstream

**The step-by-step procedure lives in [`.fork/sync-playbook.md`](./.fork/sync-playbook.md).** Follow it rather than this section — what's here is the shape of the thing, so you know what you're doing before you type it.

A sync is a merge plus assertions, not an act of curation. Upstream owns its buckets byte-for-byte; the fork owns `skills/house/` and the control plane, which upstream has never written. Because the two territories don't overlap, the only files that can conflict are the handful the fork deliberately diverged on — every one of them enumerated, with a resolution recipe, in [`.fork/divergence.md`](./.fork/divergence.md) and repeated as the playbook's residual conflict surface. A conflict outside that set means the boundary moved, and that's a stop-and-investigate rather than a merge decision.

Three habits carry most of the value, and the playbook is mostly scaffolding around them:

- **Merge, never rebase** — rebasing replays every fork commit against every upstream change and rewrites published history.
- **Sync-only branches** — a reviewer should be able to read every non-upstream hunk as a conflict resolution. Improvements the sync inspires go in a follow-up PR.
- **`git config rerere.enabled true`, once per clone** — the recurring prose conflicts (fork framing in `README.md`, `CLAUDE.md`, the bucket READMEs) are always "keep both", and rerere replays that resolution for free after the first time.

CI's `forkcheck` guard holds the boundary between syncs; at sync time run it against the merged ref (`--upstream-ref upstream/main`). Advance [`.fork/upstream.lock`](./.fork/upstream.lock) as part of the sync — it's what makes the next one's "what changed since?" a single `git log`.

## Adding or changing a skill

The full how-to — skill anatomy, the registration layers, the write→verify loop, and the customization roadmap — lives in [CUSTOMIZING.md](./CUSTOMIZING.md). Mobile-domain specifics:

Follow upstream's conventions (see `CLAUDE.md`), plus:

1. Skill lives at `skills/house/mobile/<name>/SKILL.md`; heavy material goes in `reference.md` files next to it, distilled from `research/` or fresh doc research — always against **official kotlinlang.org docs**, dated.
2. Verify with a retrieval test: dispatch a subagent that may read *only* the skill directory and must answer realistic task questions; gaps in its answers are the findings to fix before shipping.
3. Register it in: `skills/house/mobile/README.md`, top-level `README.md` (Mobile section), and add `docs/house/mobile/<name>.md` (What it does / When to reach for it / one substance section / It's working if).
4. Re-run `scripts/link-skills.sh` so local harnesses pick it up.

## Keeping content current

The mobile skills encode fast-moving facts (Kotlin/CMP versions, Swift Export status, Central Portal workflow). Refresh cadence: **each Kotlin language release (~every 6 months)** — re-run doc research against the reference URLs listed at the bottom of each `reference.md`, update the skills, and note the research date in `skills/house/mobile/README.md`.
