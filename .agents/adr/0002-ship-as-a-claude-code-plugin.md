# Ship the skill set as a native Claude Code plugin; defer a native Codex plugin

These skills have always been installable via [skills.sh](https://skills.sh/mattpocock/skills) (`npx skills add mattpocock/skills`), which copies editable skill files into a user's project across Claude Code, Codex, and other Agent-Skills-standard harnesses. A recurring request is a **plug-and-play** distribution: subscribe to the set as a read-only, always-current bundle you don't edit, rather than a fork you own. That is exactly what native plugin systems provide.

We ship a native **Claude Code plugin** and, for now, **defer** a native **Codex plugin**. The split is forced by how each ecosystem's plugin manifest selects skills, against this repo's bucketed layout.

## The constraint: bucketed skills vs. single-path selection

Skills live in bucket folders under `skills/` — `engineering/` and `productivity/` are **promoted** (shipped); `misc/`, `personal/`, `in-progress/`, and `deprecated/` are **not**. A plugin must expose only the promoted set, which spans two of those bucket folders.

- **Claude Code** — `.claude-plugin/plugin.json` accepts `skills` as an **array of explicit skill-directory paths**. We list the promoted skills one by one, exclude everything else with zero ambiguity, and add `.claude-plugin/marketplace.json` so the repo is its own single-plugin marketplace. Verified end to end: `claude plugin validate . --strict` passes, and `marketplace add` → `install` resolves all promoted skills.

- **Codex** — `.codex-plugin/plugin.json` accepts `skills` only as a **single path string** (arrays are rejected with `missing or invalid plugin.json`), and Codex discovers `SKILL.md` files recursively under it. There is no way to name two bucket folders, or to curate a subset, from one path. Two escape hatches were tested and rejected:
  - Pointing at `./skills/` would also ship `deprecated/`, `in-progress/`, `personal/`, and `misc/` — retired, draft, and personal skills we deliberately don't promote.
  - A curated flat directory of **symlinks** into the buckets does not survive install: Codex copies the plugin tree into its cache and **drops symlinks**, so the skills arrive empty.

The only robust ways to give Codex a single promoted-only path are (a) **restructure** so `skills/` contains only promoted skills (moving the non-promoted buckets out — a large blast radius across `CLAUDE.md`, `scripts/link-skills.sh`, the bucket READMEs, and the local dev workflow that relies on `in-progress/` and `personal/`), or (b) **commit duplicate copies** of promoted skills into a flat directory (a sync burden and a second source of truth). Both are structural decisions, not something to bundle into shipping the Claude plugin. This is very likely the original, half-remembered reason a plugin wasn't shipped earlier: the manifest formats didn't cleanly express a curated subset of a bucketed repo.

## Decision

- Ship the **Claude Code plugin** now (`.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`), curated to the promoted set, as the headline v1.2 deliverable.
- Keep **skills.sh** as the universal installer — it already serves Codex and other harnesses today, so no Codex user is left without an install path.
- **Defer** the native Codex plugin until we decide between restructuring `skills/` to promoted-only vs. committing a generated flat copy. Revisit when Codex either supports a `skills` array / include-list or preserves symlinks on install.

## Invariants this creates

- Every promoted skill has an entry in `.claude-plugin/plugin.json`'s `skills` array (this already stood as a `CLAUDE.md` rule; it now also gates the plugin's contents).
- `.claude-plugin/plugin.json`'s `version` tracks `package.json`'s version — bump both together on release. Claude uses the plugin `version` to decide when installed users see an update.

## Update, 2026-08-05

`mattpocock-skills` was accepted into **Claude Code's official marketplace** — configured name `claude-plugins-official`, source repo `anthropics/claude-plugins-official` — which every Claude Code install has by default. `claude plugins install mattpocock-skills` is now the documented route, and the `marketplace add` → `install` path above is superseded. The install wording lives in [.agents/install-block.md](../install-block.md).

The official listing points at this repo's git URL and reads `.claude-plugin/plugin.json` directly, so it does not depend on `.claude-plugin/marketplace.json`. That file is retained only as a fallback for installing the repo directly (an unreleased commit, or a fork).

Verified 2026-08-05, on Claude Code 2.1.222, against the live listing:

- `claude plugins install mattpocock-skills` resolves with no marketplace added first, and reports `mattpocock-skills@claude-plugins-official`.
- `claude plugin details mattpocock-skills` then reports version 1.2.0 and loads the promoted skills.
- The listing's `source` is `{"source": "url", "url": "https://github.com/mattpocock/skills.git", "sha": …}` — the **sha is pinned**, so a release reaches installed users when that pin moves, not the moment we tag. At the time of writing the pin sits two commits behind `main`, which is why it lists 22 skills rather than the 24 in `plugin.json`.
- The in-session `/plugin install mattpocock-skills` was **not** exercised — `/plugin` is unavailable in headless (`claude -p`) sessions. It runs the same resolver as the CLI, and the documented example form is `/plugin install <name>@claude-plugins-official`.

## Fork update, 2026-08-17 — `.claude-plugin/marketplace.json` comes back, as picker metadata

This fork reversed the decision above: `.claude-plugin/` was deleted and [skills.sh](https://skills.sh/osxsystem/skills) is the only install route. `forkcheck.py` enforced that with a `no-plugin-dir` assertion.

One file is now restored, and the reason has nothing to do with plugins. The skills.sh installer ([vercel-labs/skills](https://github.com/vercel-labs/skills)) renders its interactive picker as a flat list unless skills carry a group, and it derives groups from exactly one source: `getPluginGroupings()`, which reads `.claude-plugin/marketplace.json` (or `plugin.json`). With a manifest present it renders collapsible headings, each with a "select all" row — the difference between ticking 35 skills one at a time and ticking six domains. `plugin.json` can only ever express a single group, so grouping requires `marketplace.json` specifically.

**Decision:** generate `.claude-plugin/marketplace.json` from [`.fork/catalog.yaml`](../../.fork/catalog.yaml) via [`scripts/generate-marketplace.py`](../../scripts/generate-marketplace.py), carrying only `plugins[].name` and `plugins[].skills[]` — the fields the picker reads — plus a `metadata.note` recording what the file is for. No `version`, `source`, or `owner` block, so the ADR's version-sync invariant does not return and the entries do not present as installable plugins.

`no-plugin-dir` becomes **`plugin-dir-marketplace-only`**: `.claude-plugin/` may hold `marketplace.json` and nothing else, so a sync that drags `plugin.json` back still fails CI. The install story in [`install-block.md`](../install-block.md) is unchanged — one route, skills.sh.

**Known consequence, accepted:** a valid `marketplace.json` is technically resolvable by `claude plugin marketplace add`. That route is undocumented and unsupported here; we chose not to sabotage the file to prevent it, because a manifest engineered to break for one consumer is a trap for the next maintainer.

**Second consequence, accepted:** the installer sets `searchable: !hasGroups`, so turning grouping on turns type-to-filter off, and groups open expanded. Both are upstream behaviours; a PR to let search and grouping coexist (and to default groups collapsed) is tracked separately and does not gate this change.
