# `ask-matt` Mobile Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `ask-matt` route to the four mobile skills by adding a **Platform knowledge** layer to the router, re-syncing its docs page, and shipping a changeset.

**Architecture:** Three files, three tasks, no code. The router gains a new top-level section parallel to the existing `## Vocabulary underneath`, and its opening map-shape sentence is corrected to name two underneath-layers instead of one. The docs page's route-kind list grows from four to five. A patch changeset records the fix.

**Tech Stack:** Markdown only. Verification is bash + `grep`. No test runner, no build step.

## Global Constraints

- **`grep` on this machine is ugrep 7.5.0**, not GNU or BSD grep. It strips the leading `./` that other greps emit from `grep -r` output. Checks below match paths as substrings and never use `-Fx` exact-path matching, so they keep working on a teammate's machine.
- **Verification scripts live in `/tmp`, never in the repo.** Nothing this plan creates may be committed except the three deliverable files.
- **Exactly three files may change**: `skills/engineering/ask-matt/SKILL.md`, `docs/engineering/ask-matt.md`, `.changeset/ask-matt-mobile-routing.md`. Any other modified file is a plan failure.
- **The spec's out-of-scope list is binding.** In particular, `docs/engineering/ask-matt.md`'s dead `.claude-plugin/plugin.json` reference and its "twenty-two skills" count **must survive untouched**. Task 2's check asserts this.
- **The four skill names are fixed and must match their directories under `skills/mobile/` exactly**: `kmp-module-setup`, `kmp-ios-integration`, `compose-multiplatform-ui`, `kmp-release-and-publish`.
- **Baseline commit is `d990652`** ("docs: spec for routing the mobile bucket into ask-matt") — the commit immediately before implementation. Task 3's gate diffs against it.

## File Structure

| File | Responsibility | Task |
| --- | --- | --- |
| `skills/engineering/ask-matt/SKILL.md` | The router itself — the map an agent reads | 1 |
| `docs/engineering/ask-matt.md` | The human-facing published page describing that map | 2 |
| `.changeset/ask-matt-mobile-routing.md` | Release note | 3 |

Tasks 1 and 2 are split because a reviewer could reasonably accept the router wording while rejecting the docs-page phrasing, and vice versa. Task 3 is separate because the changeset describes both, and it carries the whole-repo gate.

---

### Task 1: Add the Platform knowledge layer to the router

**Files:**
- Modify: `skills/engineering/ask-matt/SKILL.md:11` (the map-shape sentence)
- Modify: `skills/engineering/ask-matt/SKILL.md` (new section inserted between line 59 and line 61)
- Test: `/tmp/check-task1.sh`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: the exact heading string `## Platform knowledge` and the four `/skill-name` mentions that Task 2's bullet describes in prose and Task 3's changeset names.

- [ ] **Step 1: Write the failing check**

Create `/tmp/check-task1.sh`:

```bash
#!/usr/bin/env bash
# Fails unless the router carries a Platform knowledge layer, positioned
# between the vocabulary layer and the phase boundaries, naming all four
# mobile skills — and unless line 11 admits there are now two layers.
set -u
F="skills/engineering/ask-matt/SKILL.md"
fail=0
note() { echo "FAIL: $1"; fail=1; }

# 1. The section exists.
grep -q '^## Platform knowledge$' "$F" || note "no '## Platform knowledge' heading"

# 2. It sits between Vocabulary underneath and Phase boundaries.
vocab=$(grep -n '^## Vocabulary underneath$' "$F" | cut -d: -f1)
plat=$(grep -n '^## Platform knowledge$' "$F" | cut -d: -f1)
phase=$(grep -n '^## Phase boundaries$' "$F" | cut -d: -f1)
if [ -z "$plat" ] || [ -z "$vocab" ] || [ -z "$phase" ]; then
  note "could not locate all three headings (vocab=$vocab plat=$plat phase=$phase)"
elif [ "$vocab" -ge "$plat" ] || [ "$plat" -ge "$phase" ]; then
  note "section misplaced: vocab=$vocab plat=$plat phase=$phase (want vocab < plat < phase)"
fi

# 3. All four skills are named, and each name is a real directory.
#    bt holds a literal backtick: the router writes skills as `/name`, and
#    anchoring on the closing backtick stops /kmp-module-setup matching a
#    longer name that merely starts the same way.
bt='`'
for s in kmp-module-setup kmp-ios-integration compose-multiplatform-ui kmp-release-and-publish; do
  [ -d "skills/mobile/$s" ] || note "skills/mobile/$s does not exist"
  grep -q "/$s$bt" "$F" || note "router never mentions /$s"
done

# 4. Line 11 no longer claims a single underneath-layer.
grep -q 'or a vocabulary layer that runs underneath' "$F" && \
  note "line 11 still claims one underneath-layer"
grep -q 'two layers that run underneath' "$F" || \
  note "line 11 does not name two underneath-layers"

# 5. The release skill's odd altitude is flagged, per the spec's decision 2.
grep -q 'ship time' "$F" || note "release skill's ship-time altitude not flagged"

[ "$fail" -eq 0 ] && echo "PASS: task 1"
exit "$fail"
```

Then: `chmod +x /tmp/check-task1.sh`

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task1.sh`

Expected: several `FAIL:` lines, including `no '## Platform knowledge' heading` and `line 11 still claims one underneath-layer`. Exit code 1.

- [ ] **Step 3: Fix the map-shape sentence on line 11**

In `skills/engineering/ask-matt/SKILL.md`, replace exactly:

```
A **flow** is a path through the skills. Most paths run along one **main flow**, and two **on-ramps** merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath.
```

with:

```
A **flow** is a path through the skills. Most paths run along one **main flow**, and two **on-ramps** merge onto it. Everything else is standalone, or one of two layers that run underneath: **vocabulary**, and **platform knowledge**.
```

- [ ] **Step 4: Insert the new section**

The file currently reads, at lines 59–61:

```
- **`/codebase-design`** — the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's *shape*: a lot of behaviour behind a small interface at a clean seam. `/tdd` and `/improve-codebase-architecture` both speak it.

## Phase boundaries
```

Replace that with:

```
- **`/codebase-design`** — the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's *shape*: a lot of behaviour behind a small interface at a clean seam. `/tdd` and `/improve-codebase-architecture` both speak it.

## Platform knowledge

Four model-invoked references for when the codebase is **Kotlin Multiplatform / Compose Multiplatform**. Like the vocabulary layer, they run *beneath* the flow rather than as a step in it — `/implement` and `/tdd` pull them in as the work demands. Reach for them directly when the **platform**, not the process, is what you're stuck on.

- **`/kmp-module-setup`** — the shared module's *shape*: targets and the source-set hierarchy you get free from `androidTarget()` + `iosArm64()`, the version catalog that pins Kotlin, AGP and Compose Multiplatform together, the iOS framework block, and the `expect`/`actual` vs interfaces-plus-DI call.
- **`/kmp-ios-integration`** — the *Xcode seam*: direct integration vs CocoaPods vs SPM vs KMMBridge, `embedAndSignAppleFrameworkForXcode`, and the framework-not-found and script-sandboxing errors — plus a review checklist for the Kotlin API Swift has to consume (`@Throws`, sealed classes, suspend functions, generics).
- **`/compose-multiplatform-ui`** — *shared UI*: per-platform entry points, `composeResources`/`Res`, Navigation and ViewModel in `commonMain`, SwiftUI/UIKit interop both directions, and the iOS-only deltas (frame-rate caps, accessibility, `viewModel()` crashes).
- **`/kmp-release-and-publish`** — the odd one out: it runs at **ship time**, at the *end* of the flow rather than beneath it. R8 over shared code, iOS archive and TestFlight, Maven Central, and the CI runner split.

## Phase boundaries
```

- [ ] **Step 5: Run the check to verify it passes**

Run: `bash /tmp/check-task1.sh`

Expected: `PASS: task 1`, exit code 0.

- [ ] **Step 6: Confirm nothing else in the file moved**

Run: `git diff --stat skills/engineering/ask-matt/SKILL.md`

Expected: one file changed, roughly `12 insertions(+), 1 deletion(-)` — the 10-line section plus its surrounding blank line, and the one-line replacement on line 11. If deletions exceed 1, something was clobbered; inspect `git diff` before continuing.

- [ ] **Step 7: Commit**

```bash
git add skills/engineering/ask-matt/SKILL.md
git commit -m "feat: route ask-matt to the mobile bucket

Adds a Platform knowledge layer naming the four Kotlin Multiplatform /
Compose Multiplatform skills, and corrects the map-shape sentence to name
both underneath-layers."
```

---

### Task 2: Re-sync the docs page

**Files:**
- Modify: `docs/engineering/ask-matt.md:27` (the route count)
- Modify: `docs/engineering/ask-matt.md:32` (add a fifth bullet after it)
- Test: `/tmp/check-task2.sh`

**Interfaces:**
- Consumes: the `## Platform knowledge` layer created in Task 1 — this page describes it in prose but does not link to it.
- Produces: nothing later tasks depend on structurally; Task 3's gate counts this file among the three changed.

- [ ] **Step 1: Write the failing check**

Create `/tmp/check-task2.sh`:

```bash
#!/usr/bin/env bash
# Fails unless the docs page counts five route kinds and describes the
# platform layer — and unless the out-of-scope plugin debt survives intact.
set -u
F="docs/engineering/ask-matt.md"
fail=0
note() { echo "FAIL: $1"; fail=1; }

# 1. The count is updated.
grep -q 'Five kinds of route exist' "$F" || note "does not say 'Five kinds of route exist'"
grep -q 'Four kinds of route exist' "$F" && note "still says 'Four kinds of route exist'"

# 2. The new bullet is present and describes the layer.
grep -q 'platform-knowledge layer underneath' "$F" || note "no platform-knowledge bullet"
grep -q 'ship time' "$F" || note "bullet does not note the release skill's ship-time altitude"

# 3. The route list is exactly five bullets. The list runs from the
#    'Flows, not skills' paragraph to the next '## ' heading.
count=$(sed -n '/kinds of route exist/,/^## /p' "$F" | grep -c '^- \*\*')
[ "$count" -eq 5 ] || note "route list has $count bullets, want 5"

# 4. OUT OF SCOPE, per the spec: the fork's plugin debt must NOT be fixed here.
grep -q 'plugin.json' "$F" || note "plugin.json reference was removed — that is out of scope"
grep -q 'twenty-two' "$F" || note "the 'twenty-two skills' count was changed — that is out of scope"

[ "$fail" -eq 0 ] && echo "PASS: task 2"
exit "$fail"
```

Then: `chmod +x /tmp/check-task2.sh`

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task2.sh`

Expected: `FAIL: does not say 'Five kinds of route exist'`, `FAIL: still says 'Four kinds of route exist'`, `FAIL: no platform-knowledge bullet`, and `FAIL: route list has 4 bullets, want 5`. The two out-of-scope checks should already **pass** (that debt is untouched). Exit code 1.

- [ ] **Step 3: Update the route count on line 27**

Replace exactly:

```
Four kinds of route exist, and the skill itself carries them in full:
```

with:

```
Five kinds of route exist, and the skill itself carries them in full:
```

- [ ] **Step 4: Add the fifth bullet**

Replace exactly:

```
- **A vocabulary layer underneath**, the two references the other skills pull in when the words rather than the process are the problem.
```

with:

```
- **A vocabulary layer underneath**, the two references the other skills pull in when the words rather than the process are the problem.
- **A platform-knowledge layer underneath**, four Kotlin Multiplatform / Compose Multiplatform references the implementation skills pull in when the platform rather than the process is the problem. One of them, release-and-publish, sits at ship time instead.
```

- [ ] **Step 5: Run the check to verify it passes**

Run: `bash /tmp/check-task2.sh`

Expected: `PASS: task 2`, exit code 0.

- [ ] **Step 6: Commit**

```bash
git add docs/engineering/ask-matt.md
git commit -m "docs: ask-matt page counts five route kinds

The router gained a platform-knowledge layer; the published page described
a four-route map that no longer exists."
```

---

### Task 3: Changeset and whole-repo gate

**Files:**
- Create: `.changeset/ask-matt-mobile-routing.md`
- Test: `/tmp/check-task3.sh`

**Interfaces:**
- Consumes: the committed work of Tasks 1 and 2 — the gate diffs the whole range against baseline `d990652`.
- Produces: the final verified state. Nothing follows.

- [ ] **Step 1: Write the failing check**

Create `/tmp/check-task3.sh`:

```bash
#!/usr/bin/env bash
# The whole-repo gate: changeset valid, exactly three files touched since
# the spec commit, working tree clean, no stray scripts committed.
set -u
BASE="d990652"   # "docs: spec for routing the mobile bucket into ask-matt"
C=".changeset/ask-matt-mobile-routing.md"
fail=0
note() { echo "FAIL: $1"; fail=1; }

# 1. The changeset exists with valid frontmatter naming the package.
[ -f "$C" ] || note "$C missing"
if [ -f "$C" ]; then
  head -1 "$C" | grep -q '^---$' || note "changeset does not open with '---'"
  grep -q '"osxsystem-skills": patch' "$C" || note "changeset does not bump osxsystem-skills as patch"
  grep -q 'Platform knowledge' "$C" || note "changeset does not name the new layer"
fi

# 2. Exactly the three deliverable files changed since the spec commit.
#    docs/superpowers/ is filtered out: this plan file is itself committed
#    after $BASE, and the spec and plan are process artefacts, not
#    deliverables. Without the filter this check fails on its own paperwork.
changed=$(git diff --name-only "$BASE" HEAD | grep -v '^docs/superpowers/' | sort)
expected="$(printf '%s\n' \
  ".changeset/ask-matt-mobile-routing.md" \
  "docs/engineering/ask-matt.md" \
  "skills/engineering/ask-matt/SKILL.md" | sort)"
if [ "$changed" != "$expected" ]; then
  note "changed files do not match the three deliverables"
  echo "--- got ---"; echo "$changed"
  echo "--- want ---"; echo "$expected"
fi

# 3. No verification script leaked into the repo.
git ls-files | grep -q 'check-task' && note "a check-task script was committed"

# 4. Working tree clean.
[ -z "$(git status --porcelain)" ] || note "working tree is dirty"

# 5. Re-run both earlier gates so a later edit cannot silently regress them.
bash /tmp/check-task1.sh >/dev/null 2>&1 || note "task 1 check regressed"
bash /tmp/check-task2.sh >/dev/null 2>&1 || note "task 2 check regressed"

[ "$fail" -eq 0 ] && echo "PASS: task 3 — all gates green"
exit "$fail"
```

Then: `chmod +x /tmp/check-task3.sh`

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash /tmp/check-task3.sh`

Expected: `FAIL: .changeset/ask-matt-mobile-routing.md missing` and a changed-files mismatch (two files, not three). Exit code 1.

- [ ] **Step 3: Write the changeset**

Create `.changeset/ask-matt-mobile-routing.md` with exactly:

```markdown
---
"osxsystem-skills": patch
---

`ask-matt` now routes to the mobile bucket.

The router mapped every promoted skill except the four Kotlin Multiplatform /
Compose Multiplatform ones, which have shipped in `skills/mobile/` since the
fork added the bucket. They now appear as a **Platform knowledge** layer that
runs beneath the main flow, alongside the existing vocabulary layer.

No skill behaviour changes — this is the map catching up with the repo.
```

- [ ] **Step 4: Commit**

```bash
git add .changeset/ask-matt-mobile-routing.md
git commit -m "chore: changeset for ask-matt mobile routing"
```

- [ ] **Step 5: Run the gate to verify it passes**

Run: `bash /tmp/check-task3.sh`

Expected: `PASS: task 3 — all gates green`, exit code 0.

- [ ] **Step 6: Read the new section back in context**

Run: `sed -n '54,72p' skills/engineering/ask-matt/SKILL.md`

Expected: the vocabulary section, then the new `## Platform knowledge` section with its four bullets, then `## Phase boundaries`. Read it as a human would — the layer should read as a peer of the vocabulary layer, not as a phase of the main flow. A check can prove the strings are present; only reading proves the map is honest.

- [ ] **Step 7: Confirm the router now names every promoted skill**

```bash
bt='`'
for d in skills/engineering/*/ skills/productivity/*/ skills/mobile/*/; do
  s=$(basename "$d")
  [ "$s" = "ask-matt" ] && continue
  grep -q "/$s$bt" skills/engineering/ask-matt/SKILL.md || echo "UNROUTED: $s"
done
```

Expected: **no output at all.**

This was measured against the pre-change file on 2026-08-06: the only four names it printed were `compose-multiplatform-ui`, `kmp-ios-integration`, `kmp-module-setup`, and `kmp-release-and-publish`. Every other promoted skill was already routed, including `setup-osxsystem-skills` under `## Precondition`. So Task 1 closes the last gap, and a silent run here means the router names every promoted skill in the repo.

If a name *does* print, it is a routing gap that appeared after this plan was written — record it for a follow-up and do not widen scope.

---

## Out of scope — do not do these

- **Fixing the docs page's dead `.claude-plugin/plugin.json` reference or its "twenty-two skills" count.** Pre-existing fork debt, unrelated to mobile routing. Task 2's check actively asserts this debt survives.
- **Editing the main flow's step 3**, or any other section of `SKILL.md` beyond line 11 and the inserted section.
- **`skills/mobile/README.md`, the top-level `README.md`, `docs/mobile/`** — already correct.
- **Changing any mobile skill's frontmatter or invocation mode.** They stay model-invoked.
- **Ticking the unticked boxes in `docs/superpowers/plans/2026-08-06-rename-setup-skill.md`, deleting the merged `rename-setup-osxsystem-skills` branch, or cutting a release** to consume the pending changesets. All real, all separate.
