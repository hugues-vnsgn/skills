# Fork Installation Customization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Drop the Claude Code plugin install route entirely, make skills.sh (pointed at `osxsystem/skills`) the single install route, and reframe `README.md` as the osxsystem fork README crediting upstream `mattpocock/skills`.

**Architecture:** Pure docs/config change — no code, no skills change behaviour. Delete `.claude-plugin/`, rewrite the canonical install text in `.agents/install-block.md`, rewrite the top of `README.md` (Reference section stays verbatim), and update the four rule/index files that instruct agents about the plugin layer (`CLAUDE.md`, `MAINTENANCE.md`, `CUSTOMIZING.md`, two bucket READMEs).

**Tech Stack:** Markdown, git, grep for verification. No build or test suite applies — each task's "test" is a grep/ls verification command with expected output.

**Spec:** `docs/superpowers/specs/2026-08-06-fork-installation-customization-design.md` (approved).

## Global Constraints

- Never touch anything outside `/Users/hugues_mini/Codes/skills`.
- Install commands must read exactly: `npx skills@latest add osxsystem/skills` (whole-set), `npx skills@latest add osxsystem/skills --skill=<name>` and `npx skills@latest update <name>` (single-skill). `skills@latest` is the pinned spelling.
- No skill renames: `setup-matt-pocock-skills` and `ask-matt` keep their names everywhere.
- `.agents/adr/0002-ship-as-a-claude-code-plugin.md` is historical record — do not edit it.
- Do not touch: `package.json`, `package-lock.json`, `CHANGELOG.md`, `.changeset/`, `docs/engineering/`, `docs/productivity/`, `docs/mobile/`, `research/`, `scripts/`, any `skills/*/SKILL.md`.
- The README's `## Reference` section (skill tables) stays byte-for-byte unchanged.
- Commit after every task, message prefix `docs:`.

---

### Task 1: Delete the plugin directory

**Files:**
- Delete: `.claude-plugin/plugin.json`
- Delete: `.claude-plugin/marketplace.json`

**Interfaces:**
- Consumes: nothing.
- Produces: `.claude-plugin/` no longer exists — later tasks remove every reference to it.

- [ ] **Step 1: Delete the directory via git**

```bash
git rm -r .claude-plugin
```

- [ ] **Step 2: Verify it is gone**

Run: `ls .claude-plugin`
Expected: `ls: .claude-plugin: No such file or directory`

- [ ] **Step 3: Commit**

```bash
git commit -m "docs: remove Claude Code plugin manifests — skills.sh is the only install route"
```

---

### Task 2: Rewrite `.agents/install-block.md` (canonical install text)

**Files:**
- Modify: `.agents/install-block.md` (full rewrite)

**Interfaces:**
- Consumes: nothing.
- Produces: the canonical install wording that Task 3 (README) and Task 7 (in-progress README) copy verbatim — canonical blocks `skills-sh-whole-set` and `skills-sh-one-skill`.

- [ ] **Step 1: Replace the entire file content with:**

````markdown
# The canonical install block

One install story, one wording. `README.md`, `.changeset/*`, and every page under `docs/` must say **this** and nothing else. Change it here first, then propagate.

The single install route is [skills.sh](https://skills.sh/osxsystem/skills), which copies editable skill files into the project — files you own and can edit. Nothing updates behind your back; pull the latest changes with `npx skills update`.

## Whole set — on `README.md`

<canonical-block name="skills-sh-whole-set">

```bash
npx skills@latest add osxsystem/skills
```

Pick the skills you want, and which coding agents to install them on. **The installer lets you choose which skills to take — make sure `setup-matt-pocock-skills` is one of them.**

</canonical-block>

## Single skill — wherever one skill is named on its own

Note that **`docs/` pages are not a consumer of this block**: ai-hero renders the install widget above the body, so a page that writes the commands out duplicates it. See [writing-docs.md](./writing-docs.md).

<canonical-block name="skills-sh-one-skill">

```bash
npx skills@latest add osxsystem/skills --skill=<name>
```

```bash
npx skills@latest update <name>
```

</canonical-block>

`skills@latest` is the pinned spelling in both. The pages under `docs/` used to carry their own copy of these commands; those blocks are now deleted rather than corrected, because the site renders the install commands itself.

## No plugin route

Upstream ships a Claude Code plugin from `.claude-plugin/`; this fork deleted that directory, and skills.sh is the only install route. Upstream syncs that re-add `.claude-plugin/` are resolved by deleting it again — see [MAINTENANCE.md](../MAINTENANCE.md). The history of the plugin decision lives in [adr/0002-ship-as-a-claude-code-plugin.md](./adr/0002-ship-as-a-claude-code-plugin.md).
````

- [ ] **Step 2: Verify no stale references remain**

Run: `grep -n "mattpocock/skills\|claude plugins install\|/plugin install\|marketplace" .agents/install-block.md`
Expected: no output (exit code 1).

Run: `grep -c "osxsystem/skills" .agents/install-block.md`
Expected: `3` (skills.sh link, whole-set command, single-skill command).

- [ ] **Step 3: Commit**

```bash
git add .agents/install-block.md
git commit -m "docs: install block — drop plugin route, point skills.sh at osxsystem/skills"
```

---

### Task 3: Rewrite `README.md` as the fork README

**Files:**
- Modify: `README.md` — replace everything **above** the `## Reference` heading (currently lines 1–183); keep `## Reference` (line 184) through end of file byte-for-byte unchanged.

**Interfaces:**
- Consumes: canonical block `skills-sh-whole-set` from Task 2 (copied verbatim).
- Produces: the fork README. Task 8 greps it for success criteria.

- [ ] **Step 1: Replace lines 1–183 (everything above `## Reference`) with:**

````markdown
# osxsystem/skills

[![skills.sh](https://skills.sh/b/osxsystem/skills)](https://skills.sh/osxsystem/skills)

The **osxsystem team fork** of [mattpocock/skills](https://github.com/mattpocock/skills), customized for mobile development with **Kotlin Multiplatform + Compose Multiplatform** (Android + iOS/Swift).

> [!NOTE]
> This project uses [mattpocock/skills](https://github.com/mattpocock/skills) — Matt Pocock's agent skills for real engineering. All credit for the engineering, productivity, and misc skills goes to the upstream author; read the [upstream README](https://github.com/mattpocock/skills#why-these-skills-exist) for the philosophy behind them.

What this fork adds on top of upstream:

- **[`skills/mobile/`](./skills/mobile/README.md)** — team skills for Kotlin Multiplatform + Compose Multiplatform development
- Fork conventions in [MAINTENANCE.md](./MAINTENANCE.md) and [CUSTOMIZING.md](./CUSTOMIZING.md)

## Installation (30-second setup)

### 1. Get the skills

```bash
npx skills@latest add osxsystem/skills
```

Pick the skills you want, and which coding agents to install them on. **The installer lets you choose which skills to take — make sure `setup-matt-pocock-skills` is one of them.**

The installer writes the skills into your repo as ordinary files you own and can edit. Nothing updates behind your back; pull the latest changes when you want them with `npx skills update`.

### 2. Run `/setup-matt-pocock-skills`

In your agent, run it once per repo. It will:

- Ask you which issue tracker you want to use (GitHub, Linear, or local files)
- Ask you what labels you apply to tickets when you triage them (`/triage` uses labels)
- Ask you where you want to save any docs we create

### 3. Bam - you're ready to go.

````

(The `## Reference` heading and everything after it — the Engineering, Productivity, and Mobile skill tables — stay exactly as they are.)

- [ ] **Step 2: Verify**

Run: `grep -n "mattpocock" README.md`
Expected: matches only on the fork-description line and the `> [!NOTE]` credit line (2 lines). None inside a code block, badge, or skills.sh URL.

Run: `grep -n "plugin\|newsletter\|aihero\|Why These Skills Exist" README.md`
Expected: no output (exit code 1).

Run: `grep -n "^## Reference" README.md && grep -c "SKILL.md" README.md`
Expected: `## Reference` present; SKILL.md link count ≥ 30 (the tables survived).

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: reframe README as osxsystem fork — skills.sh install only, credit upstream"
```

---

### Task 4: Update `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md:7` (mobile bucket line), `CLAUDE.md:9` (in-progress line), `CLAUDE.md:12` (registration rule), `CLAUDE.md:14` (install-block paragraph)

**Interfaces:**
- Consumes: Task 1 (directory deleted) — this task removes the instructions pointing at it.
- Produces: the registration rule later tasks and future agents follow: promoted skills register in bucket README + top-level README + docs page only.

- [ ] **Step 1: Apply these four line replacements**

Line 7, replace:

```markdown
- `mobile/` — **fork addition**: Kotlin Multiplatform / Compose Multiplatform team skills (promoted: listed in the top-level `README.md`, `.claude-plugin/plugin.json`, and `docs/mobile/`)
```

with:

```markdown
- `mobile/` — **fork addition**: Kotlin Multiplatform / Compose Multiplatform team skills (promoted: listed in the top-level `README.md` and `docs/mobile/`)
```

Line 9, replace:

```markdown
- `in-progress/` — beta: public on purpose, feedback wanted, not shipped in the plugin
```

with:

```markdown
- `in-progress/` — beta: public on purpose, feedback wanted, not promoted
```

Line 12, replace:

```markdown
Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`'s `skills` array (the Claude Code plugin ships exactly the promoted set). Skills in `misc/`, `in-progress/`, and `deprecated/` must not appear in either.
```

with:

```markdown
Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md`. Skills in `misc/`, `in-progress/`, and `deprecated/` must not appear there.
```

Line 14, replace:

```markdown
Install commands are copied verbatim from [.agents/install-block.md](./.agents/install-block.md). `.claude-plugin/marketplace.json` makes the repo its own single-plugin marketplace — a fallback the install block explains, not the documented route. Run `claude plugin validate . --strict` after touching either manifest. Why a Claude plugin but not (yet) a Codex one lives in [.agents/adr/0002-ship-as-a-claude-code-plugin.md](./.agents/adr/0002-ship-as-a-claude-code-plugin.md).
```

with:

```markdown
Install commands are copied verbatim from [.agents/install-block.md](./.agents/install-block.md). This fork ships via [skills.sh](https://skills.sh/osxsystem/skills) only — upstream's Claude Code plugin route (`.claude-plugin/`) was removed, and upstream syncs that re-add it are resolved by deleting it again (see [MAINTENANCE.md](./MAINTENANCE.md)). The history of the plugin decision lives in [.agents/adr/0002-ship-as-a-claude-code-plugin.md](./.agents/adr/0002-ship-as-a-claude-code-plugin.md).
```

- [ ] **Step 2: Verify**

Run: `grep -n "plugin.json\|plugin validate\|marketplace\|shipped in the plugin" CLAUDE.md`
Expected: no output (exit code 1).

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: CLAUDE.md — drop plugin registration layer and validation steps"
```

---

### Task 5: Update `MAINTENANCE.md`

**Files:**
- Modify: `MAINTENANCE.md:13` (fork-additions table), `MAINTENANCE.md:~20` (conflict note), `MAINTENANCE.md:25-27` (post-sync checklist), `MAINTENANCE.md:37` (register list)

**Interfaces:**
- Consumes: Task 1 (deletion is the new steady state the sync instructions must preserve).
- Produces: the upstream-sync procedure that keeps `.claude-plugin/` deleted.

- [ ] **Step 1: Apply these replacements**

Table row (line 13), replace:

```markdown
| Upstream files touched | `README.md` (Mobile section), `CLAUDE.md` (mobile bucket), `.claude-plugin/plugin.json` (mobile skills), `skills/engineering/tdd/SKILL.md` (KMP section at the end) |
```

with:

```markdown
| Upstream files touched | `README.md` (reframed as fork README + Mobile section), `CLAUDE.md` (mobile bucket, plugin route removed), `skills/engineering/tdd/SKILL.md` (KMP section at the end); `.claude-plugin/` deleted (skills.sh is the only install route) |
```

Conflict note (the sentence after the sync commands), replace:

```markdown
Conflicts will cluster in the four upstream files we touched (table above); our changes are appended sections/entries, so resolution is usually "keep both". After every sync:
```

with:

```markdown
Conflicts will cluster in the upstream files we touched (table above); our changes are appended sections/entries, so resolution is usually "keep both" — except `.claude-plugin/`, which we deleted and upstream may re-add. After every sync:
```

Post-sync checklist (lines 25–27), replace:

```markdown
1. `claude plugin validate . --strict` — both manifests still valid.
2. Confirm the Mobile section survived in `README.md` and `plugin.json`.
3. Skim upstream's `CHANGELOG.md` for renamed/moved skills our mobile skills cross-reference (`tdd`, `code-review`).
```

with:

```markdown
1. Confirm `.claude-plugin/` stays deleted — if the merge restored it, run `git rm -r .claude-plugin` and commit.
2. Confirm the fork README framing and the Mobile section survived in `README.md`, and that install commands still say `osxsystem/skills` (upstream's say `mattpocock/skills`).
3. Skim upstream's `CHANGELOG.md` for renamed/moved skills our mobile skills cross-reference (`tdd`, `code-review`).
```

Register list (line 37), replace:

```markdown
3. Register it in: `skills/mobile/README.md`, top-level `README.md` (Mobile section), `.claude-plugin/plugin.json`, and add `docs/mobile/<name>.md` (What it does / When to reach for it / one substance section / It's working if).
```

with:

```markdown
3. Register it in: `skills/mobile/README.md`, top-level `README.md` (Mobile section), and add `docs/mobile/<name>.md` (What it does / When to reach for it / one substance section / It's working if).
```

- [ ] **Step 2: Verify**

Run: `grep -n "plugin.json\|plugin validate" MAINTENANCE.md`
Expected: no output (exit code 1).

Run: `grep -c "claude-plugin" MAINTENANCE.md`
Expected: `3` (table row, conflict note, checklist item 1 — all describing the deletion, none instructing registration).

- [ ] **Step 3: Commit**

```bash
git add MAINTENANCE.md
git commit -m "docs: MAINTENANCE.md — sync procedure keeps .claude-plugin deleted"
```

---

### Task 6: Update `CUSTOMIZING.md`

**Files:**
- Modify: `CUSTOMIZING.md` section 2 (layers table + intro sentence), section 3 steps 1 and 4

**Interfaces:**
- Consumes: registration rule from Task 4 (three layers, not four).
- Produces: consistent customization loop for future skill edits.

- [ ] **Step 1: Apply these replacements**

Section 2 intro sentence, replace:

```markdown
The repo distinguishes **promoted** buckets (`engineering/`, `productivity/`, `mobile/`) from parked ones (`misc/`, `in-progress/`, `deprecated/`). A promoted skill is registered in four places, and edits ripple to all of them:
```

with:

```markdown
The repo distinguishes **promoted** buckets (`engineering/`, `productivity/`, `mobile/`) from parked ones (`misc/`, `in-progress/`, `deprecated/`). A promoted skill is registered in three places besides the skill itself, and edits ripple to all of them:
```

In the layers table, delete this row entirely:

```markdown
| Plugin manifest | `.claude-plugin/plugin.json` → validate with `claude plugin validate . --strict` |
```

Section 3, step 1, third bullet — replace:

```markdown
   - *Demote or remove* — move to `deprecated/`, deregister from the four layers.
```

with:

```markdown
   - *Demote or remove* — move to `deprecated/`, deregister from the three layers.
```

Section 3, step 4 — replace:

```markdown
4. **Register and validate** (the four layers), then commit and push.
```

with:

```markdown
4. **Register** (the three layers), then commit and push.
```

- [ ] **Step 2: Verify**

Run: `grep -n "plugin\|four layers\|four places" CUSTOMIZING.md`
Expected: no output (exit code 1).

- [ ] **Step 3: Commit**

```bash
git add CUSTOMIZING.md
git commit -m "docs: CUSTOMIZING.md — registration is three layers, plugin manifest dropped"
```

---

### Task 7: Update bucket READMEs (`in-progress`, `misc`)

**Files:**
- Modify: `skills/in-progress/README.md:3-9`
- Modify: `skills/misc/README.md:3`

**Interfaces:**
- Consumes: canonical block `skills-sh-one-skill` from Task 2 (the single-skill command form).
- Produces: no live text anywhere references the plugin or a `mattpocock/skills` install command.

- [ ] **Step 1: Edit `skills/in-progress/README.md`**

Replace:

```markdown
Beta. These skills are public on purpose — try them and tell me what breaks. They're excluded from the plugin and the top-level README until they graduate to a stable bucket, they get no docs pages, and they can change or disappear without warning.

The plugin won't give you these. Install one directly:

```bash
npx skills@latest add mattpocock/skills --skill=<name>
```
```

with:

```markdown
Beta. These skills are public on purpose — try them and tell me what breaks. They're excluded from the top-level README until they graduate to a stable bucket, they get no docs pages, and they can change or disappear without warning.

Install one directly:

```bash
npx skills@latest add osxsystem/skills --skill=<name>
```
```

- [ ] **Step 2: Edit `skills/misc/README.md`**

Replace:

```markdown
Tools I keep around but rarely use — not promoted in the plugin.
```

with:

```markdown
Tools I keep around but rarely use — not promoted.
```

- [ ] **Step 3: Verify**

Run: `grep -rn "plugin\|mattpocock" skills/in-progress/README.md skills/misc/README.md`
Expected: no output (exit code 1).

- [ ] **Step 4: Commit**

```bash
git add skills/in-progress/README.md skills/misc/README.md
git commit -m "docs: bucket READMEs — drop plugin mentions, install via osxsystem/skills"
```

---

### Task 8: Repo-wide success-criteria sweep

**Files:**
- None modified (verification only; fix-ups go in the file the grep flags).

**Interfaces:**
- Consumes: all prior tasks.
- Produces: confirmation the spec's success criteria hold.

- [ ] **Step 1: Plugin directory gone**

Run: `ls .claude-plugin 2>&1`
Expected: `No such file or directory`

- [ ] **Step 2: No live plugin instructions**

Run: `grep -rn "claude plugins install\|/plugin install\|plugin validate\|claude-plugin" README.md CLAUDE.md MAINTENANCE.md CUSTOMIZING.md .agents/install-block.md skills/*/README.md`
Expected: only MAINTENANCE.md / CLAUDE.md / install-block.md lines that *describe the deletion* (`.claude-plugin/` deleted / re-add resolved by deleting). No install commands, no validate commands, no registration instructions.

- [ ] **Step 3: No mattpocock install commands or badges**

Run: `grep -rn "mattpocock" README.md .agents/install-block.md skills/*/README.md`
Expected: matches only in `README.md`'s intro/credit links (3 lines). No matches in code blocks, badges, or other files.

- [ ] **Step 4: Working tree clean**

Run: `git status --porcelain`
Expected: no output. If any grep in steps 2–3 flagged a stray line, fix it in that file, amend or add a `docs: sweep fixes` commit, and re-run this task.

---

## Out of scope (from the spec)

- Renaming `setup-matt-pocock-skills` / `ask-matt` (CUSTOMIZING.md roadmap item, later).
- `package.json` / `CHANGELOG.md` / `.changeset/` (upstream release machinery).
- `docs/` skill pages (no install commands in them), `research/`, `scripts/`, all `SKILL.md` files, the ADR.
- Anything outside this repo.
