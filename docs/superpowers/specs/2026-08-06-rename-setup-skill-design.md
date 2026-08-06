# Rename `setup-matt-pocock-skills` → `setup-osxsystem-skills`

**Date:** 2026-08-06
**Status:** Approved

## Problem

This repo is the osxsystem team fork of `mattpocock/skills`. The run-once setup
skill still carries the upstream author's name, as does `package.json`. A user
who installs from `skills.sh/osxsystem/skills` is told to run
`/setup-matt-pocock-skills`, which reads as though the fork were unmodified
upstream.

Separately, `scripts/sync-plugin-version.mjs` reads `.claude-plugin/plugin.json`,
a directory this fork deleted on purpose. The script throws `ENOENT`, and
`.github/workflows/release.yml` invokes it via `npm run version` — so the release
workflow is failing on every push to `main`.

## Goals

1. Rename the skill to `setup-osxsystem-skills`, keeping its content identical.
2. Update every live reference so the documented install flow works end to end.
3. Re-point `package.json` identity fields at this fork.
4. Remove the dead plugin-version script, unblocking the release workflow.

## Non-goals

- Changing what the skill does. Its process, prompts, and four sidecar files are
  untouched.
- Rewriting history. See "Scope of the rename" below.
- Restoring `LICENSE` or `package-lock.json`, both deleted in the working tree
  before this work began. See "Known consequences".
- Modifying `scripts/link-skills.sh`, whose header states modifications will not
  be approved.

## Scope of the rename

**42 occurrences on 32 lines across 23 live files** change. Occurrences exceed
lines because a Markdown link carries the name twice — once as link text, once
in the target.

**19 occurrences across 5 historical files** do not change:

| Untouched | Occurrences | Why |
|---|---|---|
| `CHANGELOG.md` | 6 | Records what upstream shipped under the old name. Rewriting makes the release record false. |
| `.out-of-scope/mainstream-issue-trackers-only.md` | 1 | Record of a rejected idea, as argued at the time. |
| `.out-of-scope/setup-skill-verify-mode.md` | 4 | Same. |
| `docs/superpowers/plans/2026-08-06-fork-installation-customization.md` | 5 | Dated design doc from a prior session. |
| `docs/superpowers/specs/2026-08-06-fork-installation-customization-design.md` | 3 | Same. |

A dated document describes a decision made on that date. Editing it to use a
name that did not exist then is a false record, not a fix.

**This spec is also excluded.** It cites the old name throughout, by necessity.
Every verification grep below must exclude
`docs/superpowers/specs/2026-08-06-rename-setup-skill-design.md`, or it reports
its own text as an unfinished rename.

## Design

### 1. Move the two directories

```
git mv skills/engineering/setup-matt-pocock-skills \
       skills/engineering/setup-osxsystem-skills
git mv docs/engineering/setup-matt-pocock-skills.md \
       docs/engineering/setup-osxsystem-skills.md
```

`git mv` (not `mv`) so the rename is recorded as a rename and the file history
follows.

### 2. Identity edits inside the moved skill

| File | Line | From | To |
|---|---|---|---|
| `SKILL.md` | 2 | `name: setup-matt-pocock-skills` | `name: setup-osxsystem-skills` |
| `SKILL.md` | 7 | `# Setup Matt Pocock's Skills` | `# Setup osxsystem Skills` |
| `agents/openai.yaml` | 2 | `display_name: "Setup Matt Pocock Skills"` | `display_name: "Setup osxsystem Skills"` |

The frontmatter `name` must equal the directory name — that pairing is what both
harnesses resolve `/setup-osxsystem-skills` through. The four sidecar files
(`domain.md`, `triage-labels.md`, `issue-tracker-{github,gitlab,local}.md`)
contain no references and move unchanged.

`agents/openai.yaml` keeps `policy.allow_implicit_invocation: false`, and
`SKILL.md` keeps `disable-model-invocation: true`. The skill stays user-invoked.

### 3. Mechanical sweep — 24 occurrences across 14 files

Plain occurrences of `` `setup-matt-pocock-skills` ``, `/setup-matt-pocock-skills`,
and relative `./…/SKILL.md` paths. A substring swap is correct for all of them:

| File | Occurrences |
|---|---|
| `README.md` | 4 |
| `.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md` | 3 |
| `docs/engineering/setup-osxsystem-skills.md` (post-move) | 3 |
| `.agents/writing-docs.md` | 2 |
| `skills/engineering/README.md` | 2 |
| `skills/engineering/to-tickets/SKILL.md` | 2 |
| `.agents/install-block.md` | 1 |
| `CONTEXT.md` | 1 |
| `docs/engineering/triage.md` line 74 | 1 |
| `skills/engineering/{ask-matt,code-review,to-spec,triage,wayfinder}/SKILL.md` | 1 each |

`README.md` line 46 and `skills/engineering/README.md` each carry the name twice
on one line — as link text and in a relative path — but both halves are a plain
rename, so the swap is safe there.

`docs/engineering/triage.md` is the one file split across groups: line 23 is an
aihero.dev link (group 4), line 74 a plain reference (here).

`README.md` line 18 and `.agents/install-block.md` line 15 are the same sentence
by design — `install-block.md` is canonical and `README.md` copies it verbatim.
Both change identically, preserving that invariant.

### 4. Judgment edits — 16 occurrences on 8 aihero.dev lines

Eight `docs/engineering/` pages link the skill as
`https://aihero.dev/skills-setup-matt-pocock-skills`. That URL will never exist:
the fork does not publish to aihero.dev, and the renamed skill exists only here.

Each line contains the old name **twice** — once as link text, once inside the
URL — and the two halves resolve differently, so a blind substring swap produces
a confidently-wrong dead link. Each becomes:

```diff
-[setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills)
+[setup-osxsystem-skills](../../skills/engineering/setup-osxsystem-skills/SKILL.md)
```

From `docs/engineering/`, `../../skills/…` reaches the repo root. The path
resolves on GitHub and in local editors.

One line each in eight `docs/engineering/` pages: `ask-matt.md:23`,
`code-review.md:33`, `implement.md:29`, `to-spec.md:22`, `to-tickets.md:23`,
`triage.md:23`, `wayfinder.md:25`, `wizard.md:98`.

**Accepted asymmetry:** the setup link becomes relative while its neighbours in
the same sentence (e.g. `[to-tickets](https://aihero.dev/skills-to-tickets)`)
stay absolute. This is intentional. Those skills are published under those URLs;
this one is not. A uniform-looking dead link would be worse than a visibly
different working one.

### 5. `package.json`

```diff
-  "name": "mattpocock-skills",
+  "name": "osxsystem-skills",
-  "description": "Matt Pocock's agent skills for real engineering",
+  "description": "osxsystem team agent skills for real engineering — Kotlin Multiplatform + Compose Multiplatform",
   "repository": {
     "type": "git",
-    "url": "https://github.com/mattpocock/skills"
+    "url": "https://github.com/osxsystem/skills"
   },
   "scripts": {
     "changeset": "changeset",
-    "version": "changeset version && node scripts/sync-plugin-version.mjs",
-    "check-plugin-version": "node scripts/sync-plugin-version.mjs --check"
+    "version": "changeset version"
   },
```

`version` stays at `1.2.2`; this is not a release. `private: true` is unchanged —
nothing publishes to npm.

### 6. Delete `scripts/sync-plugin-version.mjs`

Its only job was copying `package.json`'s version into
`.claude-plugin/plugin.json`. That manifest is gone by design
(`.agents/install-block.md`, "No plugin route"), so the script has nothing to
sync and throws `ENOENT` at line 14 before any logic runs.

No workflow or changeset references it by name — verified by grep over
`.github/` and `.changeset/`. It is reached only through `npm run version`, and
`changeset version` alone still performs the real work: bumping `package.json`
and writing `CHANGELOG.md`.

### 7. One semantic edit

`CUSTOMIZING.md` line 53 reads:

> 4. **Prune skills the team won't use** (e.g. `ask-matt`,
>    `setup-matt-pocock-skills` are upstream-author-specific) into `deprecated/`.

A substring swap yields "`setup-osxsystem-skills` is upstream-author-specific",
which contradicts itself after the rename. This is the only line where the
rename changes meaning rather than tokens.

Resolution: drop the skill from that example list, leaving `ask-matt` as the
sole example. The advice to prune unused skills stands; the example no longer
applies to a skill this fork just claimed as its own.

## Verification

1. Live files return **nothing**, excluding history and this spec:

   ```bash
   grep -rl setup-matt-pocock-skills . --exclude-dir=.git \
     | grep -v -e CHANGELOG -e out-of-scope -e superpowers
   ```

2. The 5 historical files still total **19** occurrences:

   ```bash
   grep -ro setup-matt-pocock-skills CHANGELOG.md .out-of-scope/ \
     docs/superpowers/plans/ \
     docs/superpowers/specs/2026-08-06-fork-installation-customization-design.md \
     | wc -l   # → 19
   ```
3. `git status` shows the two moves recorded as renames, not delete+add.
4. `skills/engineering/setup-osxsystem-skills/SKILL.md` frontmatter `name`
   equals its directory name.
5. `README.md` step 2 reads ``Run `/setup-osxsystem-skills` ``, matching the
   directory a user installs.
6. `node -e "JSON.parse(require('fs').readFileSync('package.json'))"` parses.
7. The 8 rewritten relative links resolve to an existing file.

## Known consequences

**`npm ci` and the deleted lockfile.** `.github/workflows/release.yml` line 27
runs `npm ci`, which requires `package-lock.json`. That file is deleted in the
working tree. If the deletion is committed, Release fails at the install step —
independently of this rename, which neither causes nor fixes it. Recorded, not
acted on, per explicit decision.

**`LICENSE` deleted.** Also pre-existing and deliberate. Noted only because
`npx skills add osxsystem/skills` redistributes this code and MIT asks that the
notice ride along. Out of scope by decision.

**Stale symlinks.** `scripts/link-skills.sh` links by directory basename and
never prunes. Anyone who ran it before this rename keeps a dangling
`~/.claude/skills/setup-matt-pocock-skills` and
`~/.agents/skills/setup-matt-pocock-skills`, which surface a broken slash
command. No such symlinks exist on the current machine (verified). The script
may not be modified, so the fix is a one-line `rm` in the release notes:

```bash
rm -f ~/.claude/skills/setup-matt-pocock-skills \
      ~/.agents/skills/setup-matt-pocock-skills
```

**Downstream repos.** Anyone who already installed the skill has a copy under
the old name. `npx skills update` will not rename a directory on their disk;
they re-add under the new name and delete the old one. Acceptable — the fork has
no external consumers yet.
