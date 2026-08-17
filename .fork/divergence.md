# Divergence record

Every way this fork differs from [`mattpocock/skills`](https://github.com/mattpocock/skills), and how to resolve each one when it surfaces in a sync. Seeded from the fork table in [MAINTENANCE.md](../MAINTENANCE.md) and verified against `git diff upstream/main` on 2026-08-13 (upstream `84fdeff`).

Two live sections, split by how a sync treats them, and a third for the ones already retired:

- **Additions** are *sync-inert* — files upstream has never written, so a merge cannot conflict with them. They need no recipe; they need only to survive.
- **Modifications and deletions** are *sync-active* — upstream may rewrite the same bytes. Each carries a resolution recipe so the same conflict resolves the same way every time.
- **Retired divergences** are no longer differences at all. They are kept so nobody re-introduces one by hand.

The machine-readable half of this file is [`sanctioned-edits.txt`](./sanctioned-edits.txt), which lists exactly the upstream paths permitted to differ. Anything appearing in a merge that is not described here is a signal to stop and investigate.

## Additions (sync-inert)

| Path | What | Sync note |
|---|---|---|
| `skills/team/mobile/` | The team's KMP/CMP skills, in the `mobile` domain of the fork-owned `skills/team/` tree | Upstream writes nothing under `skills/team/`. `kmp-test-seams` carries the KMP guidance that used to be appended to upstream's `tdd` skill — see below. |
| `docs/team/mobile/` | Docs pages for the mobile domain, mirroring the skill tree (fork-local; never published to aihero.dev) | — |
| `skills/team/platform/` | `setup-osxsystem-skills`; `port-from-repo` (re-authored from ClaudeKit's `xia`); `when-stuck` (beta — re-authored from Microsoft Amplifier via ClaudeKit's `problem-solving`). See [the adoption spec](../docs/superpowers/specs/2026-08-10-claudekit-adoption-design.md) | Re-homed here on 2026-08-13; upstream's `setup-matt-pocock-skills` stays deleted — see below. |
| `docs/team/platform/` | Docs pages for the platform domain (fork-local). `when-stuck` is beta, so it has none | — |
| `skills/team/delivery/`, `docs/team/delivery/` | The `delivery` domain — shipping a piece of work end to end: `cook` (the implementation pipeline) and `project-organization` (the output conventions it writes with) | Both are `status: beta` in [`catalog.yaml`](./catalog.yaml), so neither has a docs page yet and `docs/team/delivery/` holds no files — the tree is declared here because upstream will never write it, whenever the first page lands. |
| `skills/team/quality/`, `docs/team/quality/` | The `quality` domain — proving a change works: `do-test` (verification and the evidence a verdict stands on) | As above: `do-test` is `status: beta`, so `docs/team/quality/` is declared but empty until it graduates. |
| `skills/team/in-development/` | Staging area for fork skills still being written — the one `skills/team/` child that is a maturity bucket rather than a capability domain. Its `README.md` carries the shipping checklist out of it | Never gains a `docs/team/` tree: a skill here is unregistered by definition, and it earns its docs page only after moving to a capability domain. |
| `docs/roles/` | One entry page per audience in [`catalog.yaml`](./catalog.yaml) — a curated reading order for engineers, designers, analysts, QA and staff (fork-local) | Regenerate the lists by hand whenever a skill's `audience` changes; the catalog is the source of truth, the pages are the view. |
| `research/` | Source research (prompts + reports from official kotlinlang.org docs, 2026-08) behind each mobile `reference.md` | — |
| `scripts/harness/`, `scripts/check-confusable-skills.py`, `.github/workflows/skillcheck.yml` | The fork's skill-validation harness and its CI job | — |
| `.fork/`, `CATALOG.md`, `scripts/generate-catalog.py` | This control plane and the generated catalog — including [`sync-playbook.md`](./sync-playbook.md), the step-by-step sync procedure | The playbook's residual conflict surface is this file's sync-active sections, one row per section. Change one, change the other. |
| `.github/CODEOWNERS` | PR approval authority: an owner per `skills/team/<domain>/`, maintainers over upstream territory and the control plane | Upstream ships no `CODEOWNERS`. Its owners mirror the `owner:` fields in [`catalog.yaml`](./catalog.yaml) — usernames while the repo is user-owned, team slugs after an org transfer (see the CODEOWNERS header). |
| `MAINTENANCE.md`, `CUSTOMIZING.md` | Fork maintenance and customization narrative | — |
| `docs/superpowers/` | Fork specs and plans (dated historical documents) | — |
| `.scratch/` | The local issue tracker (specs and their tickets); GitHub Issues is disabled on this repo | — |
| `.changeset/*.md` | Changesets — the fork's own, plus every one a sync imports from upstream | Ephemeral; consumed by a release. **Not sync-inert, despite sitting in this table:** upstream ships changesets too, and each names *its* package, so an imported one makes `changeset version` abort with "not in the workspace" and fails the Release workflow. They never *conflict* (new files, new names), so this is a post-merge fixup, not a conflict recipe — see the changeset step in [`sync-playbook.md`](./sync-playbook.md). `forkcheck`'s `changeset-package` assertion catches a missed one. `.changeset/config.json` is a *modification* — see below. |

## Modifications and deletions (sync-active)

Each row is a recurring conflict, and together they are the fork's entire expected conflict surface — [`sync-playbook.md`](./sync-playbook.md) tabulates the same sections as the list a maintainer checks a conflict against mid-merge, so the two must be changed together. Enable `git config rerere.enabled true` once, and the prose rows below self-resolve after the first sync that records them.

### `.claude-plugin/` — deleted, and `scripts/sync-plugin-version.mjs`

**Why:** this fork ships via [skills.sh](https://skills.sh/osxsystem/skills) only; the Claude Code plugin route was removed. See [ADR 0002](../.agents/adr/0002-ship-as-a-claude-code-plugin.md) for the upstream decision this fork reverses.

**Recipe:** upstream edits to these files land as a modify/delete conflict. Keep the deletion:

```bash
git rm -r --ignore-unmatch .claude-plugin scripts/sync-plugin-version.mjs
```

Also drop any `sync-plugin-version` script upstream re-adds to `package.json`.

### `skills/engineering/setup-matt-pocock-skills/` — deleted

**Why:** the setup skill configures *this* repo's skills, and the fork's approved name (2026-08-06 rename spec, [`docs/superpowers/specs/2026-08-06-rename-setup-skill-design.md`](../docs/superpowers/specs/2026-08-06-rename-setup-skill-design.md)) is `setup-osxsystem-skills`. That skill is now a fork addition under [`skills/team/platform/`](../skills/team/platform/setup-osxsystem-skills/SKILL.md), so this is no longer a rename spanning both territories — it is a plain deletion of upstream's copy, which stays deleted rather than restored: the linker links every non-deprecated skill, so restoring upstream's copy would install two setup skills under two names.

**Recipe:** treat exactly like `.claude-plugin/` — upstream's paths stay deleted:

```bash
git rm -r --ignore-unmatch skills/engineering/setup-matt-pocock-skills docs/engineering/setup-matt-pocock-skills.md
```

Then port any upstream change to the deleted files into `skills/team/platform/setup-osxsystem-skills/` by hand — the content is otherwise unchanged from upstream's; only the name and the home differ.

### Prose files — `README.md`, `CLAUDE.md`, `CONTEXT.md`, `MAINTENANCE.md`-adjacent conventions

Affected: `README.md`, `CLAUDE.md`, `CONTEXT.md`, `.agents/install-block.md`, `.agents/writing-docs.md`, `.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md`, `skills/{engineering,in-progress,misc}/README.md`, `docs/engineering/*.md`, `docs/productivity/wait-what.md`.

**Why:** fork framing (osxsystem, not mattpocock), the team tree's sections, the fork's setup-skill name, and install commands pointing at `osxsystem/skills`. `skills/engineering/README.md` and `skills/in-progress/README.md` now diverge by *omission* — the fork skills they used to list live under `skills/team/platform/`.

**Recipe:** keep both sides — these are appended sections and entries, not rewrites. Then verify:

- install commands say `osxsystem/skills`, not `mattpocock/skills` (source of truth: [`.agents/install-block.md`](../.agents/install-block.md));
- the fork README framing and its Mobile and Platform sections survived;
- no fork skill has been re-added to an upstream bucket README.

### `package.json`, `package-lock.json`, `.changeset/config.json`, `.gitignore`

**Why:** fork package name/description/repository, the removed `sync-plugin-version` script, changelog pointing at `osxsystem/skills`, and the ignored `isolated_test_workspace/`.

**Recipe:** take upstream's dependency and tooling changes; keep the fork's identity fields (`name`, `description`, `repository`, changeset `repo`) and the fork's ignore entries.

### `skills/misc/git-guardrails-claude-code/` — hardened

**Why:** fork-hardened `block-dangerous-git.sh` and its skill doc.

**Recipe:** keep both — reconcile by re-running `bash scripts/harness/test_guardrail.sh`; the tests are the arbiter, not the diff.

### `skills/engineering/{ask-matt,code-review,to-spec,to-tickets,triage,wayfinder}/SKILL.md`

**Why:** router entries and cross-references for fork skills (the `mobile` and `platform` domains). These cite fork skills by name, not by path, so the move left them unchanged.

**Recipe:** keep both; then re-read [`ask-matt`](../skills/engineering/ask-matt/SKILL.md) and confirm every fork skill still appears and every upstream skill it routes to still exists under that name.

## Retired divergences

Recorded so a future maintainer doesn't re-create one by reflex.

### `skills/engineering/tdd/SKILL.md` — KMP section appended (retired 2026-08-13)

Upstream's `tdd` skill carried a fork-appended `## Kotlin Multiplatform projects` section: seams in `commonMain`, tests in `commonTest`, and the cheapest Gradle task that proves a slice. That guidance now lives in [`skills/team/mobile/kmp-test-seams/`](../skills/team/mobile/kmp-test-seams/SKILL.md), which cross-references `tdd` by name, and upstream's file is byte-identical again — so the path is gone from [`sanctioned-edits.txt`](./sanctioned-edits.txt) and a sync can never conflict there.

**If upstream's `tdd` skill grows KMP guidance of its own,** reconcile it into `kmp-test-seams` rather than appending here: an in-file append is the divergence this retirement removed.
