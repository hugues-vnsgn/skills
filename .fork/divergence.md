# Divergence record

Every way this fork differs from [`mattpocock/skills`](https://github.com/mattpocock/skills), and how to resolve each one when it surfaces in a sync. Seeded from the fork table in [MAINTENANCE.md](../MAINTENANCE.md) and verified against `git diff upstream/main` on 2026-08-13 (upstream `84fdeff`).

Two live sections, split by how a sync treats them, and a third for the ones already retired:

- **Additions** are *sync-inert*: files upstream has never written, so a merge cannot conflict with them. They need no recipe; they need only to survive.
- **Modifications and deletions** are *sync-active*: upstream may rewrite the same bytes. Each carries a resolution recipe so the same conflict resolves the same way every time.
- **Retired divergences** are no longer differences at all. They are kept so nobody re-introduces one by hand.

The machine-readable half of this file is [`sanctioned-edits.txt`](./sanctioned-edits.txt), which lists exactly the upstream paths permitted to differ. Anything appearing in a merge that is not described here is a signal to stop and investigate.

## Additions (sync-inert)

`forkcheck` reads this table in both directions. `frozen-upstream` asks whether every fork path on disk is declared here; `declared-trees-exist` asks the reverse, so a row cannot outlive the tree it describes, which is exactly how `research/` and `docs/superpowers/` survived the commit that deleted them. Mark a path **`(planned)`** immediately after the backtick to declare a tree before it exists; the marker attaches to that one path even when a row declares several.

| Path | What | Sync note |
|---|---|---|
| `skills/house/mobile/` | The fork's KMP/CMP skills, in the `mobile` domain of the fork-owned `skills/house/` tree | Upstream writes nothing under `skills/house/`. `kmp-test-seams` carries the KMP guidance that used to be appended to upstream's `tdd` skill; see below. |
| `docs/house/mobile/` | Docs pages for the mobile domain, mirroring the skill tree (fork-local; never published to aihero.dev) | None |
| `skills/house/platform/` | `setup-osxsystem-skills`; `port-from-repo` (re-authored from ClaudeKit's `xia`); `when-stuck` (beta, re-authored from Microsoft Amplifier via ClaudeKit's `problem-solving`). Design recorded in the 2026-08-10 ClaudeKit adoption spec, dropped in `b0f14da` | Re-homed here on 2026-08-13; upstream's `setup-matt-pocock-skills` stays deleted; see below. |
| `docs/house/platform/` | Docs pages for the platform domain (fork-local). `when-stuck` is beta, so it has none | None |
| `skills/house/delivery/`, `docs/house/delivery/` (planned) | The `delivery` domain, shipping a piece of work end to end: `cook` (the implementation pipeline) and `project-organization` (the output conventions it writes with) | Both are `status: beta` in [`catalog.yaml`](./catalog.yaml), so neither has a docs page yet and `docs/house/delivery/` holds no files. The tree is declared here because upstream will never write it, whenever the first page lands. |
| `skills/house/discovery/`, `docs/house/discovery/` | The `discovery` domain, the phase before the spec: `to-prd` (conversation → Product Requirements Document), promoted, the step between `grill-with-docs` and `to-spec` in the main flow for initiative-scale work | Adapted from the ecosystem's `create-prd` (phuryn/pm-skills) into the fork's synthesis idiom. Its `ask-matt` routing rides on the already-sanctioned `skills/engineering/ask-matt/SKILL.md`. |
| `skills/house/quality/`, `docs/house/quality/` (planned) | The `quality` domain, proving a change works: `do-test` (verification and the evidence a verdict stands on) | As above: `do-test` is `status: beta`, so `docs/house/quality/` is declared but empty until it graduates. |
| `skills/house/writing/`, `docs/house/writing/` | The `writing` domain: prose a human reads, which is the other half of the pair whose agent-facing side upstream's `writing-for-agents` owns. `unslop` (cut the AI tells, restore a voice) is its first resident, promoted out of `in-development/` on 2026-08-24 | Its bundled `scripts/check-tells.py` is fork-authored and has no upstream counterpart, so a sync can never contest it. |
| `skills/house/in-development/` | Staging area for fork skills still being written, the one `skills/house/` child that is a maturity bucket rather than a capability domain. Its `README.md` carries the shipping checklist out of it | Never gains a `docs/house/` tree: a skill here is unregistered by definition, and it earns its docs page only after moving to a capability domain. |
| `docs/roles/` | One entry page per audience in [`catalog.yaml`](./catalog.yaml), a curated reading order for engineers, designers, analysts, QA and staff (fork-local) | Regenerate the lists by hand whenever a skill's `audience` changes; the catalog is the source of truth, the pages are the view. |
| `docs/agents/` | Per-repo configuration the engineering skills read: which issue tracker this repo uses (beads), the triage label vocabulary, and where the glossary and ADRs live. Written by `setup-osxsystem-skills`, and `code-review` reads `issue-tracker.md` directly | The one `docs/` subtree that is not a published page per skill, so `skillcheck`'s docs assertions do not apply to it. Note the path is fixed by the consuming skills, which is why this is not folded into the `.agents/` control plane where it would otherwise belong. |
| `scripts/harness/`, `scripts/check-confusable-skills.py`, `.github/workflows/skillcheck.yml` | The fork's skill-validation harness and its CI job | None |
| `.fork/`, `CATALOG.md`, `scripts/generate-catalog.py`, `scripts/generate-marketplace.py` | This control plane and the two artefacts generated from [`catalog.yaml`](./catalog.yaml): `CATALOG.md` (the human table) and `.claude-plugin/marketplace.json` (installer picker grouping; the manifest itself is a *modification*, see below), including [`sync-playbook.md`](./sync-playbook.md), the step-by-step sync procedure | The playbook's residual conflict surface is this file's sync-active sections, one row per section. Change one, change the other. |
| `.github/CODEOWNERS` | PR approval authority: an owner per `skills/house/<domain>/`, maintainers over upstream territory and the control plane | Upstream ships no `CODEOWNERS`. Its owners mirror the `owner:` fields in [`catalog.yaml`](./catalog.yaml), usernames while the repo is user-owned, team slugs after an org transfer (see the CODEOWNERS header). |
| `MAINTENANCE.md`, `CUSTOMIZING.md` | Fork maintenance and customization narrative | None |
| `.scratch/` | The local issue tracker (specs and their tickets); GitHub Issues is disabled on this repo | None |
| `.changeset/*.md`, `CHANGELOG.md` | The release artifacts: changesets are the inputs (the fork's own, plus every one a sync imports), `CHANGELOG.md` is the output `changeset version` writes from them | Both are skipped by `forkcheck`'s frozen-upstream assertion (`RELEASE_ARTIFACTS`), because upstream ships both and upstream-presence would otherwise override this declaration. **Neither is truly sync-inert.** Changesets: each of upstream's names *its* package, so an imported one makes `changeset version` abort with "not in the workspace" and fails the Release workflow. A changeset upstream *adds* never conflicts (new file, new name), so re-homing it is a post-merge fixup, not a conflict recipe; see the changeset step in [`sync-playbook.md`](./sync-playbook.md), and `forkcheck`'s `changeset-package` assertion catches a missed one. One shape does conflict: a changeset this fork already consumed with `changeset version` is deleted here while still live upstream, so a later upstream edit to it arrives as modify/delete. Keep the deletion; its content is already in `CHANGELOG.md`, and restoring it would re-release work the fork has shipped. First seen in the 2026-08-20 sync, where upstream's em-dash sweep touched three changesets that `f2f64f3` had consumed. `CHANGELOG.md`: still upstream's file byte-for-byte until the fork cuts its first release, then permanently diverged (fork H1, fork version line). It cannot be sanctioned instead of skipped, because before the release, a sanctioned entry is *stale*; after it, an absent one is *drift*. On conflict, keep the fork's: upstream's entries describe releases of a package this fork no longer is. `.changeset/config.json` is a *modification*; see below. |

## Modifications and deletions (sync-active)

Each row is a recurring conflict, and together they are the fork's entire expected conflict surface, and [`sync-playbook.md`](./sync-playbook.md) tabulates the same sections as the list a maintainer checks a conflict against mid-merge, so the two must be changed together. Enable `git config rerere.enabled true` once, and the prose rows below self-resolve after the first sync that records them.

### `.claude-plugin/`: `marketplace.json` regenerated, everything else deleted, and `scripts/sync-plugin-version.mjs`

**Why:** this fork ships via [skills.sh](https://skills.sh/hugues-vnsgn/skills) only; the Claude Code plugin *install route* was removed. See [ADR 0002](../.agents/adr/0002-ship-as-a-claude-code-plugin.md) for the upstream decision this fork reverses, and its 2026-08-17 update for why one file came back.

`.claude-plugin/marketplace.json` is **not** an install route here. The skills.sh installer groups its picker, the collapsible headings with a per-group "select all", only from that file, reading `plugins[].name` and `plugins[].skills[]` and nothing else. Without it every skill lands in one flat, ungrouped list. The fork's copy is generated from [`catalog.yaml`](./catalog.yaml) by [`scripts/generate-marketplace.py`](../scripts/generate-marketplace.py) and shares nothing with upstream's but the path. `plugin.json`, the file that actually makes the directory installable, stays deleted, and `forkcheck`'s `plugin-dir-marketplace-only` assertion fails if a sync brings it back.

**Recipe:** upstream edits land as a modify/delete conflict for the deleted paths, and a content conflict on `marketplace.json`. Never take upstream's; regenerate ours:

```bash
git rm -r --ignore-unmatch scripts/sync-plugin-version.mjs
git rm --ignore-unmatch .claude-plugin/plugin.json
python3 scripts/generate-marketplace.py
git add .claude-plugin/marketplace.json
```

Also drop any `sync-plugin-version` script upstream re-adds to `package.json`: this fork's manifest carries no `version`, so there is nothing to sync.

### `skills/engineering/setup-matt-pocock-skills/`, deleted

**Why:** the setup skill configures *this* repo's skills, and the fork's approved name (2026-08-06 rename spec, dropped in `b0f14da`) is `setup-osxsystem-skills`. That skill is now a fork addition under [`skills/house/platform/`](../skills/house/platform/setup-osxsystem-skills/SKILL.md), so this is no longer a rename spanning both territories; it is a plain deletion of upstream's copy, which stays deleted rather than restored: the linker links every non-deprecated skill, so restoring upstream's copy would install two setup skills under two names.

**Recipe:** treat exactly like `.claude-plugin/`, so upstream's paths stay deleted:

```bash
git rm -r --ignore-unmatch skills/engineering/setup-matt-pocock-skills docs/engineering/setup-matt-pocock-skills.md
```

Then port any upstream change to the deleted files into `skills/house/platform/setup-osxsystem-skills/` by hand. The content is otherwise unchanged from upstream's; only the name and the home differ.

### Prose files: `README.md`, `CLAUDE.md`, `CONTEXT.md`, `MAINTENANCE.md`-adjacent conventions

Affected: `README.md`, `CLAUDE.md`, `CONTEXT.md`, `.agents/install-block.md`, `.agents/writing-docs.md`, `.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md`, `skills/{engineering,in-progress,misc}/README.md`, `docs/engineering/*.md`, `docs/productivity/wait-what.md`.

**Why:** fork framing (osxsystem, not mattpocock), the house tree's sections, the fork's setup-skill name, and install commands pointing at `hugues-vnsgn/skills`. `skills/engineering/README.md` and `skills/in-progress/README.md` now diverge by *omission*, because the fork skills they used to list live under `skills/house/platform/`.

**Recipe:** keep both sides, because these are appended sections and entries, not rewrites. Then verify:

- install commands say `hugues-vnsgn/skills`, not `mattpocock/skills` (source of truth: [`.agents/install-block.md`](../.agents/install-block.md));
- the fork README framing and its Mobile and Platform sections survived;
- no fork skill has been re-added to an upstream bucket README.

### `package.json`, `package-lock.json`, `.changeset/config.json`, `.gitignore`

**Why:** fork package name/description/repository, the removed `sync-plugin-version` script, changelog pointing at `hugues-vnsgn/skills`, and the ignored `isolated_test_workspace/`.

**Recipe:** take upstream's dependency and tooling changes; keep the fork's identity fields (`name`, `description`, `repository`, changeset `repo`) and the fork's ignore entries.

### `LICENSE`: the fork's copyright line added under upstream's

**Why:** the repo is part upstream and part fork, so the notice should say both. Upstream's MIT text is kept verbatim and `Copyright (c) 2026 hugues-vnsgn` sits directly beneath `Copyright (c) 2026 Matt Pocock`. The permission grant and warranty disclaimer are upstream's, unchanged.

This is a one-line divergence on purpose. MIT requires that "the above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software", and this repo vendors upstream's `skills/{engineering,productivity,misc,in-progress}/` trees byte-for-byte, which is exactly what `forkcheck`'s frozen-upstream assertion guards. Dropping either notice while continuing to ship those files would not satisfy the licence they arrive under, so the file is extended rather than replaced.

**Recipe:** take upstream's text wholesale on conflict, then re-add the fork's copyright line beneath upstream's. Never resolve by deleting either notice. `LICENSE` was briefly reduced to a bare `MIT License` heading in `bb482b1`; `forkcheck` caught it as unsanctioned drift, which is the guard working as intended.

### `skills/misc/git-guardrails-claude-code/`, hardened

**Why:** fork-hardened `block-dangerous-git.sh` and its skill doc.

**Recipe:** keep both, and reconcile by re-running `bash scripts/harness/test_guardrail.sh`; the tests are the arbiter, not the diff.

### `skills/engineering/{ask-matt,code-review,to-spec,to-tickets,triage,wayfinder}/SKILL.md`

**Why:** router entries and cross-references for fork skills (the `mobile` and `platform` domains). These cite fork skills by name, not by path, so the move left them unchanged.

**Recipe:** keep both; then re-read [`ask-matt`](../skills/engineering/ask-matt/SKILL.md) and confirm every fork skill still appears and every upstream skill it routes to still exists under that name.

### `skills/engineering/ask-matt/references/`: the router's long-form detail

Affected: `skills/engineering/ask-matt/PHASE-BOUNDARIES.md` (deleted), `references/phase-boundaries.md` and `references/platform-knowledge.md` (added).

**Why:** `ask-matt` is a router, so its `SKILL.md` earns its keep by being scannable. The fork's five KMP/CMP skills added a `## Platform knowledge` section whose per-skill detail is reference material, not routing, so it moved into `references/platform-knowledge.md` and the section kept only its framing paragraph, the five names, and a pointer. Upstream's `PHASE-BOUNDARIES.md` moved alongside it, same kind of content and same folder, renamed to `phase-boundaries.md` to match the lowercase `references/` convention the fork's `skills/house/` skills already use. Content is byte-identical to upstream's; only the path and the case of the name changed.

**Recipe:** take upstream's edits to `PHASE-BOUNDARIES.md` and apply them to `references/phase-boundaries.md`, then delete upstream's copy again, because a sync that restores it leaves two copies of the same tree and `SKILL.md` links to only one. If upstream ever grows its own `references/` folder here, drop the case (b) entries and keep the paths.

## Retired divergences

Recorded so a future maintainer doesn't re-create one by reflex.

### `skills/engineering/tdd/SKILL.md`: KMP section appended (retired 2026-08-13)

Upstream's `tdd` skill carried a fork-appended `## Kotlin Multiplatform projects` section: seams in `commonMain`, tests in `commonTest`, and the cheapest Gradle task that proves a slice. That guidance now lives in [`skills/house/mobile/kmp-test-seams/`](../skills/house/mobile/kmp-test-seams/SKILL.md), which cross-references `tdd` by name, and upstream's file is byte-identical again, so the path is gone from [`sanctioned-edits.txt`](./sanctioned-edits.txt) and a sync can never conflict there.

**If upstream's `tdd` skill grows KMP guidance of its own,** reconcile it into `kmp-test-seams` rather than appending here: an in-file append is the divergence this retirement removed.
