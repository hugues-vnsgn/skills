# ClaudeKit adoption — design

**Date:** 2026-08-10
**Status:** Proposed
**Scope:** This repo (`osxsystem/skills`) only. Adds two maintainer scripts, one CI workflow, one appended section to an existing skill, five new promoted skills, and a preflight step in one mobile skill. Nothing outside the repo is touched; no upstream skill is rewritten.

## Goal

Absorb the mechanisms worth having from [`claudekit-engineer`](https://github.com/claudekit/claudekit-engineer) — a ClaudeKit project template whose value lives in a `.claude/` runtime (83 skills, 16 hook scripts, 13 named agents, 5 validator scripts) — into this fork **without** importing its runtime. Two things come out of it: enforcement for the invariants our prose already states, and five skills that fill genuine gaps in the flow `ask-matt` maps.

The comparison that produced this list, including the mechanisms deliberately rejected, is recorded in [Adjudication record](#adjudication-record) below. Rejections are decisions: they exist so a future maintainer reading ClaudeKit doesn't re-litigate them.

## The shape of the difference

Both repos ship agent skills; they are not the same kind of artifact.

| | this fork | claudekit-engineer |
|---|---|---|
| Unit shipped | 39 portable skills, installed as files you own | a whole `.claude/` runtime, scaffolded into a project |
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
2. **Adopt the confusable-pair check, drop the rest of the scorer.** ClaudeKit's `score-skill-description.py` weights five criteria and requires a `Use for/when` trigger phrase. That requirement contradicts [`.agents/invocation.md`](../../../.agents/invocation.md): our 20 user-invoked skills carry human-facing one-line summaries by design, so the rubric would fail them for obeying house style. The Jaccard confusable-pair detector is the transferable half. Its dependency-cycle detector has nothing to validate — no skill here uses a `requires:` field, and cross-skill deps are discouraged.
3. **The confusable check runs over model-invoked pairs only, at threshold 0.80, with no allowlist.** Measured against all 39 real descriptions before deciding (20 user-invoked, 19 model-invoked): the highest model-invoked pair is `tdd` ↔ `migrate-to-shoehorn` at **0.185**, and 0.80 flags nothing at all. The `kmp-*` quartet peaks at 0.125. The single highest pair in the whole repo, `grill-with-docs` ↔ `grill-me` at 0.417, is excluded from the check entirely — both are user-invoked, so neither carries a model-facing trigger description to collide on; the router `ask-matt` is what disambiguates them for a human. A family allowlist was designed and then cut as unnecessary. The check is a **tripwire for future drift**, not a cleanup tool for today.
4. **Promote the existing validator rather than port ClaudeKit's.** This repo already has a 476-assertion harness — written for a one-off audit and left untracked in `isolated_test_workspace/harness/`. It enforces our own `CLAUDE.md` invariants (bucket-README membership and grouping, docs-page four-section template, invocation-mode consistency across `SKILL.md` and `agents/openai.yaml`, link resolution, `ask-matt` routing freshness and stale routes, install-block verbatim, no `.claude-plugin/`). ClaudeKit's validators check a disjoint invariant set (its own `category`/`keywords` schema, `/ck:` reference graphs) — nothing to take. **Verified: 476/476 pass against the live repo today**, so CI starts green.
5. **The subagent return protocol is an appended section, not a skill.** ClaudeKit's four-status contract (`DONE` / `DONE_WITH_CONCERNS` / `BLOCKED` / `NEEDS_CONTEXT`) plus its controller-handling rules are genuinely new here; the surrounding material (context isolation, prompt templates, parallel-vs-sequential guidance) restates what `writing-for-agents` already covers. It has no distinct trigger word and no skill would invoke it by name, so it earns no registration cost.
6. **Five new promoted skills**, each filling a phase no current skill covers: `ship`, `security-review`, `journal`, `using-worktrees`, `retrospective`. Placement and invocation in [New skills](#new-skills).
7. **`kmp-release-and-publish` gains a preflight step** — refuse to publish from a dirty tree — which is where decision 1 relocates the only hook worth its enforcement.
8. **`ask-matt` is re-synced once**, at the end, covering all five skills in one edit. `CLAUDE.md` requires the router to stay accurate; five separate syncs would restate one meaning five times.

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

The threshold is a **tripwire, not a target**: it fires when a newly written description starts competing with an existing one, which is the failure mode five new skills make likely.

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

Five skills, each filling a phase no current skill covers. All follow the [`writing-for-agents`](../../../skills/productivity/writing-for-agents/SKILL.md) discipline: trigger-only descriptions for model-invoked skills, human-facing one-liners for user-invoked ones, sharp completion criteria, no `When NOT to Use` sections, heavy material behind pointers.

| Skill | Bucket | Invocation | Fills |
|---|---|---|---|
| `ship` | `engineering/` | user-invoked | the main flow's tail: `/implement` ends at a commit |
| `security-review` | `engineering/` | model-invoked | no STRIDE/OWASP coverage anywhere |
| `journal` | `engineering/` | model-invoked | the "why" at ship time |
| `using-worktrees` | `productivity/` | user-invoked | `ask-matt`'s phase-boundary options omit worktrees |
| `retrospective` | `productivity/` | user-invoked | no git-metric health reporting |

Invocation follows the rule in [`.agents/invocation.md`](../../../.agents/invocation.md): model-invocation is for skills the agent must reach autonomously or another skill must invoke. `security-review` and `journal` are model-invoked because `code-review` and `ship` respectively drive them. The other three are human entry points, and a user-invoked skill cannot be reached by another skill — so `ship` names `/journal` (model-invoked, reachable) but the human starts `ship` itself.

### `ship`

Takes the work from "committed on a branch" to "PR open". The gap is real: [`implement`](../../../skills/engineering/implement/SKILL.md) ends with "Commit your work to the current branch", and nothing afterwards covers pushing, PR creation, or the release note.

Steps: confirm the tree is clean and tests pass; push the branch with upstream tracking; open the PR through the tracker recorded in `docs/agents/issue-tracker.md` (`gh` for GitHub, `glab` for GitLab, a markdown file for local) — never assume `gh`; link the originating issue or spec; add a changeset when the repo uses them; then drive `/journal`.

Completion criterion: a PR URL (or, for the local-markdown tracker, the written file path), the linked issue, and the changeset path — each shown, not asserted. Explicitly **not** merging: pushing to `main` and merging stay human decisions, consistent with this repo's git posture.

### `security-review`

A third review axis, alongside Standards and Spec in [`code-review`](../../../skills/engineering/code-review/SKILL.md), reusing the parallel-sub-agent split already proven there — a third sub-agent, not a merged pass, so the axes don't pollute one another. Also reachable on its own for a diff or a branch.

The kernel is a STRIDE + OWASP-Top-10 checklist in `references/stride-owasp-checklist.md`, matched against the diff, with findings ranked by severity and each one quoting the hunk. ClaudeKit's red-team persona loop and auto-fix mode are left behind (see [Adjudication record](#adjudication-record)).

Its axis in `code-review` is **opt-in**: `code-review`'s two axes stay the default, and the security axis runs when the diff touches auth, input handling, secrets, network boundaries, or dependencies — or when the user asks. Always-on would make every review a security review.

### `journal`

One entry per ship, written to the repo's docs location, capturing what the change decided rather than what it did. Completion criterion: the entry names the decision taken, the alternative rejected, and the outcome observed — three things checkable by reading it. An entry that only restates the diff fails.

Driven by `ship` at the end of the pipeline; model-invoked so `ship` can reach it, and so the agent can offer it after a significant change that shipped some other way.

### `using-worktrees`

Pure git: `worktree add` / `list` / `remove` / `prune`, a branch-naming convention, stale-tree cleanup, and the decision of when an isolated tree beats a branch switch. Fully portable — no harness dependency, no scripts. ClaudeKit's `worktree.cjs` CLI is not ported; the git commands are the skill.

This lands as a sixth option in `ask-matt`'s **Phase boundaries** section, which currently offers five (Continue, `/clear`, `/handoff`, Subagent, `/compact`) and never mentions worktrees.

### `retrospective`

Git-metric reporting over a date range or since a ref: commit cadence, file hotspots, churn, per-author breakdown, active-day ratio. Each metric is a `git log` one-liner, so the skill is portable and cheap; the interpretation guidance is what makes it a skill rather than a snippet, and it lives in `references/metrics-guide.md`.

Distinct from [`improve-codebase-architecture`](../../../skills/engineering/improve-codebase-architecture/SKILL.md): that one surveys architecture for deepening opportunities, this one reports process health. Where they meet — a hotspot file that keeps churning — the retro hands off to it.

### Registration, per skill

Each promoted skill touches four layers beyond itself, per `CLAUDE.md`:

1. `skills/<bucket>/<name>/SKILL.md` (+ `agents/openai.yaml`, + `references/` where noted)
2. the bucket `README.md`, under **User-invoked** or **Model-invoked**
3. the top-level `README.md`, same grouping
4. `docs/<bucket>/<name>.md`, carrying the four sections from [`.agents/writing-docs.md`](../../../.agents/writing-docs.md)

Then `ask-matt` once for all five, and `scripts/link-skills.sh` re-run.

## `kmp-release-and-publish` preflight

A preflight step at the top of [`kmp-release-and-publish`](../../../skills/mobile/kmp-release-and-publish/SKILL.md): before any publish task runs, confirm the working tree is clean and the version is intentional, and stop if not. This is where decision 1 relocates the enforcement `simplify-gate` was meant to provide — at the skill that owns publishing, where "large diff" is not a proxy for "unreviewed" and a release diff is expected to be large.

Append-only, so an upstream sync keeps both sides.

## Adjudication record

What was examined in ClaudeKit and rejected, with the reason. Nine shortlisted mechanisms were each verified by an adversarial reviewer reading the real source before judging (below, one row per mechanism reviewed — some rows group source files that were verified and rejected together as a set), plus a completeness sweep that found the five gap-filling skills above.

| Mechanism | Verdict | Reason |
|---|---|---|
| `score-skill-description.py` — weighted 5-criterion rubric | **Partly adopted** | Trigger-phrase requirement contradicts the invocation axis; ~10 of 39 skills would fail for obeying house style. Confusable-pair half adopted (decision 2). |
| `validate-skill-frontmatter.py`, `validate-skill-crossrefs.py` | Rejected | Validate ClaudeKit's own schema (`category`, `keywords`, `/ck:` graphs). Disjoint from our invariants. |
| `ck-predict` — 5-persona debate | Rejected | Personas "analyse independently" inside **one** context — prompt role-play, not the sub-agent isolation `code-review` actually gets. Space already held by `grilling`, `codebase-design`'s design-it-twice, and `code-review`. Its GO/CAUTION/STOP verdict is a self-graded bound, the premature-completion failure `writing-for-agents` names. |
| `ck-scenario` — 12 dimensions + saturation exit | Rejected | Exhaustive edge-case enumeration contradicts [`tdd`](../../../skills/engineering/tdd/SKILL.md), which agrees seams up front "instead of every edge case". Two skills giving opposite instructions is a variance bug. The saturation-exit idea is genuinely good and stays available as prose if a future skill needs a novelty-gated loop. |
| `ck-loop` — mechanical-metric loop | Rejected | Requires a `Verify` command printing a single number; its own 200-line metric cookbook is all JS/Python/Go/Rust with no KMP/Swift example — evidence the contract is hard to satisfy. Name collides with `loop-me`. `tdd`, `diagnosing-bugs`, and `improve-codebase-architecture` already hold iterative improvement here. |
| Orchestration protocol — 4 statuses | **Partly adopted** | Status enum and controller rules adopted (decision 5); context-isolation and prompt-template sections restate `writing-for-agents`. |
| `.claude/agents/*.md` — 13 role agents, model pinning | Rejected | Named dispatch and `model:` pinning are harness runtime, not portable skill content; a ported version no-ops on Codex. The behavioural-checklist fragment already exists here as completion criteria. |
| `output-styles/coding-level-*.md` | Rejected | Claude-Code-only primitive; content is largely model default restated through the negation lever house style rejects; overlaps `teach` and `wait-what`. An individual preference, not a team default. |
| 23 hooks — `simplify-gate`, `privacy-block`, `dev-rules-reminder`, `descriptive-name`, `session-init` | Rejected | `simplify-gate` misfires on KMP (decision 1). `privacy-block` duplicates the harness's own permission system. `dev-rules-reminder` duplicates `CLAUDE.md`. `descriptive-name` exits zero unconditionally — prose in hook clothing, so a `CLAUDE.md` line does the same work. `session-init`/`subagent-init` are ClaudeKit runtime (plan state, `ck` CLI, statusline cache). |
| ~40 domain skills (Shopify, Three.js, shaders, payments, `mobile-development`) | Rejected | Reference dumps that go stale. `mobile-development` covers React Native + Flutter + Swift + Kotlin in one skill — strictly weaker than our four KMP skills. |
| `agentize`, `deploy`, `team`, `plans-kanban`, `ck-help`, `context-engineering` | Rejected | Depend on the `ck` CLI, VS Code, or harness-specific task primitives. |
| `scout`, `repomix`, `sequential-thinking`, `cook`, `ck-plan`, `fix`, `brainstorm` | Rejected | Overlap `grilling`, `wayfinder`, `implement`, `diagnosing-bugs`, `research`. Not gaps. |

## Sequencing

Four plans, in dependency order. Each is separately reviewable.

1. **Validation infra** — promote the harness, add the confusable check, wire CI. First, because it is the tool that guards the five new descriptions that follow.
2. **Subagent return protocol** — append to `writing-for-agents`, add the four pointers. Before the new skills, so `ship` and `security-review` are written under the protocol rather than retrofitted.
3. **The ship tail** — `ship` + `journal` together; they share a seam (the journal entry pairs with the PR), and designing them apart would write that seam twice.
4. **Review and discipline** — `security-review` (including its `code-review` axis), `using-worktrees`, `retrospective`, the `kmp-release-and-publish` preflight, the single `ask-matt` re-sync, and `scripts/link-skills.sh`.

A changeset ships with each plan, per repo convention.

## Verification

Each plan closes with the harness green. Verified today at 476/476 across 18 checks on the 39 existing skills; each new promoted skill adds ~12–13 rows (one per applicable check; the 13th is `invocation-mode-consistency`, which fires only when `agents/openai.yaml` carries a `policy.allow_implicit_invocation` key — i.e. for the user-invoked skills), so plan 4 should land at roughly 476 + 5×12 ≈ 536 assertions, still 100% pass. Also required: the confusable check clean, and — for the five new skills — the retrieval test [`CUSTOMIZING.md`](../../../CUSTOMIZING.md) prescribes: dispatch a subagent that may read only the skill folder, ask it 4–5 realistic task questions, and treat any gap in its answers as the bug to fix before shipping.

## Out of scope

- Porting any hook, output style, or agent definition (adjudication record).
- A `.claude/` runtime, a plugin, or anything reintroducing the route ADR [0002](../../../.agents/adr/0002-ship-as-a-claude-code-plugin.md) closed.
- Rewriting upstream skills. `code-review`, `writing-for-agents`, `tdd`, and `kmp-release-and-publish` receive append-only additions; no upstream skill is restructured.
- Merging or pushing to `main` inside `ship`.
