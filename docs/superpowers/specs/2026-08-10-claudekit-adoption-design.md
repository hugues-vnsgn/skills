# ClaudeKit adoption — design

**Date:** 2026-08-10
**Amended:** 2026-08-11 — a second pass over ClaudeKit's catalogue reached two skills this spec never examined (`xia`, `problem-solving`), re-affirmed the `ck-scenario` rejection after it was re-raised, and folded a mobile addendum into `security-review`. Amendments are marked **[2026-08-11]**.
**Status:** Proposed. Plan 1 of 5 (validation infra) shipped in PR #5; plan 5 of 5 (second-pass adoptions) shipped 2026-08-11; plans 2–4 pending.
**Scope:** This repo (`osxsystem/skills`) only. Adds two maintainer scripts, one CI workflow, one appended section to an existing skill, six new promoted skills, one beta skill, and a preflight step in one mobile skill. Nothing outside the repo is touched; no upstream skill is rewritten.

## Goal

Absorb the mechanisms worth having from [`claudekit-engineer`](https://github.com/claudekit/claudekit-engineer) — a ClaudeKit project template whose value lives in a `.claude/` runtime (83 skills, 16 hook scripts, 13 named agents, 5 validator scripts) — into this fork **without** importing its runtime. Two things come out of it: enforcement for the invariants our prose already states, and six skills that fill genuine gaps in the flow `ask-matt` maps, plus one beta skill outside it.

The comparison that produced this list, including the mechanisms deliberately rejected, is recorded in [Adjudication record](#adjudication-record) below. Rejections are decisions: they exist so a future maintainer reading ClaudeKit doesn't re-litigate them.

## The shape of the difference

Both repos ship agent skills; they are not the same kind of artifact.

| | this fork | claudekit-engineer |
|---|---|---|
| Unit shipped | 41 portable skills, installed as files you own | a whole `.claude/` runtime, scaffolded into a project |
| `SKILL.md` volume | 2,640 lines (~68 avg) | 15,314 lines (~185 avg) |
| Support files | 76 | 1,213 |
| Enforcement | prose discipline | 16 hook scripts (2,370 LOC) wired into `settings.json` |
| Routing | one router skill (`ask-matt`), read by the human | two rule files auto-loaded by `CLAUDE.md`, read by the agent |
| Frontmatter | `name`, `description` | ~8 fields (`category`, `keywords`, `argument-hint`, `metadata.version`, …) |
| Invocation axis | user-invoked vs model-invoked, enforced in both harnesses | absent — everything model-reachable |
| Validation | none in-tree | 5 validator scripts in-tree |

This fork is a **library of disciplines**; ClaudeKit is an **opinionated factory**. That difference is why most of its catalogue is not portable here: ~40 of its skills are domain reference dumps (Shopify, Three.js, shaders, payments), and its best enforcement lives in Claude-Code-only hooks. What travels is process machinery and gap-filling flow skills.

## Decisions made

1. **No hook runtime, and no hook ports.** All five candidate hooks were rejected on inspection (see [Adjudication record](#adjudication-record)). The one genuine enforcer, `simplify-gate`, misfires on Kotlin Multiplatform work: its verb regex hard-blocks "deploy to my phone" (a device-testing action), and a legitimate release diff — version bumps, changelog, per-platform artifact metadata — exceeds its 400-LOC / 8-file threshold, blocking the very publish `kmp-release-and-publish` exists to run. Dirty-tree enforcement belongs in that skill's own preflight instead (decision 7).
2. **Adopt the confusable-pair check, drop the rest of the scorer.** ClaudeKit's `score-skill-description.py` weights five criteria and requires a `Use for/when` trigger phrase. That requirement contradicts [`.agents/invocation.md`](../../../.agents/invocation.md): our 21 user-invoked skills carry human-facing one-line summaries by design, so the rubric would fail them for obeying house style. The Jaccard confusable-pair detector is the transferable half. Its dependency-cycle detector has nothing to validate — no skill here uses a `requires:` field, and cross-skill deps are discouraged.
3. **The confusable check runs over model-invoked pairs only, at threshold 0.80, with no allowlist.** Measured against all 39 real descriptions before deciding (20 user-invoked, 19 model-invoked): the highest model-invoked pair is `tdd` ↔ `migrate-to-shoehorn` at **0.185**, and 0.80 flags nothing at all. The `kmp-*` quartet peaks at 0.125. The single highest pair in the whole repo, `grill-with-docs` ↔ `grill-me` at 0.417, is excluded from the check entirely — both are user-invoked, so neither carries a model-facing trigger description to collide on; the router `ask-matt` is what disambiguates them for a human. A family allowlist was designed and then cut as unnecessary. The check is a **tripwire for future drift**, not a cleanup tool for today.
4. **Promote the existing validator rather than port ClaudeKit's.** This repo already has a 476-assertion harness — written for a one-off audit and left untracked in `isolated_test_workspace/harness/`. It enforces our own `CLAUDE.md` invariants (bucket-README membership and grouping, docs-page four-section template, invocation-mode consistency across `SKILL.md` and `agents/openai.yaml`, link resolution, `ask-matt` routing freshness and stale routes, install-block verbatim, no `.claude-plugin/`). ClaudeKit's validators check a disjoint invariant set (its own `category`/`keywords` schema, `/ck:` reference graphs) — nothing to take. **Verified: 476/476 pass against the live repo today**, so CI starts green.
5. **The subagent return protocol is an appended section, not a skill.** ClaudeKit's four-status contract (`DONE` / `DONE_WITH_CONCERNS` / `BLOCKED` / `NEEDS_CONTEXT`) plus its controller-handling rules are genuinely new here; the surrounding material (context isolation, prompt templates, parallel-vs-sequential guidance) restates what `writing-for-agents` already covers. It has no distinct trigger word and no skill would invoke it by name, so it earns no registration cost.
6. **Six new promoted skills**, each filling a phase no current skill covers: `ship`, `security-review`, `journal`, `using-worktrees`, `retrospective`, and — **[2026-08-11]** — `port-from-repo`. Placement and invocation in [New skills](#new-skills).
7. **`kmp-release-and-publish` gains a preflight step** — refuse to publish from a dirty tree — which is where decision 1 relocates the only hook worth its enforcement.
8. **`ask-matt` is re-synced once**, at the end, covering all six promoted skills in one edit. `CLAUDE.md` requires the router to stay accurate; separate syncs would restate one meaning six times. The beta skill `when-stuck` is deliberately absent from the router: `in-progress/` skills are excluded from the top-level `README.md` and from `ask-matt` by the same rule, and the harness enforces it (`ask-matt-mentions-skill` and `bucket-readme-grouping` are gated on promoted buckets; `readme-membership` inverts and *fails* a non-promoted skill that appears in the top-level README).
9. **[2026-08-11] Re-author from the pattern; never copy the prose.** `claudekit-engineer` ships **no `LICENSE` file, no `package.json`, and no git remote**, and its skill-level declarations are inconsistent — `ck-scenario` claims MIT while `xia`, `security-scan`, and `problem-solving` declare only `author: claudekit`. This repo is MIT (Matt Pocock, 2026) and publishes publicly through skills.sh, so lifting text out of an unlicensed tree into it is not clean. Patterns are not copyrightable; expression is. Every adoption is therefore written fresh in house style, and lineage is credited to the **actual originator** where ClaudeKit names one — Microsoft Amplifier for `problem-solving`, autoresearch (Udit Goenka, MIT) for the saturation idea — rather than to the distributor.
10. **[2026-08-11] Two further skills**, from a sweep of the catalogue this spec's first pass never reached: `port-from-repo` (promoted) and `when-stuck` (beta). Both were absent from the original adjudication record — verified by search, zero mentions of either source skill — so neither reverses a prior decision.
11. **[2026-08-11] The `ck-scenario` rejection stands.** It was re-raised on a narrower framing — a prioritisation aid feeding `tdd`'s seam agreement rather than exhaustive enumeration — and re-rejected. Reasoning in the [Adjudication record](#adjudication-record).

## Validation infrastructure

Two scripts and one workflow. Neither is a skill: they run for the maintainer and in CI, so they pay none of the registration cost a promoted skill does.

### `scripts/harness/` — the promoted validator

Move these from `isolated_test_workspace/harness/` (currently untracked) to `scripts/harness/`:

| File | Role |
|---|---|
| `skillcheck.py` | The 476 assertions across 18 named checks (verified: `frontmatter-*`, `name-matches-dir`, `description-length`, `openai-yaml-*`, `links-resolve`, `readme-membership`, `bucket-readme-lists-skill`, `bucket-readme-grouping`, `docs-page-sections`, `ask-matt-mentions-skill`, `ask-matt-no-stale-routes`, `invocation-mode-consistency`, `install-block-*`, `no-claude-plugin-dir`). `REPO` already comes from `sys.argv[1]`. |
| `hand_validator.py` | Dependency-free YAML re-implementation — insurance for a missing `pyyaml`. |
| `yamlcheck.cjs` | Independent Node parser, cross-checks the Python read of every frontmatter field. |
| `diff_parsers.py` | Compares the parsers' outputs; disagreement is itself a finding. |
| `test_guardrail.sh` | The 39 functional cases for `block-dangerous-git.sh`. |
| `render_report.py` | Human-readable report from the JSON rows. |

One fix is required: `test_guardrail.sh` hardcodes `SCRIPT="repo-copy/skills/…"`. Change it to take the repo root from `$1`, defaulting to `.`, matching the two Python validators (which already do this — verified: `skillcheck.py` and `hand_validator.py` both default `REPO` to `sys.argv[1] or "repo-copy"`).

`isolated_test_workspace/` (untracked, never committed — confirmed via `git status`) is deleted in its entirety once the six harness files above are copied out to `scripts/harness/`. It also holds a stale rsync'd copy of the whole tree (`repo-copy/`) and a one-time `TEST_REPORT.md`; neither is needed once the harness runs against the real tree directly, and keeping a second copy of the validator around is exactly the duplication `writing-for-agents` warns about.

### `scripts/check-confusable-skills.py` — the drift tripwire

Roughly 40 lines. For every **model-invoked × model-invoked** pair of skills, tokenise both descriptions (lowercase words, stop-words dropped, single characters dropped), compute the Jaccard index, and report any pair at or above **0.80**.

- User-invoked skills are excluded by construction: with no description in the model's reach, they cannot compete for a model trigger. This is the invocation-axis awareness the naive port lacks.
- Exit non-zero on a flagged pair so CI fails; print the pair and both descriptions so the finding is actionable.
- No allowlist. Measured headroom is 4× (0.185 observed vs 0.80 threshold); an allowlist would be an unused mechanism carrying a maintenance cost.

The threshold is a **tripwire, not a target**: it fires when a newly written description starts competing with an existing one, which is the failure mode seven new skills make likely.

### `.github/workflows/skillcheck.yml`

Modelled on the existing `release.yml`: checkout, `setup-python`, install `pyyaml`, then run the harness and the confusable check against the repo root. Fail the job on any `FAIL` row or flagged pair. Runs on pull requests and pushes to `main`.

Verified before wiring: `skillcheck.py .` reports **476/476 PASS** on the live tree, so the workflow does not land red.

## The subagent return protocol

Appended to [`skills/productivity/writing-for-agents/SKILL.md`](../../../skills/productivity/writing-for-agents/SKILL.md) as a new section after **Pruning**, in about 40 lines. Append-only, so an upstream sync resolves as "keep both".

Content: a subagent's report ends with a status, a one-or-two-sentence summary, and its concerns or blockers. Four statuses, and what the controller does with each:

| Status | Controller's move |
|---|---|
| `DONE` | Proceed. |
| `DONE_WITH_CONCERNS` | Read the concerns; address anything touching correctness or scope before proceeding, note the rest. |
| `BLOCKED` | Change something before retrying — more context, a smaller task, a more capable model, or escalate to the human. Never re-run the same approach unchanged. |
| `NEEDS_CONTEXT` | Supply what's missing, re-dispatch. |

Written positively, per the skill's own negation lever: state what the controller does, rather than forbidding the retry. `DONE`'s handling is one line because a plain proceed is close to the model's default; the load-bearing entries are `BLOCKED` and `DONE_WITH_CONCERNS`.

Then a one-line pointer in each skill that fans out — [`code-review`](../../../skills/engineering/code-review/SKILL.md), [`research`](../../../skills/engineering/research/SKILL.md), [`improve-codebase-architecture`](../../../skills/engineering/improve-codebase-architecture/SKILL.md), [`grilling`](../../../skills/productivity/grilling/SKILL.md) — anchored to the aggregation step ("when aggregating reports from subagents you spawned"). The narrow anchor is deliberate: an unanchored four-status enum leaks into ordinary task completions and the agent starts stamping `Status: DONE` on everything.

## New skills

Seven skills, each filling a phase no current skill covers. All follow the [`writing-for-agents`](../../../skills/productivity/writing-for-agents/SKILL.md) discipline: trigger-only descriptions for model-invoked skills, human-facing one-liners for user-invoked ones, sharp completion criteria, no `When NOT to Use` sections, heavy material behind pointers.

| Skill | Bucket | Invocation | Fills |
|---|---|---|---|
| `ship` | `engineering/` | user-invoked | the main flow's tail: `/implement` ends at a commit |
| `security-review` | `engineering/` | model-invoked | no STRIDE/OWASP coverage anywhere |
| `journal` | `engineering/` | model-invoked | the "why" at ship time |
| `using-worktrees` | `productivity/` | user-invoked | `ask-matt`'s phase-boundary options omit worktrees |
| `retrospective` | `productivity/` | user-invoked | no git-metric health reporting |
| `port-from-repo` **[2026-08-11]** | `engineering/` | user-invoked | nothing covers bringing a capability in from another codebase |
| `when-stuck` **[2026-08-11]** | `in-progress/` | model-invoked | no technique for design-level stuck-ness |

Invocation follows the rule in [`.agents/invocation.md`](../../../.agents/invocation.md): model-invocation is for skills the agent must reach autonomously or another skill must invoke. `security-review` and `journal` are model-invoked because `code-review` and `ship` respectively drive them. `when-stuck` is model-invoked because the agent is usually the party that has stalled. The rest are human entry points, and a user-invoked skill cannot be reached by another skill — so `ship` names `/journal` (model-invoked, reachable) but the human starts `ship` itself.

### `ship`

Takes the work from "committed on a branch" to "PR open". The gap is real: [`implement`](../../../skills/engineering/implement/SKILL.md) ends with "Commit your work to the current branch", and nothing afterwards covers pushing, PR creation, or the release note.

Steps: confirm the tree is clean and tests pass; push the branch with upstream tracking; open the PR through the tracker recorded in `docs/agents/issue-tracker.md` (`gh` for GitHub, `glab` for GitLab, a markdown file for local) — never assume `gh`; link the originating issue or spec; add a changeset when the repo uses them; then drive `/journal`.

Completion criterion: a PR URL (or, for the local-markdown tracker, the written file path), the linked issue, and the changeset path — each shown, not asserted. Explicitly **not** merging: pushing to `main` and merging stay human decisions, consistent with this repo's git posture.

### `security-review`

A third review axis, alongside Standards and Spec in [`code-review`](../../../skills/engineering/code-review/SKILL.md), reusing the parallel-sub-agent split already proven there — a third sub-agent, not a merged pass, so the axes don't pollute one another. Also reachable on its own for a diff or a branch.

The kernel is a STRIDE + OWASP-Top-10 checklist in `references/stride-owasp-checklist.md`, matched against the diff, with findings ranked by severity and each one quoting the hunk. ClaudeKit's red-team persona loop and auto-fix mode are left behind (see [Adjudication record](#adjudication-record)).

Its axis in `code-review` is **opt-in**: `code-review`'s two axes stay the default, and the security axis runs when the diff touches auth, input handling, secrets, network boundaries, or dependencies — or when the user asks. Always-on would make every review a security review.

**[2026-08-11] Mobile addendum.** ClaudeKit's `security-scan` was examined separately on the second pass and is **superseded by this skill** rather than adopted — but its secret-detection half surfaces a gap a generic STRIDE/OWASP checklist misses, and that half is folded in here as a second reference, `references/mobile-secrets.md`:

- `local.properties` and `google-services.json` committed or leaked into a build artifact
- signing config and keystore credentials inline in `build.gradle.kts` rather than read from the environment
- API keys in `Info.plist` or `*.xcconfig`, and keys committed inside `*.xcodeproj`
- **secrets placed in `commonMain`** — the KMP-specific trap, because one careless constant ships into *both* the Android APK and the iOS framework
- R8/ProGuard configured such that shared Kotlin is left unobfuscated in the release build
- App Transport Security exceptions, `android:debuggable` left on, and exported components without permission guards

ClaudeKit's `npm audit` / `pip audit` detection ladder is not ported — wrong ecosystem for this fork. Dependency auditing for KMP stays with the Gradle toolchain and is out of scope here.

### `journal`

One entry per ship, written to the repo's docs location, capturing what the change decided rather than what it did. Completion criterion: the entry names the decision taken, the alternative rejected, and the outcome observed — three things checkable by reading it. An entry that only restates the diff fails.

Driven by `ship` at the end of the pipeline; model-invoked so `ship` can reach it, and so the agent can offer it after a significant change that shipped some other way.

### `using-worktrees`

Pure git: `worktree add` / `list` / `remove` / `prune`, a branch-naming convention, stale-tree cleanup, and the decision of when an isolated tree beats a branch switch. Fully portable — no harness dependency, no scripts. ClaudeKit's `worktree.cjs` CLI is not ported; the git commands are the skill.

This lands as a sixth option in `ask-matt`'s **Phase boundaries** section, which currently offers five (Continue, `/clear`, `/handoff`, Subagent, `/compact`) and never mentions worktrees.

### `retrospective`

Git-metric reporting over a date range or since a ref: commit cadence, file hotspots, churn, per-author breakdown, active-day ratio. Each metric is a `git log` one-liner, so the skill is portable and cheap; the interpretation guidance is what makes it a skill rather than a snippet, and it lives in `references/metrics-guide.md`.

Distinct from [`improve-codebase-architecture`](../../../skills/engineering/improve-codebase-architecture/SKILL.md): that one surveys architecture for deepening opportunities, this one reports process health. Where they meet — a hotspot file that keeps churning — the retro hands off to it.

### `port-from-repo` **[2026-08-11]**

Derived from ClaudeKit's `xia`. **Renamed on adoption:** "xia" is never defined anywhere in ClaudeKit — not in its `SKILL.md`, its `references/`, its bundled `intro.html`, the skills `README.md`, or its `CLAUDE.md`; the only trace is a trigger list containing `'xia'`, `'xi a'`, `'xia feature'`, which marks it as a coined invocation word rather than an acronym. A codename requiring tribal knowledge cannot be routed by `ask-matt` and cannot be guessed by a human browsing slash-commands, so it is named for what it does.

Takes a GitHub URL or local path plus a capability, and brings that capability into this codebase. The spine that survives is **understand → challenge → adapt → verify**, and the one genuinely load-bearing idea is the challenge step: argue why you should *not* port this, before porting it. The governing principle — **adapt, don't transplant** — is what separates it from a copy-paste.

Most of ClaudeKit's 195 lines do not survive, because this repo already owns the primitives they re-implement. The skill **invokes** rather than restates:

| Phase | Delegates to |
|---|---|
| Challenge — is this worth bringing over at all? | [`/grilling`](../../../skills/productivity/grilling/SKILL.md) |
| Where the seam goes in *our* codebase | [`/codebase-design`](../../../skills/engineering/codebase-design/SKILL.md) |
| Building it | [`/tdd`](../../../skills/engineering/tdd/SKILL.md) |
| Closing out | [`/code-review`](../../../skills/engineering/code-review/SKILL.md) |

That delegation is why the adopted version is *shorter* than the original and still does more.

Dropped: the four mode flags (`--compare` / `--copy` / `--improve` / `--port`), the two speed flags, and the keyword intent-detection table. No skill in this repo carries an argument surface, and `--fast` / `--auto` auto-approve contradicts the human-confirmation gates the surrounding skills are built on. The compare-only use stays reachable as prose ("stop after the understand phase"), not as a flag.

KMP angle, and the reason this earns a promoted slot in a mobile fork: the common real case is lifting something out of an Android-only or iOS-only sample into `commonMain`, which is exactly where "adapt, don't transplant" bites — platform APIs, lifecycle assumptions, and DI graphs do not survive the move intact. The skill hands off to [`kmp-module-setup`](../../../skills/mobile/kmp-module-setup/SKILL.md) for the `expect`/`actual` versus interface + DI call.

Completion criterion: the ported capability is reachable through an interface this codebase already uses, has a test at an agreed seam, and the source repo plus the specific commit or path it came from are recorded in the commit message — traceable, not folklore.

### `when-stuck` **[2026-08-11]**

Derived from ClaudeKit's `problem-solving`, whose own `references/attribution.md` credits [Microsoft Amplifier](https://github.com/microsoft/amplifier) (MIT) at commit `2adb63f858e7d760e188197c8e8d4c1ef721e2a6`, 2025-10-10. Per decision 9 the derivation goes to Amplifier's agent definitions directly, and Amplifier is what gets credited.

A dispatch table from symptom to technique when design progress has stalled: inversion, the scale game, simplification cascades, meta-pattern recognition, collision-zone thinking.

**Scoped narrowly, or it collides with two skills already here.** Stuck on a bug is [`diagnosing-bugs`](../../../skills/engineering/diagnosing-bugs/SKILL.md). Stuck on an undecided plan is [`grilling`](../../../skills/productivity/grilling/SKILL.md). `when-stuck` covers **design and architecture stuck-ness only**, and its description must say so — otherwise the router misroutes and `scripts/check-confusable-skills.py` has a real pair to flag rather than a hypothetical one.

Cut hard on the way in. Six techniques across seven reference files is over-built for "five ways to re-frame a stuck problem." Target: a single `SKILL.md`, no `references/`, each technique earning roughly ten lines with a concrete trigger and one worked example. **A technique that cannot state a crisp trigger is filler and gets dropped** — including, if it comes to it, dropping below five.

Beta placement is the point. This is the one of the two most likely to read as fortune-cookie advice, and `in-progress/` is where the repo says such things go: public on purpose, feedback wanted, no docs page, absent from the router, free to disappear. It graduates to `productivity/` only if the team actually reaches for it.

### Registration, per skill

Each **promoted** skill touches four layers beyond itself, per `CLAUDE.md`:

1. `skills/<bucket>/<name>/SKILL.md` (+ `agents/openai.yaml`, + `references/` where noted)
2. the bucket `README.md`, under **User-invoked** or **Model-invoked**
3. the top-level `README.md`, same grouping
4. `docs/<bucket>/<name>.md`, carrying the four sections from [`.agents/writing-docs.md`](../../../.agents/writing-docs.md)

Then `ask-matt` once for all six, and `scripts/link-skills.sh` re-run.

**[2026-08-11]** A skill in `in-progress/` pays roughly half that. `when-stuck` needs only its `SKILL.md`, its `agents/openai.yaml`, and a flat entry in [`skills/in-progress/README.md`](../../../skills/in-progress/README.md) — verified against the six skills already in that bucket, each of which has exactly those three. It gets **no** docs page, **no** top-level README entry, and **no** `ask-matt` route; the harness enforces all three, and adding the top-level entry would actively fail `readme-membership`.

## `kmp-release-and-publish` preflight

A preflight step at the top of [`kmp-release-and-publish`](../../../skills/mobile/kmp-release-and-publish/SKILL.md): before any publish task runs, confirm the working tree is clean and the version is intentional, and stop if not. This is where decision 1 relocates the enforcement `simplify-gate` was meant to provide — at the skill that owns publishing, where "large diff" is not a proxy for "unreviewed" and a release diff is expected to be large.

Append-only, so an upstream sync keeps both sides.

## Adjudication record

What was examined in ClaudeKit and rejected, with the reason. Nine shortlisted mechanisms were each verified by an adversarial reviewer reading the real source before judging (below, one row per mechanism reviewed — some rows group source files that were verified and rejected together as a set), plus a completeness sweep that found the first five gap-filling skills above.

**[2026-08-11]** A second pass re-read the catalogue and added the last four rows. It reached two skills the first sweep missed entirely, superseded one, and re-affirmed one rejection. Rows carrying a **[2026-08-11]** marker are from that pass; the rest are unchanged from 2026-08-10.

| Mechanism | Verdict | Reason |
|---|---|---|
| `score-skill-description.py` — weighted 5-criterion rubric | **Partly adopted** | Trigger-phrase requirement contradicts the invocation axis; ~10 of 39 skills would fail for obeying house style. Confusable-pair half adopted (decision 2). |
| `validate-skill-frontmatter.py`, `validate-skill-crossrefs.py` | Rejected | Validate ClaudeKit's own schema (`category`, `keywords`, `/ck:` graphs). Disjoint from our invariants. |
| `ck-predict` — 5-persona debate | Rejected | Personas "analyse independently" inside **one** context — prompt role-play, not the sub-agent isolation `code-review` actually gets. Space already held by `grilling`, `codebase-design`'s design-it-twice, and `code-review`. Its GO/CAUTION/STOP verdict is a self-graded bound, the premature-completion failure `writing-for-agents` names. |
| `ck-scenario` — 12 dimensions + saturation exit | Rejected; **re-affirmed [2026-08-11]** | Exhaustive edge-case enumeration contradicts [`tdd`](../../../skills/engineering/tdd/SKILL.md), which agrees seams up front "instead of every edge case". Two skills giving opposite instructions is a variance bug. The saturation-exit idea is genuinely good and stays available as prose if a future skill needs a novelty-gated loop. **Re-raised 2026-08-11** on a narrower framing — a prioritisation aid feeding `tdd`'s seam agreement rather than exhaustive generation, with mobile dimensions added (process death, permissions revoked mid-session, background/foreground, locale and RTL). Re-rejected: the narrow version is a real improvement on ClaudeKit's but it still asks the agent to enumerate broadly before choosing, which is the move `tdd` exists to resist, and the seam-choosing step it claims to fill is already `tdd`'s own "confirm the seams with the user". Revisit after plans 2–5 ship, if that step proves underspecified in practice. |
| `ck-loop` — mechanical-metric loop | Rejected | Requires a `Verify` command printing a single number; its own 200-line metric cookbook is all JS/Python/Go/Rust with no KMP/Swift example — evidence the contract is hard to satisfy. Name collides with `loop-me`. `tdd`, `diagnosing-bugs`, and `improve-codebase-architecture` already hold iterative improvement here. |
| Orchestration protocol — 4 statuses | **Partly adopted** | Status enum and controller rules adopted (decision 5); context-isolation and prompt-template sections restate `writing-for-agents`. |
| `.claude/agents/*.md` — 13 role agents, model pinning | Rejected | Named dispatch and `model:` pinning are harness runtime, not portable skill content; a ported version no-ops on Codex. The behavioural-checklist fragment already exists here as completion criteria. |
| `output-styles/coding-level-*.md` | Rejected | Claude-Code-only primitive; content is largely model default restated through the negation lever house style rejects; overlaps `teach` and `wait-what`. An individual preference, not a team default. |
| 23 hooks — `simplify-gate`, `privacy-block`, `dev-rules-reminder`, `descriptive-name`, `session-init` | Rejected | `simplify-gate` misfires on KMP (decision 1). `privacy-block` duplicates the harness's own permission system. `dev-rules-reminder` duplicates `CLAUDE.md`. `descriptive-name` exits zero unconditionally — prose in hook clothing, so a `CLAUDE.md` line does the same work. `session-init`/`subagent-init` are ClaudeKit runtime (plan state, `ck` CLI, statusline cache). |
| ~40 domain skills (Shopify, Three.js, shaders, payments, `mobile-development`) | Rejected | Reference dumps that go stale. `mobile-development` covers React Native + Flutter + Swift + Kotlin in one skill — strictly weaker than our four KMP skills. |
| `agentize`, `deploy`, `team`, `plans-kanban`, `ck-help`, `context-engineering` | Rejected | Depend on the `ck` CLI, VS Code, or harness-specific task primitives. |
| `scout`, `repomix`, `sequential-thinking`, `cook`, `ck-plan`, `fix`, `brainstorm` | Rejected | Overlap `grilling`, `wayfinder`, `implement`, `diagnosing-bugs`, `research`. Not gaps. **[2026-08-11]** `sequential-thinking`, `cook`, and `brainstorm` cover idea generation and stepwise reasoning, which `grilling` owns; `when-stuck` covers reframing an already-formed design, which it does not. |
| `xia` — extract/compare/port a feature from another repo **[2026-08-11]** | **Adopted**, renamed `port-from-repo` | Not examined on the first pass — zero mentions in this record before today. No skill here covers bringing a capability in from another codebase; `research` investigates questions and `implement` builds from a spec, neither ports. Its flag surface and auto-approve modes are dropped, and four of its phases collapse into invocations of skills this repo already owns. |
| `problem-solving` — 6 techniques, 7 reference files **[2026-08-11]** | **Adopted** into `in-progress/` as `when-stuck`, cut hard | Not examined on the first pass. Fills design-level stuck-ness, which `diagnosing-bugs` (bugs) and `grilling` (undecided plans) leave uncovered. Beta placement because it is the likeliest of the set to read as filler; the seven reference files collapse to one `SKILL.md`. Derived from Microsoft Amplifier (MIT) directly, per decision 9. |
| `security-scan` — secrets, deps, vulnerability patterns **[2026-08-11]** | **Superseded** by `security-review` | Same job as the skill already planned here, and a second one would split the axis and give the confusable check a real pair to flag. Its mobile secret-detection patterns are the transferable half and are folded into `security-review` as `references/mobile-secrets.md`; its `npm audit` / `pip audit` ladder is the wrong ecosystem. |
| `worktree`, `retro`, `journal` **[2026-08-11]** | Already covered | Re-surfaced on the second pass; each is already adopted above as `using-worktrees`, `retrospective`, and `journal` respectively. Recorded so a third pass doesn't raise them again. |

## Sequencing

Five plans, in dependency order. Each is separately reviewable.

1. **Validation infra** — promote the harness, add the confusable check, wire CI. First, because it is the tool that guards the new descriptions that follow. **Shipped 2026-08-10 in PR #5** (`ffb265d`, `2ff2d76`, `ffd4a94`).
2. **Subagent return protocol** — append to `writing-for-agents`, add the four pointers. Before the new skills, so `ship` and `security-review` are written under the protocol rather than retrofitted.
3. **The ship tail** — `ship` + `journal` together; they share a seam (the journal entry pairs with the PR), and designing them apart would write that seam twice.
4. **Review and discipline** — `security-review` (including its `code-review` axis and the mobile-secrets reference), `using-worktrees`, `retrospective`, the `kmp-release-and-publish` preflight.
5. **[2026-08-11] The second-pass adoptions** — `port-from-repo`, `when-stuck`, then the single `ask-matt` re-sync covering all six promoted skills, and `scripts/link-skills.sh`. **Shipped 2026-08-11** (`ba8ac57`, `261995c`, `bfb933b`, `258b3ec`).

Plan 5 goes last for one reason: the `ask-matt` re-sync is a shared resource, and whichever plan runs last owns it. Plan 5 itself is independent of plans 2–4 and executable standalone — nothing in it depends on `ship`, `security-review`, `using-worktrees`, or `retrospective` existing first. Running the re-sync last means it covers all six promoted skills once the earlier plans have shipped theirs, rather than being written once and patched again later.

A changeset ships with each plan, per repo convention.

## Verification

Each plan closes with the harness green. Verified at 476/476 across 18 checks on the 39 existing skills; each new promoted skill adds ~12–13 rows (one per applicable check; the 13th is `invocation-mode-consistency`, which fires only when `agents/openai.yaml` carries a `policy.allow_implicit_invocation` key — i.e. for the user-invoked skills), so plan 4 should land at roughly 476 + 5×12 ≈ 536 assertions, still 100% pass.

**[2026-08-11]** Plan 5 adds two more skills but not 2×12 rows. `port-from-repo` is promoted and user-invoked, so it draws the full ~13. `when-stuck` sits in `in-progress/`, where three checks do not fire — `docs-page-sections`, `bucket-readme-grouping`, and `ask-matt-mentions-skill` are all gated on `PROMOTED = {"engineering", "productivity", "mobile"}` — and `readme-membership` inverts, passing only while the skill stays out of the top-level README. Expect roughly **560** assertions at the end of plan 5, still 100% pass. The exact count is whatever `skillcheck.py .` reports; it is the gate, not the prediction.

Also required, per plan: the confusable check clean, and — for every new skill — the retrieval test [`CUSTOMIZING.md`](../../../CUSTOMIZING.md) prescribes: dispatch a subagent that may read only the skill folder, ask it 4–5 realistic task questions, and treat any gap in its answers as the bug to fix before shipping.

**[2026-08-11]** Two additions specific to plan 5:

- **Confusable check is load-bearing here, not ceremonial.** `when-stuck` is model-invoked and its natural description overlaps `diagnosing-bugs` and `grilling`. This is the first pair in the repo's history with a plausible route to the 0.80 threshold, so the check runs *before* the description is finalised, not after.
- **Attribution lands in-tree.** Each of the two skills states its lineage in its own `SKILL.md` — Amplifier for `when-stuck`, ClaudeKit's `xia` for `port-from-repo` — and [`MAINTENANCE.md`](../../../MAINTENANCE.md) gains a line recording that both are fork additions re-authored from external patterns, so an upstream sync doesn't mistake them for upstream skills and drop them.

## Out of scope

- Porting any hook, output style, or agent definition (adjudication record).
- A `.claude/` runtime, a plugin, or anything reintroducing the route ADR [0002](../../../.agents/adr/0002-ship-as-a-claude-code-plugin.md) closed.
- Rewriting upstream skills. `code-review`, `writing-for-agents`, `tdd`, and `kmp-release-and-publish` receive append-only additions; no upstream skill is restructured.
- Merging or pushing to `main` inside `ship`.
- **[2026-08-11]** Copying any prose, reference file, or script out of `claudekit-engineer`. Decision 9 makes every adoption a fresh write from the pattern; the source tree is read as research and nothing is transcribed from it.
- **[2026-08-11]** Editing anything outside this repository. `claudekit-engineer` is read-only for this work.
- **[2026-08-11]** A dependency-audit capability for KMP. `security-scan`'s `npm audit` / `pip audit` ladder is not ported and no Gradle equivalent is specced here.
