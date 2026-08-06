# Rename `setup-matt-pocock-skills` → `setup-osxsystem-skills` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the run-once setup skill to `setup-osxsystem-skills` across all live files, re-point `package.json` at this fork, and delete the dead plugin-version script that is failing CI.

**Architecture:** Five independent edit groups, ordered so the directory move lands first and every later task edits files at their final paths. The mechanical group is a scripted `perl` sweep over plain-text references; the cross-link group is hand-edited because those lines change *form* (absolute URL → relative path), not just tokens. `package.json` and the script deletion are independent of the rename and could land alone.

**Tech Stack:** Markdown, JSON, `git mv`, `perl -pi -e`, `grep`. No test runner exists in this repo — it ships Markdown skills, not code.

**Spec:** `docs/superpowers/specs/2026-08-06-rename-setup-skill-design.md`

## Global Constraints

- **New name is exactly `setup-osxsystem-skills`** — lowercase, hyphenated, no scope prefix.
- **Human-facing display strings are exactly `Setup osxsystem Skills`** — lowercase `osxsystem`, matching the org name as written everywhere else in this repo.
- **Skill content does not change.** Only the `name:` frontmatter field, the H1, and the `display_name` are edited inside the skill. Process prose, prompts, and the four sidecar files are untouched.
- **Do not edit these 5 historical files** — they record what was true when written: `CHANGELOG.md`, `.out-of-scope/mainstream-issue-trackers-only.md`, `.out-of-scope/setup-skill-verify-mode.md`, `docs/superpowers/plans/2026-08-06-fork-installation-customization.md`, `docs/superpowers/specs/2026-08-06-fork-installation-customization-design.md`. They hold 19 occurrences that must survive.
- **Do not edit the spec or this plan.** Both cite the old name by necessity and sit under `docs/superpowers/`, which every verification grep excludes.
- **Do not restore `LICENSE` or `package-lock.json`.** Both are deleted in the working tree by prior decision. Never `git add` them.
- **Do not modify `scripts/link-skills.sh`.** Its header states modifications will not be approved.
- **`package.json` stays at version `1.2.2` and `private: true`.** This is not a release.
- **Use `perl -pi -e`, not `sed -i`.** macOS ships BSD sed, where `-i` requires a backup-suffix argument; `perl` behaves identically on both platforms.
- **Expected totals:** 42 occurrences on 32 lines across 23 live files change. 24 mechanical + 16 cross-link + 1 frontmatter + 1 CUSTOMIZING = 42.

---

## File Structure

**Moved (2):**
- `skills/engineering/setup-matt-pocock-skills/` → `skills/engineering/setup-osxsystem-skills/` — the skill itself, 7 files
- `docs/engineering/setup-matt-pocock-skills.md` → `docs/engineering/setup-osxsystem-skills.md` — its human-facing docs page

**Deleted (1):**
- `scripts/sync-plugin-version.mjs` — synced a manifest this fork does not have

**Modified — mechanical sweep (14):** `README.md`, `CONTEXT.md`, `.agents/install-block.md`, `.agents/writing-docs.md`, `.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md`, `skills/engineering/README.md`, `docs/engineering/setup-osxsystem-skills.md`, `docs/engineering/triage.md`, and the `SKILL.md` of `ask-matt`, `code-review`, `to-spec`, `to-tickets`, `triage`, `wayfinder`

**Modified — cross-links (8):** `docs/engineering/{ask-matt,code-review,implement,to-spec,to-tickets,triage,wayfinder,wizard}.md`

**Modified — judgment (2):** `CUSTOMIZING.md`, `package.json`

Note `docs/engineering/triage.md` appears in two groups: line 23 is a cross-link, line 74 a plain reference.

---

### Task 1: Move the skill and set its identity

**Files:**
- Move: `skills/engineering/setup-matt-pocock-skills/` → `skills/engineering/setup-osxsystem-skills/`
- Move: `docs/engineering/setup-matt-pocock-skills.md` → `docs/engineering/setup-osxsystem-skills.md`
- Modify: `skills/engineering/setup-osxsystem-skills/SKILL.md:2,7`
- Modify: `skills/engineering/setup-osxsystem-skills/agents/openai.yaml:2`

**Interfaces:**
- Produces: the directory path `skills/engineering/setup-osxsystem-skills/` and the docs path `docs/engineering/setup-osxsystem-skills.md`. Tasks 2 and 3 write links pointing at both; both must exist before those tasks run.
- Produces: frontmatter `name: setup-osxsystem-skills`, which is what resolves the `/setup-osxsystem-skills` slash command.

- [ ] **Step 1: Write the failing check**

The invariant: a skill's frontmatter `name` must equal its directory basename, and no directory may carry the old name. Save as `/tmp/check-task1.sh`:

```bash
#!/usr/bin/env bash
# Fails if the skill dir or docs page still carries the old name,
# or if frontmatter `name` disagrees with the directory basename.
set -uo pipefail
cd /Users/hugues_mini/Codes/skills
fail=0

[ -d skills/engineering/setup-matt-pocock-skills ] && { echo "FAIL: old skill dir exists"; fail=1; }
[ -f docs/engineering/setup-matt-pocock-skills.md ] && { echo "FAIL: old docs page exists"; fail=1; }
[ -d skills/engineering/setup-osxsystem-skills ] || { echo "FAIL: new skill dir missing"; fail=1; }
[ -f docs/engineering/setup-osxsystem-skills.md ] || { echo "FAIL: new docs page missing"; fail=1; }

if [ -f skills/engineering/setup-osxsystem-skills/SKILL.md ]; then
  name=$(grep -m1 '^name:' skills/engineering/setup-osxsystem-skills/SKILL.md | sed 's/^name: *//')
  [ "$name" = "setup-osxsystem-skills" ] || { echo "FAIL: frontmatter name is '$name'"; fail=1; }
  grep -q '^# Setup osxsystem Skills$' skills/engineering/setup-osxsystem-skills/SKILL.md \
    || { echo "FAIL: H1 not updated"; fail=1; }
  grep -q '^disable-model-invocation: true$' skills/engineering/setup-osxsystem-skills/SKILL.md \
    || { echo "FAIL: disable-model-invocation lost"; fail=1; }
fi

if [ -f skills/engineering/setup-osxsystem-skills/agents/openai.yaml ]; then
  grep -q 'display_name: "Setup osxsystem Skills"' skills/engineering/setup-osxsystem-skills/agents/openai.yaml \
    || { echo "FAIL: display_name not updated"; fail=1; }
  grep -q 'allow_implicit_invocation: false' skills/engineering/setup-osxsystem-skills/agents/openai.yaml \
    || { echo "FAIL: allow_implicit_invocation lost"; fail=1; }
fi

[ $fail -eq 0 ] && echo "PASS"
exit $fail
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task1.sh`
Expected: FAIL lines for "old skill dir exists", "old docs page exists", "new skill dir missing", "new docs page missing". Exit code 1.

- [ ] **Step 3: Move both paths**

```bash
cd /Users/hugues_mini/Codes/skills
git mv skills/engineering/setup-matt-pocock-skills \
       skills/engineering/setup-osxsystem-skills
git mv docs/engineering/setup-matt-pocock-skills.md \
       docs/engineering/setup-osxsystem-skills.md
```

Use `git mv`, not `mv` — it stages the move as a rename so `git log --follow` keeps the file's history.

- [ ] **Step 4: Edit the three identity strings**

`skills/engineering/setup-osxsystem-skills/SKILL.md` line 2:

```diff
-name: setup-matt-pocock-skills
+name: setup-osxsystem-skills
```

`skills/engineering/setup-osxsystem-skills/SKILL.md` line 7:

```diff
-# Setup Matt Pocock's Skills
+# Setup osxsystem Skills
```

`skills/engineering/setup-osxsystem-skills/agents/openai.yaml` line 2:

```diff
-  display_name: "Setup Matt Pocock Skills"
+  display_name: "Setup osxsystem Skills"
```

Leave `description:` on SKILL.md line 3 alone — it names no author. Leave `short_description: "Configure a repo for the skills"` alone.

- [ ] **Step 5: Run the check to verify it passes**

Run: `bash /tmp/check-task1.sh`
Expected: `PASS`, exit code 0.

- [ ] **Step 6: Verify the moves registered as renames**

Run: `git status --short`
Expected: lines beginning `R ` (rename), not `D ` + `A ` pairs. The skill's 6 unmodified sidecar files should each show as `R`.

Also confirm no sidecar drifted:

Run: `ls skills/engineering/setup-osxsystem-skills/`
Expected exactly: `SKILL.md  agents  domain.md  issue-tracker-github.md  issue-tracker-gitlab.md  issue-tracker-local.md  triage-labels.md`

- [ ] **Step 7: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add skills/engineering/setup-osxsystem-skills docs/engineering/setup-osxsystem-skills.md
git commit -m "refactor: rename setup-matt-pocock-skills skill to setup-osxsystem-skills"
```

Do not use `git add -A` or `git add .` — that would stage the `LICENSE` and `package-lock.json` deletions, which are explicitly out of scope.

---

### Task 2: Mechanical sweep — 24 plain references across 14 files

**Files:**
- Modify: `README.md:18,22,46` (4 occurrences — line 46 holds two)
- Modify: `.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md:1,3,7` (3)
- Modify: `docs/engineering/setup-osxsystem-skills.md:3,11,94` (3)
- Modify: `.agents/writing-docs.md:36,66` (2)
- Modify: `skills/engineering/README.md:13` (2 — link text and relative path)
- Modify: `skills/engineering/to-tickets/SKILL.md:11,60` (2)
- Modify: `.agents/install-block.md:15` (1)
- Modify: `CONTEXT.md:3` (1)
- Modify: `docs/engineering/triage.md:74` (1)
- Modify: `skills/engineering/ask-matt/SKILL.md:90` (1)
- Modify: `skills/engineering/code-review/SKILL.md:13` (1)
- Modify: `skills/engineering/to-spec/SKILL.md:9` (1)
- Modify: `skills/engineering/triage/SKILL.md:43` (1)
- Modify: `skills/engineering/wayfinder/SKILL.md:25` (1)

**Interfaces:**
- Consumes: the moved paths from Task 1. `README.md:46` and `skills/engineering/README.md:13` contain relative links into the skill directory; those resolve only after Task 1 landed.
- Produces: `README.md:22` reading ``### 2. Run `/setup-osxsystem-skills` `` — the line a user follows to complete installation.

Every occurrence in this task is a plain substring swap. None sit inside an `aihero.dev` URL — those are Task 3, and this task's file list deliberately excludes the 8 files that hold them, except `docs/engineering/triage.md`, where only line 74 is in scope here.

- [ ] **Step 1: Write the failing check**

Save as `/tmp/check-task2.sh`:

```bash
#!/usr/bin/env bash
# Fails if any of the 14 mechanical files still holds the old name,
# or if the sweep changed the wrong count.
set -uo pipefail
cd /Users/hugues_mini/Codes/skills
fail=0

FILES=(
  README.md
  CONTEXT.md
  .agents/install-block.md
  .agents/writing-docs.md
  .agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md
  skills/engineering/README.md
  docs/engineering/setup-osxsystem-skills.md
  skills/engineering/ask-matt/SKILL.md
  skills/engineering/code-review/SKILL.md
  skills/engineering/to-spec/SKILL.md
  skills/engineering/to-tickets/SKILL.md
  skills/engineering/triage/SKILL.md
  skills/engineering/wayfinder/SKILL.md
)

for f in "${FILES[@]}"; do
  n=$(grep -o 'setup-matt-pocock-skills' "$f" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" = "0" ] || { echo "FAIL: $f still has $n occurrence(s)"; fail=1; }
done

# triage.md: line 74 must be clean, line 23 is Task 3's and may still be dirty.
sed -n '74p' docs/engineering/triage.md | grep -q 'setup-matt-pocock-skills' \
  && { echo "FAIL: docs/engineering/triage.md:74 not swept"; fail=1; }

# The install sentence and the run-this heading are what make installation work.
grep -q '### 2. Run `/setup-osxsystem-skills`' README.md \
  || { echo "FAIL: README install step 2 not renamed"; fail=1; }
grep -q 'make sure `setup-osxsystem-skills` is one of them' README.md \
  || { echo "FAIL: README install sentence not renamed"; fail=1; }

# README.md:18 and install-block.md:15 are the same canonical sentence.
a=$(grep -F 'make sure `setup-osxsystem-skills` is one of them' README.md)
b=$(grep -F 'make sure `setup-osxsystem-skills` is one of them' .agents/install-block.md)
[ -n "$a" ] && [ "$a" = "$b" ] || { echo "FAIL: README/install-block sentences diverged"; fail=1; }

# Relative links must resolve to real files.
[ -f skills/engineering/setup-osxsystem-skills/SKILL.md ] \
  || { echo "FAIL: link target missing"; fail=1; }

[ $fail -eq 0 ] && echo "PASS"
exit $fail
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task2.sh`
Expected: FAIL lines for all 13 listed files plus the triage line-74 check and both README assertions. Exit code 1.

- [ ] **Step 3: Run the sweep**

```bash
cd /Users/hugues_mini/Codes/skills
perl -pi -e 's/setup-matt-pocock-skills/setup-osxsystem-skills/g' \
  README.md \
  CONTEXT.md \
  .agents/install-block.md \
  .agents/writing-docs.md \
  .agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md \
  skills/engineering/README.md \
  docs/engineering/setup-osxsystem-skills.md \
  skills/engineering/ask-matt/SKILL.md \
  skills/engineering/code-review/SKILL.md \
  skills/engineering/to-spec/SKILL.md \
  skills/engineering/to-tickets/SKILL.md \
  skills/engineering/triage/SKILL.md \
  skills/engineering/wayfinder/SKILL.md
```

`docs/engineering/triage.md` is **not** in that list — it holds a cross-link on line 23 that a blind swap would corrupt. Sweep only its line 74:

```bash
perl -pi -e 's/setup-matt-pocock-skills/setup-osxsystem-skills/g if $. == 74' \
  docs/engineering/triage.md
```

- [ ] **Step 4: Run the check to verify it passes**

Run: `bash /tmp/check-task2.sh`
Expected: `PASS`, exit code 0.

- [ ] **Step 5: Confirm the cross-links were left alone**

Run: `grep -o 'setup-matt-pocock-skills' docs/engineering/*.md | wc -l`
Expected: `16` — the eight cross-link lines, two occurrences each, untouched and waiting for Task 3.

Run: `sed -n '23p' docs/engineering/triage.md`
Expected: still contains `https://aihero.dev/skills-setup-matt-pocock-skills`.

- [ ] **Step 6: Eyeball the two doubled lines**

Run: `grep -n 'setup-osxsystem-skills' README.md skills/engineering/README.md`
Expected — `README.md:46` and `skills/engineering/README.md:13` each show the name twice, once as link text and once inside a path ending `/SKILL.md`:

```
README.md:46:- **[setup-osxsystem-skills](./skills/engineering/setup-osxsystem-skills/SKILL.md)** — Configure this repo…
skills/engineering/README.md:13:- **[setup-osxsystem-skills](./setup-osxsystem-skills/SKILL.md)** — Configure this repo…
```

- [ ] **Step 7: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add README.md CONTEXT.md .agents skills/engineering docs/engineering/setup-osxsystem-skills.md docs/engineering/triage.md
git commit -m "docs: sweep plain setup-matt-pocock-skills references to new name"
```

---

### Task 3: Re-point the 8 aihero.dev cross-links

**Files:**
- Modify: `docs/engineering/ask-matt.md:23`
- Modify: `docs/engineering/code-review.md:33`
- Modify: `docs/engineering/implement.md:29`
- Modify: `docs/engineering/to-spec.md:22`
- Modify: `docs/engineering/to-tickets.md:23`
- Modify: `docs/engineering/triage.md:23`
- Modify: `docs/engineering/wayfinder.md:25`
- Modify: `docs/engineering/wizard.md:98`

**Interfaces:**
- Consumes: `skills/engineering/setup-osxsystem-skills/SKILL.md` from Task 1 — the link target. If Task 1 has not run, every link written here is dead.

Each line holds the old name **twice**, and the two halves need different treatment: the link text is a rename, the URL is a change of form. `https://aihero.dev/skills-setup-osxsystem-skills` would be a 404 — the fork does not publish to that site. Replace the whole link with a repo-relative path.

- [ ] **Step 1: Write the failing check**

Save as `/tmp/check-task3.sh`:

```bash
#!/usr/bin/env bash
# Fails if any docs/engineering page still links the setup skill to aihero.dev,
# or if a rewritten relative link does not resolve to a real file.
set -uo pipefail
cd /Users/hugues_mini/Codes/skills
fail=0

n=$(grep -ro 'skills-setup-matt-pocock-skills' docs/engineering/ | wc -l | tr -d ' ')
[ "$n" = "0" ] || { echo "FAIL: $n aihero URL(s) for the setup skill remain"; fail=1; }

n=$(grep -ro 'setup-matt-pocock-skills' docs/engineering/ | wc -l | tr -d ' ')
[ "$n" = "0" ] || { echo "FAIL: $n old-name occurrence(s) remain in docs/engineering"; fail=1; }

EXPECTED='[setup-osxsystem-skills](../../skills/engineering/setup-osxsystem-skills/SKILL.md)'
for f in ask-matt code-review implement to-spec to-tickets triage wayfinder wizard; do
  grep -qF "$EXPECTED" "docs/engineering/$f.md" \
    || { echo "FAIL: docs/engineering/$f.md missing the relative link"; fail=1; }
done

# The relative path must resolve from docs/engineering/.
[ -f docs/engineering/../../skills/engineering/setup-osxsystem-skills/SKILL.md ] \
  || { echo "FAIL: relative link target does not resolve"; fail=1; }

# Other skills' aihero links must survive — only the setup skill's 8 change.
# docs/engineering/ held 216 such links before this task; 216 - 8 = 208.
n=$(grep -ro 'https://aihero.dev/skills-' docs/engineering/ | wc -l | tr -d ' ')
[ "$n" = "208" ] || { echo "FAIL: $n aihero links left, expected exactly 208 — over- or under-broad edit"; fail=1; }

[ $fail -eq 0 ] && echo "PASS"
exit $fail
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task3.sh`
Expected: FAIL for 8 remaining aihero URLs, 16 remaining old-name occurrences, and all 8 missing-link lines. Exit code 1.

- [ ] **Step 3: Rewrite the 8 links**

```bash
cd /Users/hugues_mini/Codes/skills
perl -pi -e 's{\[setup-matt-pocock-skills\]\(https://aihero\.dev/skills-setup-matt-pocock-skills\)}{[setup-osxsystem-skills](../../skills/engineering/setup-osxsystem-skills/SKILL.md)}g' \
  docs/engineering/ask-matt.md \
  docs/engineering/code-review.md \
  docs/engineering/implement.md \
  docs/engineering/to-spec.md \
  docs/engineering/to-tickets.md \
  docs/engineering/triage.md \
  docs/engineering/wayfinder.md \
  docs/engineering/wizard.md
```

The pattern matches the complete `[text](url)` construct, so it cannot half-edit a line. `{}` delimiters avoid escaping the slashes in the URL and path.

- [ ] **Step 4: Run the check to verify it passes**

Run: `bash /tmp/check-task3.sh`
Expected: `PASS`, exit code 0.

- [ ] **Step 5: Confirm neighbouring links survived**

The edited sentences also link *other* skills to aihero.dev. Those must be intact.

Run: `grep -n 'aihero.dev/skills-' docs/engineering/wizard.md`
Expected: `wizard.md:98` still carries `skills-implement` and `skills-ask-matt`, alongside the new relative link to the setup skill.

- [ ] **Step 6: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add docs/engineering
git commit -m "docs: point setup skill cross-links at the in-repo SKILL.md"
```

---

### Task 4: Fix the self-contradicting line in CUSTOMIZING.md

**Files:**
- Modify: `CUSTOMIZING.md:53`

**Interfaces:**
- Consumes: nothing. Independent of Tasks 1–3.

Task 2 already swept this file's single occurrence, which turned the line into a claim that is now false. `setup-osxsystem-skills` is this fork's own skill; calling it upstream-author-specific contradicts the rename that just happened.

- [ ] **Step 1: Write the failing check**

Save as `/tmp/check-task4.sh`:

```bash
#!/usr/bin/env bash
# Fails if CUSTOMIZING.md still calls the renamed setup skill upstream-specific.
set -uo pipefail
cd /Users/hugues_mini/Codes/skills
fail=0

grep -n 'upstream-author-specific' CUSTOMIZING.md | grep -q 'setup-osxsystem-skills' \
  && { echo "FAIL: setup-osxsystem-skills still described as upstream-author-specific"; fail=1; }

grep -q 'e.g. `ask-matt` is upstream-author-specific' CUSTOMIZING.md \
  || { echo "FAIL: replacement wording not present"; fail=1; }

grep -q 'Prune skills the team won.t use' CUSTOMIZING.md \
  || { echo "FAIL: the prune step was removed entirely — it should stay"; fail=1; }

[ $fail -eq 0 ] && echo "PASS"
exit $fail
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task4.sh`
Expected: FAIL on the contradiction and on the missing replacement wording. Exit code 1.

- [ ] **Step 3: Reword line 53**

```diff
-4. **Prune skills the team won't use** (e.g. `ask-matt`, `setup-osxsystem-skills` are upstream-author-specific) into `deprecated/`.
+4. **Prune skills the team won't use** (e.g. `ask-matt` is upstream-author-specific) into `deprecated/`.
```

Note the singular verb: `are` becomes `is`, since one example remains.

- [ ] **Step 4: Run the check to verify it passes**

Run: `bash /tmp/check-task4.sh`
Expected: `PASS`, exit code 0.

- [ ] **Step 5: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add CUSTOMIZING.md
git commit -m "docs: drop renamed setup skill from the upstream-specific prune example"
```

---

### Task 5: Re-point package.json and delete the dead plugin script

**Files:**
- Modify: `package.json`
- Delete: `scripts/sync-plugin-version.mjs`

**Interfaces:**
- Consumes: nothing. Fully independent of Tasks 1–4 — it fixes a separate, pre-existing breakage.
- Produces: a working `npm run version`, which `.github/workflows/release.yml:32` invokes.

`scripts/sync-plugin-version.mjs` copies `package.json`'s version into `.claude-plugin/plugin.json`. This fork deleted that directory on purpose, so the script throws `ENOENT` at its `readFileSync` before any logic runs — and because the release workflow calls it through `npm run version`, the workflow fails on every push to `main`.

- [ ] **Step 1: Write the failing check**

Save as `/tmp/check-task5.sh`:

```bash
#!/usr/bin/env bash
# Fails if package.json still carries upstream identity, if the dead script
# survives, or if package.json stops being valid JSON.
set -uo pipefail
cd /Users/hugues_mini/Codes/skills
fail=0

node -e 'JSON.parse(require("fs").readFileSync("package.json","utf8"))' 2>/dev/null \
  || { echo "FAIL: package.json is not valid JSON"; fail=1; }

check() { # key, expected
  got=$(node -p "JSON.parse(require('fs').readFileSync('package.json','utf8'))$1 ?? 'MISSING'" 2>/dev/null)
  [ "$got" = "$2" ] || { echo "FAIL: $1 is '$got', expected '$2'"; fail=1; }
}
check '.name' 'osxsystem-skills'
check '.description' 'osxsystem team agent skills for real engineering — Kotlin Multiplatform + Compose Multiplatform'
check '.repository.url' 'https://github.com/osxsystem/skills'
check '.version' '1.2.2'
check '.private' 'true'
check '.scripts.version' 'changeset version'
check '.scripts["check-plugin-version"]' 'MISSING'

[ -f scripts/sync-plugin-version.mjs ] && { echo "FAIL: dead script still present"; fail=1; }

# Nothing may still reference the deleted script.
n=$(grep -rl 'sync-plugin-version' . --exclude-dir=.git --exclude-dir=node_modules \
      | grep -v -e superpowers -e CHANGELOG | wc -l | tr -d ' ')
[ "$n" = "0" ] || { echo "FAIL: $n live file(s) still reference sync-plugin-version"; fail=1; }

[ $fail -eq 0 ] && echo "PASS"
exit $fail
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task5.sh`
Expected: FAIL on `.name`, `.description`, `.repository.url`, `.scripts.version`, `.scripts["check-plugin-version"]`, the surviving script, and one live reference. Exit code 1.

- [ ] **Step 3: Edit package.json**

```diff
 {
-  "name": "mattpocock-skills",
+  "name": "osxsystem-skills",
   "version": "1.2.2",
   "private": true,
-  "description": "Matt Pocock's agent skills for real engineering",
+  "description": "osxsystem team agent skills for real engineering — Kotlin Multiplatform + Compose Multiplatform",
   "repository": {
     "type": "git",
-    "url": "https://github.com/mattpocock/skills"
+    "url": "https://github.com/osxsystem/skills"
   },
   "license": "MIT",
   "scripts": {
     "changeset": "changeset",
-    "version": "changeset version && node scripts/sync-plugin-version.mjs",
-    "check-plugin-version": "node scripts/sync-plugin-version.mjs --check"
+    "version": "changeset version"
   },
```

The em dash in the description is U+2014, matching the repo's prose style. Leave `license`, `devDependencies`, and `packageManager` untouched.

- [ ] **Step 4: Delete the script**

```bash
cd /Users/hugues_mini/Codes/skills
git rm scripts/sync-plugin-version.mjs
```

- [ ] **Step 5: Run the check to verify it passes**

Run: `bash /tmp/check-task5.sh`
Expected: `PASS`, exit code 0.

- [ ] **Step 6: Confirm the remaining scripts still resolve**

Run: `npm run` (lists scripts without executing them)
Expected: `changeset` and `version` listed; no `check-plugin-version`.

Do **not** run `npm ci` or `npm install` to test this — `package-lock.json` is deleted in the working tree by prior decision, and `npm install` would recreate it, staging a file that is explicitly out of scope.

- [ ] **Step 7: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add package.json scripts/sync-plugin-version.mjs
git commit -m "chore: point package.json at the fork, drop dead plugin-version script"
```

---

### Task 6: Whole-repo verification and release note

**Files:**
- Create: `.changeset/rename-setup-skill.md`

**Interfaces:**
- Consumes: every preceding task. This is the gate that proves the rename is complete and history is intact.

- [ ] **Step 1: Write the failing check**

Save as `/tmp/check-final.sh`:

```bash
#!/usr/bin/env bash
# The whole-repo gate: live files clean, history preserved, links resolve.
set -uo pipefail
cd /Users/hugues_mini/Codes/skills
fail=0

# 1. No live file may carry the old name. Four deliberate exclusions:
#    - CHANGELOG.md and .out-of-scope/  : upstream release history + rejected ideas
#    - docs/superpowers/                : the dated spec and plan for this rename
#    - .changeset/rename-setup-skill.md : the release note, which must name the
#      old command to tell users what to remove. Excluded by exact path, so any
#      *other* changeset carrying a stale reference is still caught.
#    Matched as a substring, not an exact path: this repo aliases grep to ugrep,
#    which strips the leading "./" that GNU and BSD grep emit. An -Fx exact match
#    would silently stop working on a teammate's machine.
live=$(grep -rl 'setup-matt-pocock-skills' . --exclude-dir=.git --exclude-dir=node_modules \
        | grep -v -e CHANGELOG -e out-of-scope -e superpowers \
        | grep -v 'changeset/rename-setup-skill\.md')
[ -z "$live" ] && echo "ok: no live references" \
  || { echo "FAIL: live references remain:"; echo "$live"; fail=1; }

# 2. History must be untouched: exactly 19 occurrences across the 5 files.
n=$(grep -ro 'setup-matt-pocock-skills' \
      CHANGELOG.md \
      .out-of-scope/ \
      docs/superpowers/plans/2026-08-06-fork-installation-customization.md \
      docs/superpowers/specs/2026-08-06-fork-installation-customization-design.md \
      | wc -l | tr -d ' ')
[ "$n" = "19" ] && echo "ok: history intact (19)" \
  || { echo "FAIL: history has $n occurrences, expected 19"; fail=1; }

# 3. The out-of-scope deletions must not have been staged.
git diff --cached --name-only | grep -qE '^(LICENSE|package-lock\.json)$' \
  && { echo "FAIL: LICENSE or package-lock.json was staged"; fail=1; } \
  || echo "ok: out-of-scope files not staged"

# 4. link-skills.sh untouched.
git diff HEAD --name-only | grep -q 'scripts/link-skills.sh' \
  && { echo "FAIL: link-skills.sh was modified"; fail=1; } \
  || echo "ok: link-skills.sh untouched"

# 5. Every relative link to the renamed skill resolves to a real file.
#    Scoped to the files Tasks 2-3 actually edited. Do NOT widen this to all
#    *.md: docs/superpowers/ holds the spec and plan, whose illustrative link
#    snippets are prose examples, not live links, and would false-positive.
missing=0
while IFS= read -r line; do
  f="${line%%:*}"; rest="${line#*:}"
  for p in $(echo "$rest" | grep -o '(\.\{1,2\}/[^)]*\.md)' | tr -d '()'); do
    [ -f "$(dirname "$f")/$p" ] || { echo "FAIL: broken link in $f -> $p"; missing=1; }
  done
done < <(grep -n 'setup-osxsystem-skills' \
           README.md skills/engineering/README.md docs/engineering/*.md \
           /dev/null | grep -o '^[^:]*:[0-9]*:.*(\.\{1,2\}/[^)]*)')
[ $missing -eq 0 ] && echo "ok: relative links resolve" || fail=1

# 6. The installation story is coherent end to end.
grep -q '### 2. Run `/setup-osxsystem-skills`' README.md \
  && echo "ok: README step 2" || { echo "FAIL: README step 2 wrong"; fail=1; }
[ "$(grep -m1 '^name:' skills/engineering/setup-osxsystem-skills/SKILL.md)" \
   = "name: setup-osxsystem-skills" ] \
  && echo "ok: frontmatter matches dir" || { echo "FAIL: frontmatter mismatch"; fail=1; }

echo "---"
[ $fail -eq 0 ] && echo "ALL PASS" || echo "FAILURES PRESENT"
exit $fail
```

- [ ] **Step 2: Run it**

Run: `bash /tmp/check-final.sh`
Expected: `ALL PASS`, exit code 0. If any check fails, fix it in the task that owns it and re-run — do not patch around it here.

- [ ] **Step 3: Confirm the rename totals**

Run:
```bash
cd /Users/hugues_mini/Codes/skills
git diff HEAD~5 --stat | tail -1
```
Expected: roughly 23 files changed, consistent with 42 swapped occurrences plus the two moves and the script deletion.

Run: `git log --oneline -5`
Expected, newest first: the package.json commit, CUSTOMIZING, cross-links, mechanical sweep, and the rename.

- [ ] **Step 4: Verify the skill still resolves in a harness**

Run: `bash scripts/link-skills.sh`
Expected: output includes `linked setup-osxsystem-skills -> …/skills/engineering/setup-osxsystem-skills` for both `~/.claude/skills` and `~/.agents/skills`.

Run: `ls -la ~/.claude/skills/ | grep -i -e osxsystem -e matt`
Expected: a live symlink for `setup-osxsystem-skills`, and **no** entry for `setup-matt-pocock-skills`. (None existed before this work, verified during design — if one appears, it is stale and should be removed with the `rm` in Step 5.)

- [ ] **Step 5: Write the changeset**

Create `.changeset/rename-setup-skill.md` with exactly this content (the outer
fence below is four backticks so the inner `bash` block survives copy-paste —
the file itself starts at `---` and the inner block uses three backticks):

````markdown
---
"osxsystem-skills": patch
---

Rename `setup-matt-pocock-skills` to `setup-osxsystem-skills`.

The skill's behaviour is unchanged — only its name, directory, and docs page
move. Run `/setup-osxsystem-skills` instead of the old command.

**If you installed a previous version,** the old skill is still linked under its
old name and will surface a broken slash command. Remove it:

```bash
rm -f ~/.claude/skills/setup-matt-pocock-skills \
      ~/.agents/skills/setup-matt-pocock-skills
```

Also in this release: `package.json` now identifies this fork rather than
upstream, and `scripts/sync-plugin-version.mjs` is deleted. That script synced a
`.claude-plugin/plugin.json` this fork does not ship, and its failure was
breaking the release workflow.
````

The package name in the frontmatter must match `package.json`'s `name` field as
set in Task 5 (`osxsystem-skills`), or `changeset version` errors on an unknown
package.

This changeset mentions the old name twice, deliberately — a user cannot remove
a stale symlink they cannot name. `check-final.sh` excludes this one file by
exact path, so Step 7 still passes while any *other* stale reference, including
one in a different changeset, is still caught.

- [ ] **Step 6: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add .changeset/rename-setup-skill.md
git commit -m "chore: changeset for the setup skill rename"
```

- [ ] **Step 7: Final gate**

Run: `bash /tmp/check-final.sh && git status --short`
Expected: `ALL PASS`, and `git status --short` showing **only** ` D LICENSE` and ` D package-lock.json` — the two pre-existing, deliberately-unstaged deletions. Anything else means a file was missed.

---

## Out of scope — do not do these

Recorded so an implementer does not "helpfully" fix them:

- **Restoring `LICENSE` or `package-lock.json`.** Deleted by prior decision. Note that `.github/workflows/release.yml:27` runs `npm ci`, which requires the lockfile — if that deletion is committed, Release fails at the install step. This is a known, accepted consequence, independent of the rename.
- **Editing the 5 historical files.** Their 19 occurrences are load-bearing evidence that the check in Task 6 Step 1 is honest.
- **Modifying `scripts/link-skills.sh`** to prune stale symlinks. Forbidden by its own header; handled by the `rm` in the changeset instead.
- **Publishing the docs page to aihero.dev** or registering the new slug there. The fork does not publish; that is why Task 3 uses relative links.
