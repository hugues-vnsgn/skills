# Customizing skills in this fork

How to change, extend, or add skills in this repo. Companion to [MAINTENANCE.md](./MAINTENANCE.md) (upstream sync, refresh cadence) and the [writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md) skill (the writing discipline itself).

## 1. What a skill is in this repo

Each skill is a folder `skills/<bucket>/<name>/` containing:

- **`SKILL.md`** — the file the agent loads when the skill fires. YAML frontmatter with exactly two required fields: `name` and `description`.
- **Reference files** (optional, e.g. `reference.md`, `tests.md`) — heavy detail the agent opens only when needed. The mobile skills use this: SKILL.md is a ~60-line distillation, and the full research sits beside it.

The single most important line is the **`description`**. It is the *pointer* the agent reads on every turn to decide whether to load the skill, so it must contain **only triggering conditions** — symptoms, error messages, situations — never a summary of the workflow.

- ✅ `Use when Xcode builds but the Kotlin framework never updates…`
- ❌ `Runs a checklist that…` — agents follow the summary and skip the body.

## 2. The layers a change must touch

The repo distinguishes **promoted** buckets (`engineering/`, `productivity/`, `mobile/`) from parked ones (`misc/`, `in-progress/`, `deprecated/`). A promoted skill is registered in three places besides the skill itself, and edits ripple to all of them:

| Layer | File |
|---|---|
| The skill itself | `skills/<bucket>/<name>/SKILL.md` (+ reference files) |
| Bucket index | `skills/<bucket>/README.md` |
| Repo index | top-level `README.md` |
| Human docs page | `docs/<bucket>/<name>.md` |

## 3. The customization loop

For each skill you want to change:

1. **Classify the change.** Three kinds, cheapest first:
   - *Append* a section to an upstream skill (like the "Kotlin Multiplatform projects" section in `tdd`) — append-only edits merge cleanly when syncing upstream.
   - *Rewrite or create* a skill (the four `mobile/` skills).
   - *Demote or remove* — move to `deprecated/`, deregister from the three layers.
2. **Write with the body/pointer split.** Steps and decision tables the agent needs every time go in SKILL.md; anything only some paths need goes to a reference file behind a pointer ("Full detail: [reference.md]"). State rules positively ("write `@Throws` on throwing API") rather than as prohibitions, and prune anything the agent would do by default anyway.
3. **Verify before shipping.** Dispatch a subagent that may read *only* the skill folder, give it 4–5 realistic task questions you know the answers to, and treat any gap or ambiguity in its answers as the bug to fix. For discipline-style skills — ones that must hold under pressure, like `tdd` — the stronger test is a pressure scenario: give a subagent a tempting shortcut and see if the skill stops it.
4. **Register** (the three layers), then commit and push.

## 4. Fork hygiene

- Keep edits to upstream files **append-only** where possible — upstream syncs then resolve as "keep both" (see [MAINTENANCE.md](./MAINTENANCE.md) for the sync commands).
- Date anything fact-heavy. The mobile skills encode moving targets (Kotlin/CMP versions, Swift Export status, Central Portal flow); refresh at each Kotlin language release.
- One meaning, one place: if a fact lives in `kmp-module-setup`, other skills point to it rather than restating it — restated copies drift.

## 5. Customization roadmap

Directions worth taking, roughly by leverage:

1. **Tailor the mobile skills to the actual project** — bake in real module names (`shared`, `androidApp`, `iosApp`), the chosen iOS integration route (direct vs CocoaPods), the real version catalog.
2. **Customize `code-review`** with KMP standards — the Swift-facing API checklist from `kmp-ios-integration` as a review axis.
3. **Customize `implement` / `to-tickets`** so tracer-bullet slices respect the platform dimension (common-first, then per-platform actuals).
4. **Prune skills the team won't use** (e.g. `ask-matt` is upstream-author-specific) into `deprecated/`.
