# `ask-matt` mobile routing — design

**Date:** 2026-08-06
**Status:** Approved
**Scope:** Three files — `skills/engineering/ask-matt/SKILL.md`, `docs/engineering/ask-matt.md`, and a new changeset. No skill behaviour changes; no other skill is touched.

## Problem

`skills/engineering/ask-matt/SKILL.md` is the hand-written router over every user-reachable skill in this repo. It has zero mentions of the four mobile skills, which have shipped in `skills/mobile/` since the fork added the bucket:

- `kmp-module-setup`
- `kmp-ios-integration`
- `compose-multiplatform-ui`
- `kmp-release-and-publish`

Everything else about the bucket is wired — the top-level `README.md` (lines 81–90), `skills/mobile/README.md`, and all four docs pages under `docs/mobile/`. Only the router was missed.

`CLAUDE.md` makes this a rule rather than a nicety: whenever a user-reachable skill is added, `ask-matt` must be re-synced, because "a new skill it never mentions, or a stale one it still routes to, is a router that lies."

All four mobile skills are **model-invoked** — no `disable-model-invocation`, no `policy` block in `agents/openai.yaml` — so the model can reach them autonomously and a human can type them. That makes them router-eligible on the same terms as `/domain-modeling` and `/codebase-design`.

## Decisions made

1. **A new top-level section, `## Platform knowledge`**, parallel to the existing `## Vocabulary underneath`. Rejected: appending to `## Standalone` (that section means "off the main flow entirely", which misdescribes skills used *during* implementation) and weaving mentions inline through the main flow (scatters them across the doc's densest prose).
2. **A flat list in lifecycle order, with the release skill's altitude flagged** — not a numbered 1–4 pipeline. The four are reached for on demand; numbering would imply an order the skills do not enforce. But `kmp-release-and-publish` genuinely sits at ship time rather than beneath the flow, and the prose says so.
3. **Discoverability comes from the opening map-shape sentence only** (line 11). The main flow's step 3 is left untouched — it is already the densest passage in the doc, and a reader meets the new layer in the opening paragraph before they start travelling.
4. **The docs page is re-synced in the same change**, because `CLAUDE.md` requires it when an `engineering/` skill's behaviour changes, and because that page independently enumerates the map's route kinds.
5. **A patch changeset ships with it**, so the routing fix appears in the next release notes.

## Changes by file

### 1. `skills/engineering/ask-matt/SKILL.md`

**Line 11 — the map-shape sentence.** It currently enumerates the map's shape and goes stale the moment a third layer exists.

Before:

> Everything else is standalone, or a vocabulary layer that runs underneath.

After:

> Everything else is standalone, or one of two layers that run underneath: **vocabulary**, and **platform knowledge**.

**New section**, inserted between `## Vocabulary underneath` and `## Phase boundaries`:

```markdown
## Platform knowledge

Four model-invoked references for when the codebase is **Kotlin Multiplatform /
Compose Multiplatform**. Like the vocabulary layer, they run *beneath* the flow
rather than as a step in it — `/implement` and `/tdd` pull them in as the work
demands. Reach for them directly when the **platform**, not the process, is what
you're stuck on.

- **`/kmp-module-setup`** — the shared module's *shape*: targets and the
  source-set hierarchy you get free from `androidTarget()` + `iosArm64()`, the
  version catalog that pins Kotlin, AGP and Compose Multiplatform together, the
  iOS framework block, and the `expect`/`actual` vs interfaces-plus-DI call.
- **`/kmp-ios-integration`** — the *Xcode seam*: direct integration vs CocoaPods
  vs SPM vs KMMBridge, `embedAndSignAppleFrameworkForXcode`, and the
  framework-not-found and script-sandboxing errors — plus a review checklist for
  the Kotlin API Swift has to consume (`@Throws`, sealed classes, suspend
  functions, generics).
- **`/compose-multiplatform-ui`** — *shared UI*: per-platform entry points,
  `composeResources`/`Res`, Navigation and ViewModel in `commonMain`,
  SwiftUI/UIKit interop both directions, and the iOS-only deltas (frame-rate
  caps, accessibility, `viewModel()` crashes).
- **`/kmp-release-and-publish`** — the odd one out: it runs at **ship time**, at
  the *end* of the flow rather than beneath it. R8 over shared code, iOS archive
  and TestFlight, Maven Central, and the CI runner split.
```

The opening sentence deliberately echoes the `## Vocabulary underneath` opener ("Two model-invoked references that run *beneath* the other skills") so the reader recognises the shape as a layer, not a phase.

### 2. `docs/engineering/ask-matt.md`

In the **"Flows, not skills"** section:

- `Four kinds of route exist` → `Five kinds of route exist`
- Add a fifth bullet, after the vocabulary-layer bullet:

> - **A platform-knowledge layer underneath**, four Kotlin Multiplatform / Compose Multiplatform references the implementation skills pull in when the platform rather than the process is the problem. One of them, release-and-publish, sits at ship time instead.

### 3. `.changeset/ask-matt-mobile-routing.md` — new

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

## Success criteria

1. All four mobile skill names appear in `skills/engineering/ask-matt/SKILL.md`.
2. Line 11 names both underneath-layers; no sentence in the file still claims there is exactly one.
3. `docs/engineering/ask-matt.md` says five kinds of route and describes the platform layer.
4. The changeset exists, is valid changeset frontmatter, and names the `osxsystem-skills` package.
5. Every one of the four skill names in the new section matches its directory name under `skills/mobile/` exactly.
6. No file outside those three is modified.

## Out of scope — do not do these

- **The docs page's dead plugin references.** `docs/engineering/ask-matt.md` tells readers to check `.claude-plugin/plugin.json`, which this fork deleted, and cites "the plugin's twenty-two skills". Both are wrong and both are pre-existing fork debt unrelated to mobile routing. Flagged, deliberately not fixed here.
- **Touching the main flow's step 3**, or any other section of `SKILL.md`.
- **`skills/mobile/README.md`, the top-level `README.md`, and `docs/mobile/`** — already correct.
- **Changing any mobile skill's frontmatter or invocation mode.** They stay model-invoked.
- **The other loose ends noted alongside this work**: the unticked checkboxes in `docs/superpowers/plans/2026-08-06-rename-setup-skill.md`, the merged `rename-setup-osxsystem-skills` branch, and the pending release that would consume the existing changesets.
