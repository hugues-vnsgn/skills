# Second-Pass Adoptions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the two skills the second pass over ClaudeKit's catalogue adopted — `port-from-repo` (promoted, user-invoked) and `when-stuck` (beta, model-invoked) — and re-sync the router once for the promoted one.

**Architecture:** Three deliverables, each independently reviewable. Task 1 ships a fully-registered promoted skill (skill, Codex metadata, both READMEs, docs page). Task 2 ships a beta skill, which pays roughly half that registration because `in-progress/` is not a promoted bucket. Task 3 re-syncs `ask-matt`, fixes a stale count it already carries, records the fork addition in `MAINTENANCE.md`, and re-links the local harnesses. No existing skill's behaviour changes.

**Tech Stack:** Markdown skills, YAML frontmatter, `agents/openai.yaml` Codex metadata, Python validation harness (`scripts/harness/skillcheck.py`, `scripts/check-confusable-skills.py`), bash (`scripts/link-skills.sh`), Changesets.

Plan 5 of 5 from [the ClaudeKit adoption spec](../specs/2026-08-10-claudekit-adoption-design.md). Plan 1 (validation infra) shipped in PR #5. Plans 2–4 (subagent return protocol; `ship` + `journal`; review & discipline) are still pending and are **not** prerequisites for this plan — see Global Constraints.

## Global Constraints

- **Nothing is copied from `claudekit-engineer`.** Per spec decision 9, that tree ships no `LICENSE`, no `package.json`, and no git remote. Both skills are written fresh from the pattern. Transcribing a sentence, a heading structure, or a reference file out of it is a task failure. The source repo is read-only for this work and lives outside this repository.
- **The harness must stay green.** `python3 scripts/harness/skillcheck.py .` reports **476/476 PASS across 18 checks over 39 skills** today (verified). Every task ends with it passing. The final count lands near **560**; the exact number is whatever the tool reports, and the gate is `PASS`, not the number.
- **`python3 scripts/check-confusable-skills.py .` must stay clean.** Today: `39 skills: 19 model-invoked, 20 user-invoked (excluded)` — `PASS — no pair at or above 0.80 (highest: 0.185)`. `when-stuck` is model-invoked and joins the compared set; `port-from-repo` is user-invoked and is excluded by construction.
- **Folder name, frontmatter `name:`, docs filename, and README anchor are one identifier.** Verified: all 39 skills match with zero exceptions, and `skillcheck.py` asserts it as `name-matches-dir`.
- **Frontmatter carries `name` and `description` only** — plus `disable-model-invocation: true` for user-invoked skills. No `category`, `keywords`, `argument-hint`, `license`, or `metadata` fields; those are ClaudeKit's schema, not this repo's.
- **User-invoked descriptions are human-facing one-liners** with no trigger phrasing; **model-invoked descriptions keep trigger phrasing** so auto-invocation fires. Per [`.agents/invocation.md`](../../../.agents/invocation.md). The two harnesses must agree: `disable-model-invocation: true` in `SKILL.md` pairs with `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, and `skillcheck.py` asserts it as `invocation-mode-consistency`.
- **`in-progress/` skills get no docs page, no top-level README entry, and no `ask-matt` route.** `docs-page-sections`, `bucket-readme-grouping`, and `ask-matt-mentions-skill` are gated on `PROMOTED = {"engineering", "productivity", "mobile"}`; `readme-membership` inverts for non-promoted buckets and **fails** if the skill appears in the top-level README. Adding one is a task failure, not a bonus.
- **Docs pages use absolute links only** (`https://aihero.dev/skills-<name>`, or full `https://github.com/osxsystem/skills/...`), carry no H1, and write no install commands. Per [`.agents/writing-docs.md`](../../../.agents/writing-docs.md). Exception, stated there: fork-local targets — `setup-osxsystem-skills` and the `mobile/` bucket — link repo-relative on purpose, because aihero.dev never hosts them.
- **Commit messages use conventional-commit prefixes.** Per `CLAUDE.md`, do not use `chore`/`docs` prefixes for changes inside a `.claude` directory — not applicable here.
- **One changeset ships with the plan** (`.changeset/<name>.md`, package `"osxsystem-skills"`, bump `patch`), added in Task 3 so it describes the whole plan once.
- **Plans 2–4 are not prerequisites.** Neither new skill references `/ship`, `/journal`, `/security-review`, `/using-worktrees`, or `/retrospective`, so this plan is executable standalone. If those plans have already shipped when this one runs, Task 3's single `ask-matt` edit covers their skills too; if they have not, it covers `port-from-repo` alone and the `ask-matt-mentions-skill` check passes either way, because it only asserts over skills that exist.

## File Structure

| Path | Responsibility | Status |
|---|---|---|
| `skills/engineering/port-from-repo/SKILL.md` | The skill: understand → challenge → adapt → verify, delegating four phases to skills this repo already owns. | Create |
| `skills/engineering/port-from-repo/agents/openai.yaml` | Codex picker metadata + the user-invoked policy flag. | Create |
| `skills/engineering/README.md` | Bucket index entry under **User-invoked**. | Modify |
| `README.md` | Top-level index entry under **Engineering → User-invoked**. | Modify |
| `docs/engineering/port-from-repo.md` | Human-facing docs page, four required sections. | Create |
| `skills/in-progress/when-stuck/SKILL.md` | The skill: five techniques for design-level stuck-ness, scoped away from bugs and plans. | Create |
| `skills/in-progress/when-stuck/agents/openai.yaml` | Codex picker metadata. Model-invoked, so **no** `policy` block. | Create |
| `skills/in-progress/README.md` | Bucket index entry, flat list. | Modify |
| `skills/engineering/ask-matt/SKILL.md` | New on-ramp for `port-from-repo`; fix the stale on-ramp count on line 11. | Modify |
| `MAINTENANCE.md` | Record both skills as fork additions so an upstream sync doesn't drop them. | Modify |
| `.changeset/second-pass-adoptions.md` | Release note for the plan. | Create |

Task 1 is `port-from-repo` and its full registration; Task 2 is `when-stuck` and its lighter registration; Task 3 is the router, the fork record, and the changeset.

---

### Task 1: `port-from-repo` — skill, Codex metadata, and full registration

A promoted skill is not shippable half-registered: `readme-membership` **fails** a promoted skill missing from the top-level README. So the skill, its Codex metadata, both README entries, and its docs page land in one task.

**Files:**
- Create: `skills/engineering/port-from-repo/SKILL.md`
- Create: `skills/engineering/port-from-repo/agents/openai.yaml`
- Create: `docs/engineering/port-from-repo.md`
- Modify: `skills/engineering/README.md` (under `## User-invoked`)
- Modify: `README.md` (under `### Engineering` → `**User-invoked**`)
- Test: `python3 scripts/harness/skillcheck.py .`

**Interfaces:**
- Consumes: nothing from earlier tasks (first task).
- Produces:
  - A user-invoked skill named `port-from-repo` in the `engineering` bucket. Task 3 adds its `ask-matt` route and relies on this exact name.
  - Prose invocations of four existing skills — `/grilling`, `/codebase-design`, `/tdd`, `/code-review` — and one mobile skill, `/kmp-module-setup`. These are `/skill`-style prose per `.agents/invocation.md`, **not** relative file links; `links-resolve` only checks markdown links, and deep `../other-skill/FILE.md` cross-references are against house convention.

- [ ] **Step 1: Create the skill directory and write `SKILL.md`**

Create `skills/engineering/port-from-repo/SKILL.md` with exactly this content:

```markdown
---
name: port-from-repo
description: Bring a capability across from another codebase — study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.
disable-model-invocation: true
---

# Port from repo

You saw something work in another codebase and you want it here. This skill brings the capability over without bringing its architecture with it.

**Adapt, don't transplant.** The code you are reading was shaped by constraints that are not yours — its dependency graph, its error convention, its platform assumptions, its idea of where a boundary goes. What travels is the *approach*; the expression gets rewritten in this codebase's idiom. A port that reads like a foreign body is a failed port, even when the tests are green.

Ask the user for the source — a GitHub URL, an `owner/repo`, or a local path — and for the capability they want, if they haven't already said.

## The source is read-only

Fetch it outside this repository: a shallow clone in a temp directory, or `gh` reads against the API when you only need a few files. Never add it as a submodule, never vendor the tree, never edit it. You are reading a primary source, not acquiring a dependency.

Prefer reading over cloning when the capability is small and the repo is large — a clone you have to search is slower than the two files you actually need.

## Understand

Before any judgement about whether to port, be able to answer four questions:

- **What does it do?** State the behaviour without referring to its code.
- **How does it earn its keep?** Name the hard part it solves. Most ported code is a little insight surrounded by a lot of plumbing — find the insight.
- **What holds it up?** The dependencies, framework assumptions, and platform APIs it stands on, and which of those exist here.
- **What did it cost the source?** The constraints its own codebase accepted in order to have it.

Report the four answers back before going on. Not being able to answer the second one means you are ready to copy, not to port — and copying is the failure this skill exists to prevent.

## Challenge

Run the `/grilling` skill on one question: **should we bring this over at all?**

Don't skip this because the answer feels obvious — it is the step that separates a port from a copy. The frontier to push on:

- What is the smallest thing that solves our actual problem? It is usually a fraction of what the source built.
- What do we already have that overlaps? A port that duplicates an existing seam makes the codebase worse, not better.
- Which of the source's constraints are we inheriting, and do we accept them?
- What happens if we do nothing?

Grilling ends in decisions. Carry them into the next phase: what is in scope, what is cut, and what we are deliberately doing differently from the source.

## Adapt

Decide where it lands before writing anything. Use the `/codebase-design` skill for the vocabulary — the seam it sits behind, how deep the module is, what the interface exposes. Treat the source's boundaries as evidence, not instruction: it drew them for its own codebase.

Then build with the `/tdd` skill, one vertical slice at a time, at seams agreed with the user. Retyping rather than pasting is not ceremony — it is what surfaces the assumptions that don't hold here.

Translate as you go:

- **Naming** to this project's domain language — read `CONTEXT.md` where it exists.
- **Error handling** to this codebase's convention, not the source's.
- **Dependencies** to what the manifest already has. A port that wants three new packages says so out loud, and gets an answer, before it adds them.

### Porting into Kotlin Multiplatform

The common case in this repo is lifting something out of an Android-only or iOS-only sample into `commonMain`, which is where "adapt, don't transplant" bites hardest.

- Anything touching a platform API cannot cross as-is. The `expect`/`actual` versus interface-plus-DI call belongs to the `/kmp-module-setup` skill.
- Lifecycle assumptions do not travel. Code that assumes an Android `Activity` recreation, or a `UIViewController` appearing, has to be re-expressed as explicit state before it can live in shared code.
- A captured `Context` or `UIViewController` is a signal you are porting the plumbing rather than the insight. Find the behaviour underneath it.

## Verify

Close out with the `/code-review` skill.

Then record provenance in the commit message: the source repository, the specific commit or file path it came from, and what you changed on the way in. A port whose origin is folklore cannot be re-checked when the source fixes a bug.

## Done when

- The capability is reachable through an interface this codebase already uses.
- It has a test at a seam agreed with the user, and that test would pass against a fresh implementation of the same behaviour.
- Nothing in the diff reads as imported — naming, error handling, and structure match the code around it.
- The commit message names the source repository and the commit or path.

---

Derived from the `xia` skill in ClaudeKit, re-authored for this repo. Renamed because "xia" is not defined anywhere in that project.
```

- [ ] **Step 2: Verify the skill is picked up and the name matches its directory**

Run: `python3 scripts/harness/skillcheck.py . --json | python3 -c "import json,sys; rows=json.load(sys.stdin); print('\n'.join(f\"{r['status']} {r['check']}\" for r in rows if r.get('skill')=='port-from-repo'))"`

Expected: rows appear for `port-from-repo`, with `name-matches-dir` PASS. Several other rows FAIL at this point and that is correct — `openai-yaml-*` (the file arrives in Step 3), `readme-membership` and `bucket-readme-lists-skill` (Step 4), `ask-matt-mentions-skill` (Task 3). No `docs-page-sections` row appears yet: the check is skipped entirely when the file is absent rather than failing, which is why the docs page needs Step 8's explicit verification.

The one thing to stop for is `name-matches-dir` failing — that means the directory name and the frontmatter `name:` have drifted, and every later check inherits the error.

- [ ] **Step 3: Write the Codex metadata**

Create `skills/engineering/port-from-repo/agents/openai.yaml` with exactly this content:

```yaml
interface:
  display_name: "Port From Repo"
  short_description: "Adapt a feature in from another codebase"
policy:
  allow_implicit_invocation: false
```

The `policy` block is required: it pairs with `disable-model-invocation: true` in the frontmatter, and `skillcheck.py` asserts the pairing as `invocation-mode-consistency`.

- [ ] **Step 4: Add both README entries**

In `skills/engineering/README.md`, under `## User-invoked`, add this entry at the end of that section's list:

```markdown
- **[port-from-repo](./port-from-repo/SKILL.md)** — Bring a capability across from another codebase — study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.
```

In the top-level `README.md`, under `### Engineering` → `**User-invoked**`, add this entry at the end of that section's list:

```markdown
- **[port-from-repo](./skills/engineering/port-from-repo/SKILL.md)** — Bring a capability across from another codebase — study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.
```

The two link paths differ because the files sit at different depths. `skillcheck.py` matches the top-level entry against the exact pattern `[port-from-repo](./skills/engineering/port-from-repo/SKILL.md)`, so the path must be written exactly as above.

- [ ] **Step 5: Verify README membership now passes**

Run: `python3 scripts/harness/skillcheck.py . 2>&1 | tail -3`

Expected: `PASS`, with a total above 476. If `readme-membership` or `bucket-readme-lists-skill` still fails, the link path does not match the expected pattern character-for-character.

- [ ] **Step 6: Hunt for real docs-page questions before writing the page**

`.agents/writing-docs.md` requires the question hunt to run before `## Common questions` is written, and requires the section be sized to what the hunt found rather than padded.

Run all three:

```bash
ls ~/repos/matt/personal-wiki 2>/dev/null || echo "no wiki on this machine — skip that source"
gh issue list --repo osxsystem/skills --search "port" --state all --limit 20
grep -rin "port\b" CHANGELOG.md | head -20
```

`port-from-repo` is fork-local and brand new, so expect the hunt to come up thin — do not search `mattpocock/skills`, which has never had this skill. Add any question the hunt actually surfaces to the section written in Step 7; write no invented questions to pad it out.

- [ ] **Step 7: Write the docs page**

Create `docs/engineering/port-from-repo.md` with this content, appending any questions Step 6 surfaced to `## Common questions`:

```markdown
## What it does

Takes a capability you have seen working in another codebase and brings it into this one: read the source, argue about whether you want it, place it behind a seam that fits here, then build it test-first.

It never pastes. The code is rewritten in this codebase's idiom, because the version you are reading was shaped by constraints that are not yours — its dependency graph, its error convention, its platform assumptions. What crosses over is the approach, not the expression.

## When to reach for it

You invoke this by typing `/port-from-repo` — the agent won't reach for it on its own.

| Situation | Reach for |
|---|---|
| Another repo solves a problem you have, and you want that capability here | `/port-from-repo` |
| You want to understand how another project works, with no intention of building | [research](https://aihero.dev/skills-research) |
| You know what to build already and no other codebase is involved | [implement](https://aihero.dev/skills-implement) |
| You want the whole project, not a capability from it | Neither — clone it |

## Prerequisites

The source repository must be readable — a public GitHub URL, an `owner/repo` you have access to, or a local path. It is fetched outside this repository and never modified.

## Adapt, don't transplant

The leading idea, and the one the whole skill turns on. A transplant moves the code; an adaptation moves the insight and rewrites the rest.

The tell that you are transplanting rather than adapting: the diff reads as imported. Foreign naming, an error convention that appears nowhere else, a dependency added because the source had it. That code works and still makes the codebase worse, because the next person to read it has to hold two idioms in their head.

Most of what you are looking at is plumbing. The skill's understand phase exists to make you name the part that is not, before you decide anything.

## The challenge phase

Between reading the source and writing any code, the skill runs [grilling](https://aihero.dev/skills-grilling) on a single question: should we bring this over at all?

It is the step people skip, and the reason ports go wrong. The four questions it pushes on — what is the smallest thing that solves our problem, what do we already have that overlaps, which of the source's constraints are we inheriting, what happens if we do nothing — routinely cut the scope to a fraction of what the source built.

## Common questions

**Does it copy the source's code?**
No. It retypes in this codebase's idiom, deliberately. Retyping is what surfaces the assumptions that don't hold here — a paste hides them until something breaks.

**What if the source has an incompatible licence?**
Check before you start. The skill ports an approach rather than an expression, which is the safer footing, but a licence that restricts derivative work is a reason not to proceed — raise it rather than working around it.

**How does this differ from just asking the agent to copy a file?**
The challenge phase. A copy answers "can we have this?"; the skill answers "do we want this, and in what shape?" — and the answer is often a smaller thing than the source built.

## It's working if

- You can state what the ported capability does without referring to the source's code.
- The scope shrank during the challenge phase — you are building less than the source did.
- Reading the diff cold, nothing marks it as imported.
- The commit message names the source repository and the commit it came from.

## Where it fits

An **on-ramp**: a starting situation that generates work and then merges onto the main flow. It ends where [implement](https://aihero.dev/skills-implement) and [code-review](https://aihero.dev/skills-code-review) do, having driven [tdd](https://aihero.dev/skills-tdd) to build each slice.

Its neighbours are [research](https://aihero.dev/skills-research), because reading another codebase to answer a question is research and stops there, and [codebase-design](https://aihero.dev/skills-codebase-design), because deciding where the ported capability sits is a seam decision in this codebase rather than a copy of the source's. On a Kotlin Multiplatform codebase it hands the `expect`/`actual` versus interface-plus-DI call to [kmp-module-setup](../../skills/mobile/kmp-module-setup/SKILL.md).

For the whole map, see [ask-matt](https://aihero.dev/skills-ask-matt).
```

The `kmp-module-setup` link is repo-relative on purpose: the `mobile/` bucket is fork-local and aihero.dev never hosts it. `.agents/writing-docs.md` names this exception explicitly.

- [ ] **Step 8: Verify the docs page has all four required sections**

Run: `python3 scripts/harness/skillcheck.py . 2>&1 | tail -3`

Expected: `PASS`. The `docs-page-sections` check asserts `## What it does`, `## When to reach for it`, `## Common questions`, and `## It's working if` are all present.

- [ ] **Step 9: Verify no link in the new files is broken**

Run:

```bash
python3 scripts/harness/skillcheck.py . --json | python3 -c "import json,sys; rows=json.load(sys.stdin); print([r for r in rows if r['check']=='links-resolve' and r['status']!='PASS'] or 'all links resolve')"
```

Expected: `all links resolve`.

- [ ] **Step 10: Commit**

```bash
git add skills/engineering/port-from-repo docs/engineering/port-from-repo.md skills/engineering/README.md README.md
git commit -m "feat(skills): add port-from-repo

Brings a capability across from another codebase without bringing its
architecture with it. Delegates its challenge phase to /grilling, seam
placement to /codebase-design, the build to /tdd, and close-out to
/code-review, so the skill stays small.

Re-authored from ClaudeKit's xia, renamed because that name is undefined
anywhere in its source tree."
```

---

### Task 2: `when-stuck` — beta skill in `in-progress/`

Lighter registration than Task 1: no docs page, no top-level README entry, no router route. It is also the **first model-invoked skill in `in-progress/`** — all six existing ones are user-invoked (verified) — so it is the first entry in that bucket to join the confusable-description comparison set.

**Files:**
- Create: `skills/in-progress/when-stuck/SKILL.md`
- Create: `skills/in-progress/when-stuck/agents/openai.yaml`
- Modify: `skills/in-progress/README.md`
- Test: `python3 scripts/harness/skillcheck.py .` and `python3 scripts/check-confusable-skills.py .`

**Interfaces:**
- Consumes: nothing from Task 1. The two skills are independent and this task can run first if a reviewer prefers.
- Produces: a model-invoked skill named `when-stuck` in the `in-progress` bucket. Task 3 deliberately does **not** route to it.

- [ ] **Step 1: Write the skill**

Create `skills/in-progress/when-stuck/SKILL.md` with exactly this content:

```markdown
---
name: when-stuck
description: Techniques for design and architecture stuck-ness. Use when a design keeps sprouting special cases, when every option feels forced, or when the same problem recurs in different places.
---

# When stuck

Five ways to re-frame a design problem that will not resolve. Each one is a move, not a mood: pick by symptom, make the move, see what it exposes.

**This is for design and architecture stuck-ness only.** Two neighbours own the other kinds, and reaching for this one instead wastes the session:

| What is stuck | Use |
|---|---|
| A bug you cannot reproduce or explain | the `/diagnosing-bugs` skill |
| A plan or decision you have not settled | the `/grilling` skill |
| The *shape* of a solution — it won't resolve, or every option feels wrong | this skill |

## Inversion

**Reach for it when** you catch yourself saying it has to be done this way, or the design feels forced but you cannot say why.

State the load-bearing assumption out loud, then negate it and design from the negation. You are not looking for the inverted design to win — you are looking for what the negation exposes about the original.

*Worked example.* "Every request has to hit the cache first." Inverted: nothing is cached. What breaks? If the honest answer is "one endpoint gets slow", the cache was never the architecture — it was one endpoint's optimisation, and modelling it as a layer was the mistake.

## The scale game

**Reach for it when** you cannot tell whether a design holds up, or "it depends" is the only answer you can give about load.

Run the design at three sizes: zero, one, and a million. Designs break at the extremes in ways the middle hides.

*Worked example.* A sync engine that reconciles on every change. At zero changes it does nothing — fine. At one, it is obviously correct. At a million it is a thundering herd, and you learn the design's real dependency is batching, which was nowhere in the diagram.

## Simplification cascade

**Reach for it when** the same idea is implemented several ways, special cases keep accreting, or every fix adds a branch.

Stop looking for the change that handles the next case. Look for the one change that **deletes components** — the reframing after which several of the special cases stop existing rather than getting handled.

*Worked example.* Four code paths for four auth providers, each with its own refresh quirk. The cascade is not a fifth path; it is noticing that three of the four differ only in token lifetime, which turns three paths into one path with a parameter.

## Meta-pattern

**Reach for it when** this feels like a problem you have solved before somewhere else, or the same shape keeps recurring in unrelated parts of the system.

Find three instances and name what they share. Naming the shape is the work — an unnamed recurring pattern gets re-solved from scratch every time it appears.

*Worked example.* Retry-with-backoff in the uploader, debounce in the search box, and rate-limiting on the API client are three faces of "an operation whose timing is governed by feedback from its own failures". Named, they can share one abstraction; unnamed, they stay three.

## Collision

**Reach for it when** every conventional option is inadequate and you need something you have not thought of yet.

Force two unrelated concepts together and take the result seriously for a few minutes before rejecting it. Most collisions produce nothing; the technique is cheap enough that this is fine.

*Worked example.* "What if the migration were a test?" is nonsense until you notice both are things you run once against a known starting state and assert an ending state — and now the migration has a dry-run mode it did not have before.

## Done when

You have a move to make, not a summary of your situation. If the session ends with a restatement of the problem, the technique did not fire — pick a different one rather than describing the stuck-ness more carefully.

---

Derived from the problem-solving agent patterns in [Microsoft Amplifier](https://github.com/microsoft/amplifier) (MIT), commit `2adb63f858e7d760e188197c8e8d4c1ef721e2a6`.
```

- [ ] **Step 2: Write the Codex metadata**

Create `skills/in-progress/when-stuck/agents/openai.yaml` with exactly this content:

```yaml
interface:
  display_name: "When Stuck"
  short_description: "Techniques for design stuck-ness"
```

There is **no** `policy` block. This skill is model-invoked, and adding `allow_implicit_invocation: false` without `disable-model-invocation` in the frontmatter fails `invocation-mode-consistency`.

- [ ] **Step 3: Run the confusable check before anything else depends on the description**

Run: `python3 scripts/check-confusable-skills.py .`

Expected: `40 skills: 20 model-invoked, 20 user-invoked (excluded)` then `PASS — no pair at or above 0.80`.

The description above was measured against its nearest neighbours before being written into this plan: `diagnosing-bugs` **0.000**, `grilling` **0.000**, `codebase-design` **0.023**, `prototype` **0.053**. The threshold is 0.80, so there is wide headroom — but re-run it here, because this is the first model-invoked skill in `in-progress/` and the first pair in the repo's history with a plausible route to the threshold. If a pair does flag, change *this* description rather than an existing skill's.

- [ ] **Step 4: Add the bucket README entry**

In `skills/in-progress/README.md`, add this entry at the end of the list:

```markdown
- **[when-stuck](./when-stuck/SKILL.md)** — Five techniques for design and architecture stuck-ness: inversion, the scale game, simplification cascades, meta-patterns, collision.
```

The list is flat — `in-progress/` is not a promoted bucket, so it carries no **User-invoked** / **Model-invoked** headings. Do not append a "User-invoked." marker: this skill is model-invoked.

- [ ] **Step 5: Verify the harness, including that the beta skill stayed out of the top-level README**

Run: `python3 scripts/harness/skillcheck.py . 2>&1 | tail -3`

Expected: `PASS`.

Then confirm the inverted check specifically:

```bash
python3 scripts/harness/skillcheck.py . --json | python3 -c "import json,sys; rows=json.load(sys.stdin); print([ (r['check'],r['status'],r.get('notes','')) for r in rows if r.get('skill')=='when-stuck' ])"
```

Expected: `readme-membership` PASS (it passes *because* the skill is absent from the top-level README), `bucket-readme-lists-skill` PASS, and **no** `docs-page-sections`, `bucket-readme-grouping`, or `ask-matt-mentions-skill` rows at all — those three are gated on promoted buckets.

- [ ] **Step 6: Commit**

```bash
git add skills/in-progress/when-stuck skills/in-progress/README.md
git commit -m "feat(skills): add when-stuck to in-progress

Five techniques for design-level stuck-ness, scoped away from bugs
(/diagnosing-bugs) and undecided plans (/grilling) so the router and the
confusable check both stay clean.

Beta placement is deliberate: it graduates to productivity/ only if the
team reaches for it. Derived from Microsoft Amplifier (MIT)."
```

---

### Task 3: Re-sync the router, record the fork addition, and re-link

`CLAUDE.md` makes the router a rule: a new user-reachable skill it never mentions is a router that lies. This task also fixes a stale count `ask-matt` already carries, independent of this plan's work.

**Files:**
- Modify: `skills/engineering/ask-matt/SKILL.md:11` and its `## On-ramps` section
- Modify: `MAINTENANCE.md` (the "What the fork adds" table)
- Create: `.changeset/second-pass-adoptions.md`
- Test: `python3 scripts/harness/skillcheck.py .`, then `bash scripts/link-skills.sh`

**Interfaces:**
- Consumes: the skill name `port-from-repo` from Task 1. This task must run after Task 1; it does not depend on Task 2.
- Produces: nothing later tasks consume — this is the final task.

- [ ] **Step 1: Fix the stale on-ramp count**

`skills/engineering/ask-matt/SKILL.md` line 11 currently claims two on-ramps while the `## On-ramps` section already lists three (`/triage`, `/diagnosing-bugs`, `/wayfinder`). This plan makes it four, so replace the enumeration with a form that does not go stale.

Replace this line:

```markdown
A **flow** is a path through the skills. Most paths run along one **main flow**, and two **on-ramps** merge onto it. Everything else is standalone, or one of two layers that run underneath: **vocabulary**, and **platform knowledge**.
```

with:

```markdown
A **flow** is a path through the skills. Most paths run along one **main flow**, and several **on-ramps** merge onto it. Everything else is standalone, or one of two layers that run underneath: **vocabulary**, and **platform knowledge**.
```

- [ ] **Step 2: Add the on-ramp**

In the `## On-ramps` section, add this entry after the `/wayfinder` entry (which ends with the paragraph beginning "When the map clears"):

```markdown
- **Another codebase already solved this** → **`/port-from-repo`**. You saw a capability working somewhere else — an open-source project, a sample app, another repo of your own — and you want it here. It reads the source as a **primary source**, then runs `/grilling` on the question *should we bring this over at all*, which routinely cuts the scope to a fraction of what the source built. What survives merges onto the main flow at `/implement`, driving `/tdd` per slice.

  **Adapt, don't transplant** is the whole discipline: what crosses over is the approach, not the expression, because the source's dependency graph, error convention and platform assumptions are not yours. Reach for **`/research`** instead when you want to understand another codebase with no intention of building from it.
```

- [ ] **Step 3: Verify the router check passes**

Run: `python3 scripts/harness/skillcheck.py . 2>&1 | tail -3`

Expected: `PASS`. Two checks are load-bearing here — `ask-matt-mentions-skill` (every promoted skill has a route) and `ask-matt-no-stale-routes` (every route points at a skill that exists).

Then confirm `when-stuck` was correctly left out:

```bash
grep -c 'when-stuck' skills/engineering/ask-matt/SKILL.md
```

Expected: `0`. A route to a beta skill is a router that promises something the top-level README does not list.

- [ ] **Step 4: Record both skills in `MAINTENANCE.md`**

In the "What the fork adds" table, insert this row immediately before the `MAINTENANCE.md` row:

```markdown
| `skills/engineering/port-from-repo/`, `skills/in-progress/when-stuck/` | Fork additions re-authored from external patterns (ClaudeKit's `xia`; Microsoft Amplifier via ClaudeKit's `problem-solving`). Not upstream skills — an upstream sync must not drop them. See [the adoption spec](./docs/superpowers/specs/2026-08-10-claudekit-adoption-design.md). |
```

This is the record that stops a future sync from mistaking either skill for upstream content.

- [ ] **Step 5: Write the changeset**

Create `.changeset/second-pass-adoptions.md` with exactly this content:

```markdown
---
"osxsystem-skills": patch
---

Two new skills, from a second pass over ClaudeKit's catalogue.

`port-from-repo` (engineering, user-invoked) brings a capability across from
another codebase without bringing its architecture with it — understand,
challenge, adapt, verify. It delegates four of those phases to skills this repo
already owns, so it stays small: `/grilling` for the challenge, `/codebase-design`
for the seam, `/tdd` for the build, `/code-review` for close-out.

`when-stuck` (in-progress, model-invoked) collects five techniques for
design-level stuck-ness — inversion, the scale game, simplification cascades,
meta-patterns, collision — scoped away from bugs and undecided plans so it
doesn't compete with `/diagnosing-bugs` or `/grilling`.

`ask-matt` gains an on-ramp for `port-from-repo`, and its opening line stops
claiming a fixed number of on-ramps now that there are four.
```

- [ ] **Step 6: Re-link the local harness skill directories**

Run: `bash scripts/link-skills.sh`

Expected: the script reports the new symlinks. Then verify both landed:

```bash
ls -l ~/.claude/skills/port-from-repo ~/.claude/skills/when-stuck 2>&1
```

Expected: two symlinks pointing into this repository. This is a local-machine effect only — nothing in the repo changes.

- [ ] **Step 7: Run the full gate one last time**

Run all three, exactly as CI does:

```bash
python3 scripts/harness/skillcheck.py .
bash scripts/harness/test_guardrail.sh .
python3 scripts/check-confusable-skills.py .
```

Expected: `PASS` from each. The skill count reads **41 skills** and the assertion total lands near **560** — the gate is `PASS`, not the number.

- [ ] **Step 8: Run the retrieval test on both new skills**

`CUSTOMIZING.md` prescribes this and it is the only check that tests whether the skills actually *work*, as opposed to being structurally valid.

For each of the two skills, dispatch a subagent that may read **only** that skill's directory, and ask it four realistic task questions. For `port-from-repo`: "I want the offline-sync behaviour from github.com/example/app — what do you do first?", "The source uses a DI framework we don't have. What now?", "It's Android-only and we need it in commonMain — what changes?", "When are you done?" For `when-stuck`: "Our auth code has four near-identical paths and every fix adds a branch — which technique?", "I can't reproduce a flaky test — which technique?" (correct answer: none of them, use `/diagnosing-bugs`), "What does the scale game actually ask me to do?", "When has a technique failed?"

Any gap or wrong answer is a bug in the skill, to fix before shipping — not a note for later.

- [ ] **Step 9: Commit**

```bash
git add skills/engineering/ask-matt/SKILL.md MAINTENANCE.md .changeset/second-pass-adoptions.md
git commit -m "feat(skills): route ask-matt to port-from-repo

Adds the on-ramp for port-from-repo and replaces the opening line's fixed
on-ramp count, which was already stale before this plan — it claimed two
while the section listed three.

when-stuck is deliberately absent: in-progress/ skills carry no router
route and no top-level README entry.

Records both skills in MAINTENANCE.md so an upstream sync doesn't mistake
them for upstream content."
```

---

## Verification

The plan is complete when all three gates pass together and both skills survive the retrieval test:

| Gate | Command | Expected |
|---|---|---|
| Structural | `python3 scripts/harness/skillcheck.py .` | `PASS`, ~560 assertions over 41 skills |
| Guardrail | `bash scripts/harness/test_guardrail.sh .` | `PASS`, 39 cases |
| Description drift | `python3 scripts/check-confusable-skills.py .` | `PASS`, 20 model-invoked compared, no pair ≥ 0.80 |
| Retrieval | Subagent per skill, skill directory only | Four realistic questions answered correctly, including the one whose right answer is "use a different skill" |

Baseline before this plan, for comparison: 476 assertions over 39 skills, 19 model-invoked, highest pair 0.185.
