---
type: skill-audit
date: 2026-09-04
issue: skills-3mp
scope: all 58 skills under skills/
---

# Skill audit: trigger, payload, and portfolio

## Executive summary

**Overall grade: B.** The collection is strong on structure and unusually good at defining specialist workflows. The weighted mean is 4.26/5, and 50 of 58 skills score at least 4.00. That number overstates release readiness. Four core workflow skills can exceed the user's authority, three payloads name capabilities that do not exist, adjacent writing skills still need sharper picker boundaries, and the only automated trigger test is lexical rather than behavioral.

The five findings that matter most:

1. **Green structure hides red behavior.** `skillcheck.py` reports 691/691 PASS, `forkcheck.py` reports 7/7 PASS, and the guardrail suite reports 39/39 PASS. Those checks prove packaging, registration, link resolution, and one hook's behavior. They do not prove that a skill fires correctly or that an agent follows it. The repo contains no routing or end-to-end skill eval fixtures.
2. **Authority boundaries are not encoded consistently.** `diagnosing-bugs` enters a fix phase after a diagnosis-only trigger, `implement` and `resolving-merge-conflicts` require commits, and `do-test` proposes `git stash` or reverting an active file to reconstruct a pre-fix state. These are workflow bugs, not style nits.
3. **The router and several payloads point at missing or omitted skills.** `ask-matt` says there are five KMP references but there are seven. `cook` calls `html-design-to-compose` and `simplify`, neither of which exists. `show-me` and `do-test` call `codebase-retrieval`, which also does not exist.
4. **The trigger system has semantic collisions that the lexical check cannot see.** The current Jaccard check reports a harmless maximum of 0.185, yet `writing-beats` and `writing-shape` share the same exploit and grounding frame while differing mainly by unit of composition, `claude-handoff` is `handoff` plus launch, and the implementation family has three competing entry points.
5. **Token discipline is uneven.** The best skills keep the route in the main file and push branch detail behind explicit pointers. The worst counterexample is `improve-claude-md`: 254 body lines, a 124-line worked example, and no retained evidence that its central XML technique changes model behavior.

### Score distribution

| Weighted range | Count | Meaning |
|---|---:|---|
| 4.50 to 5.00 | 18 | Strong patterns to preserve |
| 4.00 to 4.49 | 32 | Good, usually with one bounded defect |
| 3.00 to 3.99 | 7 | Usable but materially unreliable or wasteful |
| 2.00 to 2.99 | 0 | No skills in this band |
| Below 2.00 | 1 | Remove or quarantine |

### Scoring interpretation

The dimensions and weights are the ones in the audit brief: trigger 25%, actionability 25%, token economy 15%, correctness 15%, structure 10%, and scope/portability 10%. A 5 is exemplary, 4 is good, 3 is usable with a material defect, 2 is weak, and 1 is broken or actively misleading.

This repo has 26 user-invoked skills. Their descriptions are picker copy rather than model triggers, by `.agents/invocation.md:3-5` ("reachable only by the human" and "human-facing"). I therefore score those descriptions for human selection and sibling disambiguation. Penalizing them for omitting model trigger phrases would contradict the repository's invocation contract.

## Evidence and method

- Inventory source: every `skills/**/SKILL.md` found by `rg`, 58 files and 4,664 total lines.
- Structural evidence: `python3 scripts/harness/skillcheck.py --json` returned 691 PASS and no failures.
- Fork evidence: `python3 scripts/harness/forkcheck.py` returned 7 PASS. Its fail-closed suite returned 26 PASS and no failures.
- Trigger evidence: `python3 scripts/check-confusable-skills.py` evaluated 32 model-invoked descriptions, excluded 26 user-invoked descriptions by design, and reported maximum token Jaccard similarity 0.185.
- Functional evidence: `bash scripts/harness/test_guardrail.sh` returned 39 PASS and no failures.
- Time-sensitive KMP claims were checked against current primary sources: [Kotlin 2.4.10 releases](https://kotlinlang.org/docs/releases.html), [Compose Multiplatform 1.11.1 changes](https://kotlinlang.org/docs/multiplatform/whats-new-compose-111.html), [AGP 9 migration](https://kotlinlang.org/docs/multiplatform/multiplatform-project-agp-9-migration.html), [Ktor retry ordering](https://ktor.io/docs/client-request-retry.html), and [Kotlin to Swift exception interop](https://kotlinlang.org/docs/native-objc-interop.html).
- Current package docs also confirm the basic Shoehorn API and Husky v9 setup: [Shoehorn README](https://github.com/total-typescript/shoehorn) and [Husky get started](https://typicode.github.io/husky/get-started.html).
- Semantic claims below cite the current repository as `path:line` with a short quote. Scores are static-review assurance only. No score is represented as a live-fire result.

## Phase 0: inventory

No skill has missing frontmatter, an empty body, a duplicate name, a non-kebab-case directory name, or a description longer than 1,024 characters. Every skill has `agents/openai.yaml`. "Other skills referenced" below is name-based and includes explicit missing names where the payload depends on them.

| Skill | Purpose from body | Desc words | Body lines | Supporting files | Other skills referenced |
|---|---|---:|---:|---|---|
| `ask-matt` | Route a user to the right skill or multi-skill flow. | 16 | 100 | `openai.yaml`, `references/phase-boundaries.md`, `references/platform-knowledge.md` | `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-with-docs`, `implement`, `improve-codebase-architecture`, `prototype`, `research`, `resolving-merge-conflicts`, `tdd`, `to-spec`, `to-tickets`, `triage`, `wayfinder`, `wizard`, `to-prd`, `compose-multiplatform-ui`, `kmp-ios-integration`, `kmp-module-setup`, `kmp-release-and-publish`, `kmp-test-seams`, `port-from-repo`, `setup-osxsystem-skills`, `use-git-worktree`, `unslop`, `retro`, `grill-me`, `grilling`, `handoff`, `teach`, `to-questionnaire`, `wait-what`, `writing-for-agents` |
| `code-review` | Review a diff separately against repository standards and its source spec. | 69 | 83 | `openai.yaml` | `implement`, `setup-osxsystem-skills` |
| `codebase-design` | Supply deep-module vocabulary and interface design heuristics. | 40 | 110 | `DEEPENING.md`, `DESIGN-IT-TWICE.md`, `openai.yaml` | None |
| `diagnosing-bugs` | Build a tight reproduction loop, isolate a cause, then fix and regress it. | 23 | 134 | `openai.yaml`, `scripts/hitl-loop.template.sh` | None |
| `domain-modeling` | Sharpen domain language and capture glossary terms and ADRs. | 24 | 70 | `ADR-FORMAT.md`, `CONTEXT-FORMAT.md`, `openai.yaml` | None |
| `grill-with-docs` | Invoke grilling and domain-modeling together so interview decisions become repo docs. | 19 | 2 | `openai.yaml` | `domain-modeling`, `grilling` |
| `implement` | Implement tickets or a spec with TDD, checks, review, and a commit. | 13 | 10 | `openai.yaml` | `code-review`, `tdd` |
| `improve-codebase-architecture` | Find deepening opportunities and present them visually before design grilling. | 20 | 66 | `HTML-REPORT.md`, `openai.yaml` | `codebase-design`, `domain-modeling`, `grilling` |
| `prototype` | Build throwaway logic or UI code that answers one design question. | 32 | 22 | `LOGIC.md`, `UI.md`, `openai.yaml` | None |
| `research` | Delegate primary-source research and save a cited Markdown note. | 39 | 8 | `openai.yaml` | None |
| `resolving-merge-conflicts` | Resolve an active merge or rebase by intent and finish it. | 12 | 10 | `openai.yaml` | None |
| `tdd` | Drive one behavior at a time through a red-green test loop at agreed seams. | 20 | 34 | `mocking.md`, `openai.yaml`, `tests.md` | `code-review`, `codebase-design` |
| `to-spec` | Synthesize conversation and codebase context into a tracker-published spec. | 24 | 70 | `openai.yaml` | `prototype`, `triage`, `setup-osxsystem-skills` |
| `to-tickets` | Split a plan into dependency-aware tracer-bullet tickets. | 41 | 100 | `openai.yaml` | `prototype`, `triage`, `setup-osxsystem-skills` |
| `triage` | Move issues and external PRs through a configured triage state machine. | 21 | 107 | `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md`, `openai.yaml` | `domain-modeling`, `setup-osxsystem-skills`, `grilling` |
| `wayfinder` | Map a multi-session unknown as decision tickets and resolve its frontier. | 39 | 123 | `openai.yaml` | `domain-modeling`, `prototype`, `research`, `setup-osxsystem-skills`, `grilling` |
| `wizard` | Generate a guided shell script for steps only a human can perform. | 47 | 40 | `openai.yaml`, `template.sh` | None |
| `cook` | Run an implementation pipeline from intent through finalization. | 29 | 77 | `README.md`, `openai.yaml`, `references/intent-detection.md`, `references/review-cycle.md`, `references/workflow-steps.md` | `code-review`, `implement`, `research`, `tdd`, `project-organization`, `compose-multiplatform-ui`, `do-test`, `html-design-to-compose` (missing), `simplify` (missing) |
| `project-organization` | Choose project paths, names, nesting, and document templates. | 23 | 112 | `openai.yaml`, `references/directory-patterns.md`, `references/markdown-body-templates.md`, `references/naming-conventions.md` | `research` |
| `to-prd` | Synthesize an initiative-level PRD, ask only genuine gaps, then link it from the tracker. | 27 | 81 | `openai.yaml` | `domain-modeling`, `grill-with-docs`, `implement`, `prototype`, `research`, `to-spec`, `to-tickets`, `setup-osxsystem-skills`, `grilling` |
| `bro` | Restate the preceding message in concise human language without jargon. | 11 | 2 | `openai.yaml` | None |
| `ddd` | Run strategic or full domain-driven design discovery and return model artifacts. | 115 | 208 | `ARTIFACTS.md`, `openai.yaml` | `domain-modeling`, `show-me`, `grilling` |
| `improve-claude-md` | Rewrite CLAUDE.md around conditional `important-if` XML blocks. | 13 | 254 | `openai.yaml` | None |
| `show-me` | Compress a topic into a small truthful visual and expose a simpler shape. | 54 | 125 | `openai.yaml` | `codebase-design`, `improve-codebase-architecture`, `when-stuck`, `codebase-retrieval` (missing) |
| `compose-multiplatform-ui` | Guide shared Compose UI and iOS-specific integration choices. | 79 | 95 | `openai.yaml`, `reference.md` | `wizard`, `kmp-boundaries`, `kmp-ios-integration`, `kmp-module-setup` |
| `kmp-boundaries` | Design narrow common-to-platform capability seams in KMP. | 70 | 113 | `openai.yaml` | `compose-multiplatform-ui`, `kmp-ios-integration`, `kmp-ktor` |
| `kmp-ios-integration` | Connect a KMP framework to Xcode and shape Swift-facing Kotlin APIs. | 51 | 52 | `cocoapods-reference.md`, `interop-reference.md`, `openai.yaml` | `wizard` |
| `kmp-ktor` | Handle Ktor client configuration traps, auth refresh, error mapping, and tests. | 35 | 109 | `openai.yaml` | `kmp-boundaries`, `kmp-test-seams` |
| `kmp-module-setup` | Configure KMP targets, source sets, versions, frameworks, and abstractions. | 39 | 67 | `openai.yaml`, `reference.md` | None |
| `kmp-release-and-publish` | Ship KMP apps and libraries and divide their CI workload. | 51 | 55 | `openai.yaml`, `reference.md` | None |
| `kmp-test-seams` | Choose KMP test source sets, seams, and the cheapest proving task. | 43 | 8 | `openai.yaml` | `tdd`, `kmp-module-setup`, `kmp-release-and-publish` |
| `herdr` | Inspect and control Herdr workspaces, panes, terminals, and coding agents. | 52 | 191 | `openai.yaml` | None |
| `port-from-repo` | Adapt a capability from another repository without copying its architecture. | 23 | 77 | `openai.yaml` | `code-review`, `codebase-design`, `tdd`, `kmp-module-setup`, `grilling` |
| `setup-osxsystem-skills` | Write the tracker, triage, and domain-doc configuration other skills consume. | 29 | 111 | `domain.md`, `issue-tracker-github.md`, `issue-tracker-gitlab.md`, `issue-tracker-local.md`, `openai.yaml`, `triage-labels.md` | `to-spec`, `to-tickets`, `triage` |
| `sync-upstream` | Merge upstream skill changes using the fork divergence playbook. | 33 | 93 | `openai.yaml` | `ask-matt`, `research`, `resolving-merge-conflicts`, `triage`, `setup-osxsystem-skills` |
| `use-git-worktree` | Create and enter an isolated feat/fix worktree safely. | 84 | 72 | `openai.yaml` | `implement` |
| `when-stuck` | Apply one of five reframing moves to an architecture design impasse. | 28 | 62 | `openai.yaml` | `codebase-design`, `diagnosing-bugs`, `grilling` |
| `do-test` | Derive a test matrix and return a verdict backed by observed evidence. | 43 | 90 | `openai.yaml`, `references/report-format.md`, `references/test-matrix.md`, `references/triage.md`, `references/ui-surface.md` | `code-review`, `implement`, `triage`, `cook`, `project-organization`, `codebase-retrieval` (missing, in support file) |
| `unslop` | Remove AI prose tells without erasing claims or voice. | 82 | 125 | `openai.yaml`, `references/tells.md`, `scripts/check-tells.py` | `writing-fragments`, `writing-shape`, `writing-for-agents` |
| `claude-handoff` | Launch a fresh background Claude session seeded with a handoff summary. | 16 | 12 | `openai.yaml` | `handoff` |
| `implement-spec` | Parallelize a full spec across ticket worktrees and merge into one PR. | 5 | 30 | `openai.yaml` | `code-review`, `implement`, `research` |
| `loop-me` | Grill recurring life loops into implementable workflow specs stored in the workspace. | 14 | 26 | `openai.yaml` | `grilling` |
| `retro` | Review a coding session for improvements to the agent environment. | 7 | 39 | `openai.yaml` | `writing-for-agents` |
| `setup-ts-deep-modules` | Enforce TypeScript package entry-point boundaries with dependency-cruiser. | 26 | 97 | `dependency-cruiser.config.cjs`, `openai.yaml` | `codebase-design` |
| `writing-beats` | Assemble fixed raw material into a user-chosen sequence of beats. | 19 | 62 | `openai.yaml` | None |
| `writing-fragments` | Mine an interview into an append-only file of unstructured writing fragments. | 8 | 74 | `openai.yaml` | `grilling` |
| `writing-shape` | Shape fixed raw material into an article one agreed block at a time. | 11 | 74 | `openai.yaml` | `grilling` |
| `git-guardrails-claude-code` | Install and verify a Claude hook that blocks destructive Git commands. | 41 | 95 | `openai.yaml`, `scripts/block-dangerous-git.sh` | None |
| `migrate-to-shoehorn` | Replace test-only TypeScript assertions with Shoehorn helpers. | 26 | 114 | `openai.yaml` | None |
| `scaffold-exercises` | Create and lint the directory structure for AI Hero course exercises. | 30 | 102 | `openai.yaml` | None |
| `setup-pre-commit` | Install Husky, lint-staged, Prettier, typecheck, and test hooks. | 35 | 87 | `openai.yaml` | None |
| `grill-me` | Alias a user-invoked grill command to the grilling primitive. | 9 | 2 | `openai.yaml` | `grilling` |
| `grilling` | Interview through the frontier of a dependency-aware decision tree. | 25 | 24 | `openai.yaml` | None |
| `handoff` | Write a redacted, pointer-heavy conversation handoff in the OS temp directory. | 14 | 10 | `openai.yaml` | None |
| `teach` | Maintain a multi-session teaching workspace of lessons, records, references, and assets. | 11 | 134 | `GLOSSARY-FORMAT.md`, `LEARNING-RECORD-FORMAT.md`, `MISSION-FORMAT.md`, `RESOURCES-FORMAT.md`, `openai.yaml` | None |
| `to-questionnaire` | Turn a knowledge gap into a questionnaire for the person who can answer it. | 16 | 49 | `openai.yaml` | None |
| `wait-what` | Re-pitch the previous answer in controlled plain language. | 9 | 2 | `openai.yaml` | None |
| `writing-for-agents` | Define how to structure pointers and instructions that agents consume. | 17 | 77 | `SKILL-MECHANICS.md`, `openai.yaml` | None |

### Unusual or important traits

Invocation mode is included here because it changes how trigger quality must be judged.

| Skill | Invocation | Unusual or important trait |
|---|---|---|
| `ask-matt` | User | Portfolio router with two disclosed route references; its KMP inventory is stale. |
| `code-review` | Model or user | Requires two parallel review agents and keeps Standards and Spec findings separate. |
| `codebase-design` | Model or user | Reference vocabulary rather than an end-to-end workflow. |
| `diagnosing-bugs` | Model or user | Six-phase workflow with a human-in-the-loop script; diagnosis currently flows into fixing. |
| `domain-modeling` | Model or user | Owns two durable artifact types, glossary and ADR. |
| `grill-with-docs` | User | Two-line composition wrapper over `grilling` and `domain-modeling`. |
| `implement` | User | Ten-line wrapper that ends with an unconditional commit. |
| `improve-codebase-architecture` | User | Produces a temporary visual HTML comparison before the user chooses a seam. |
| `prototype` | Model or user | Routes to separate logic and UI playbooks, then preserves the experiment off main. |
| `research` | Model or user | Always delegates to a background agent and always writes a Markdown artifact. |
| `resolving-merge-conflicts` | Model or user | Five-step flat recipe that forbids abort and requires finishing the Git operation. |
| `tdd` | Model or user | Description says red-green-refactor while the body explicitly removes refactor from the loop. |
| `to-spec` | User | Promises no interview but still requires a user confirmation of test seams before tracker publication. |
| `to-tickets` | User | Represents blocking edges in either native tracker relationships or local per-ticket files. |
| `triage` | User | Requires a disclaimer on every external tracker write and models category and state roles separately. |
| `wayfinder` | User | Limits normal work to one decision ticket per session and treats the tracker as shared map. |
| `wizard` | Model or user | Generates a human-operated Bash program from a fixed library template and does not execute it end to end. |
| `cook` | Model or user | Fork orchestration hub with five modes, hard gates, and two unresolved skill dependencies. |
| `project-organization` | Model or user | Claims single-source ownership of paths, names, nesting, and Markdown templates. |
| `to-prd` | User | Writes both a repository PRD and a tracker anchor; uses an uppercase filename convention. |
| `bro` | User, internal | Two-line plain-language repitch with no persistent artifact. |
| `ddd` | Model or user, internal | Longest description in the portfolio and a 208-line strategic modeling workflow. |
| `improve-claude-md` | Model or user, internal | Largest main body at 254 lines; central XML adherence claim has no retained effect evidence. |
| `show-me` | Model or user, internal | Two-stage compress and collapse method; can emit HTML and names a missing retrieval capability. |
| `compose-multiplatform-ui` | Model or user | Pins a current Compose era and carries symptom-level iOS routing in its description. |
| `kmp-boundaries` | Model or user | Separates sourced platform constraints from labeled team heuristics. |
| `kmp-ios-integration` | Model or user | Routes among four integration methods and maintains two deep references. |
| `kmp-ktor` | Model or user | Description promises basic setup and engine selection that the first body paragraph excludes. |
| `kmp-module-setup` | Model or user | Treats the version catalog as a compatibility contract and contains a seam-choice table. |
| `kmp-release-and-publish` | Model or user | Combines store release, Maven publishing, CI topology, and test-task selection. |
| `kmp-test-seams` | Model or user | Eight-line reference that deliberately delegates the red-green loop to `tdd`. |
| `herdr` | Model or user | Requires `HERDR_ENV=1`, learns the live CLI before control, and spans 191 body lines. |
| `port-from-repo` | User | Makes the source read-only, checks the license first, and requires provenance in a commit message. |
| `setup-osxsystem-skills` | User, internal | Run-once repository configurator that writes the pointers consumed by several engineering skills. |
| `sync-upstream` | User, internal | Repository-specific fork maintenance runbook that must land a merge commit. |
| `use-git-worktree` | Model or user | Implicitly creates Git state for multi-file changes and includes detailed submodule and ignore edge cases. |
| `when-stuck` | Model or user | Five diagnostic reframing moves with explicit provenance to Microsoft Amplifier. |
| `do-test` | Model or user | Verdict-oriented test workflow with five references; its regression recipe proposes stash or revert. |
| `unslop` | Model or user | Only prose skill with an executable checker and an explicit register model. |
| `claude-handoff` | User | Host-specific launcher that does not retain the handoff packet before starting the background process. |
| `implement-spec` | User | Parallel PR orchestrator that allocates one worktree per implementer and a separate merger agent. |
| `loop-me` | User | Stateful life-workflow modeling that creates, edits, and deletes `workflows/*.md` specs. |
| `retro` | User | Reviews the agent environment, not the product change, and returns severity-ordered candidates. |
| `setup-ts-deep-modules` | User | Installs dependency-cruiser, commits an example package, and proves rules with pass-fail-pass. |
| `writing-beats` | User | Choose-your-own-journey interaction where concept grounding determines the next reachable beat. |
| `writing-fragments` | User | Explore-only, append-oriented capture that rejects outline and article structure. |
| `writing-shape` | User | Exploit workflow that grows one article block at a time from fixed raw material. |
| `git-guardrails-claude-code` | Model or user | Ships a fail-closed hook script with the portfolio's only substantial behavior fixture suite. |
| `migrate-to-shoehorn` | Model or user | Test-only TypeScript migration tied to one external helper library. |
| `scaffold-exercises` | Model or user | Hardcoded to AI Hero course layout, its linter, and a final Git commit. |
| `setup-pre-commit` | Model or user | Installs a full JavaScript hook stack and uses its own commit as the smoke test. |
| `grill-me` | User | One-line user-facing alias over `grilling`. |
| `grilling` | Model or user | Decision-tree interview that delegates fact finding but reserves every decision for the user. |
| `handoff` | User | Writes a redacted pointer-first packet to the operating system temporary directory. |
| `teach` | User | Assumes a multi-session course and creates a durable HTML lesson and reference workspace. |
| `to-questionnaire` | User | Writes one asynchronous questionnaire in the current directory after two setup questions. |
| `wait-what` | User | One-line corrective that requires ASD-STE100 and repository ubiquitous language. |
| `writing-for-agents` | Model or user | Reference skill with its own mechanics supplement and an explicit context-load vocabulary. |

## Scorecard

`T` trigger, `A` actionability, `E` token economy, `C` correctness, `S` structure, `P` scope and portability. Sorted worst first.

| Skill | T | A | E | C | S | P | Total | Verdict |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| `improve-claude-md` | 1 | 3 | 1 | 1 | 3 | 2 | 1.80 | delete |
| `implement-spec` | 2 | 4 | 4 | 2 | 4 | 2 | 3.00 | merge |
| `implement` | 4 | 3 | 5 | 1 | 2 | 2 | 3.05 | fix |
| `teach` | 4 | 5 | 1 | 3 | 5 | 2 | 3.55 | fix |
| `cook` | 5 | 5 | 2 | 1 | 5 | 2 | 3.65 | fix |
| `retro` | 4 | 4 | 4 | 3 | 4 | 4 | 3.85 | fix |
| `diagnosing-bugs` | 5 | 5 | 3 | 2 | 5 | 2 | 3.95 | fix |
| `project-organization` | 3 | 5 | 3 | 4 | 5 | 4 | 3.95 | fix |
| `ask-matt` | 5 | 5 | 2 | 2 | 5 | 4 | 4.00 | fix |
| `kmp-ktor` | 2 | 5 | 4 | 5 | 5 | 4 | 4.00 | fix |
| `claude-handoff` | 5 | 4 | 5 | 3 | 3 | 3 | 4.05 | merge |
| `ddd` | 5 | 5 | 1 | 4 | 4 | 4 | 4.05 | fix |
| `tdd` | 5 | 4 | 4 | 2 | 5 | 4 | 4.05 | fix |
| `herdr` | 5 | 5 | 2 | 4 | 5 | 2 | 4.10 | keep |
| `do-test` | 5 | 5 | 3 | 2 | 5 | 4 | 4.15 | fix |
| `resolving-merge-conflicts` | 5 | 4 | 5 | 3 | 3 | 4 | 4.15 | fix |
| `scaffold-exercises` | 5 | 5 | 4 | 3 | 5 | 1 | 4.15 | fix |
| `show-me` | 5 | 5 | 3 | 2 | 5 | 4 | 4.15 | fix |
| `domain-modeling` | 5 | 5 | 4 | 2 | 5 | 3 | 4.20 | fix |
| `improve-codebase-architecture` | 4 | 5 | 3 | 4 | 5 | 4 | 4.20 | keep |
| `kmp-module-setup` | 4 | 5 | 3 | 4 | 5 | 4 | 4.20 | fix |
| `port-from-repo` | 4 | 5 | 4 | 3 | 5 | 4 | 4.20 | fix |
| `research` | 5 | 3 | 5 | 5 | 3 | 4 | 4.20 | fix |
| `migrate-to-shoehorn` | 5 | 4 | 4 | 4 | 5 | 3 | 4.25 | fix |
| `writing-fragments` | 5 | 4 | 4 | 4 | 4 | 4 | 4.25 | keep |
| `codebase-design` | 5 | 4 | 4 | 3 | 5 | 5 | 4.30 | fix |
| `grill-with-docs` | 5 | 4 | 5 | 4 | 2 | 5 | 4.30 | fix |
| `sync-upstream` | 5 | 5 | 4 | 4 | 5 | 1 | 4.30 | keep |
| `unslop` | 4 | 5 | 3 | 4 | 5 | 5 | 4.30 | keep |
| `setup-osxsystem-skills` | 5 | 5 | 3 | 4 | 5 | 3 | 4.35 | keep |
| `setup-ts-deep-modules` | 5 | 5 | 3 | 4 | 5 | 3 | 4.35 | fix |
| `wayfinder` | 4 | 5 | 4 | 4 | 5 | 4 | 4.35 | keep |
| `kmp-test-seams` | 5 | 4 | 5 | 4 | 4 | 4 | 4.40 | keep |
| `grill-me` | 5 | 4 | 5 | 5 | 2 | 5 | 4.45 | keep |
| `kmp-ios-integration` | 5 | 5 | 3 | 4 | 5 | 4 | 4.45 | keep |
| `kmp-release-and-publish` | 5 | 5 | 3 | 4 | 5 | 4 | 4.45 | keep |
| `to-prd` | 5 | 5 | 4 | 3 | 5 | 4 | 4.45 | fix |
| `triage` | 5 | 5 | 3 | 4 | 5 | 4 | 4.45 | keep |
| `wait-what` | 5 | 5 | 5 | 4 | 2 | 4 | 4.45 | fix |
| `writing-for-agents` | 5 | 4 | 4 | 4 | 5 | 5 | 4.45 | keep |
| `loop-me` | 5 | 5 | 4 | 4 | 5 | 3 | 4.50 | fix |
| `setup-pre-commit` | 5 | 5 | 4 | 4 | 5 | 3 | 4.50 | fix |
| `git-guardrails-claude-code` | 5 | 5 | 4 | 5 | 5 | 2 | 4.55 | keep |
| `code-review` | 5 | 5 | 4 | 4 | 5 | 4 | 4.60 | keep |
| `compose-multiplatform-ui` | 5 | 5 | 3 | 5 | 5 | 4 | 4.60 | keep |
| `prototype` | 5 | 5 | 4 | 4 | 5 | 4 | 4.60 | fix |
| `to-spec` | 5 | 5 | 5 | 3 | 5 | 4 | 4.60 | fix |
| `to-tickets` | 5 | 5 | 4 | 4 | 5 | 4 | 4.60 | keep |
| `use-git-worktree` | 5 | 5 | 4 | 4 | 5 | 4 | 4.60 | keep |
| `wizard` | 5 | 5 | 3 | 5 | 5 | 4 | 4.60 | keep |
| `bro` | 5 | 5 | 5 | 5 | 2 | 5 | 4.70 | keep |
| `when-stuck` | 5 | 5 | 4 | 4 | 5 | 5 | 4.70 | keep |
| `kmp-boundaries` | 5 | 5 | 4 | 5 | 5 | 4 | 4.75 | keep |
| `writing-beats` | 5 | 5 | 4 | 5 | 5 | 4 | 4.75 | keep |
| `writing-shape` | 5 | 5 | 4 | 5 | 5 | 4 | 4.75 | keep |
| `to-questionnaire` | 5 | 5 | 5 | 4 | 5 | 5 | 4.85 | keep |
| `grilling` | 5 | 5 | 5 | 5 | 4 | 5 | 4.90 | keep |
| `handoff` | 5 | 5 | 5 | 5 | 4 | 5 | 4.90 | keep |

## Phase 1: per-skill reports

Each block names one evidence line for every score. Pros state what works and why. Cons state symptom, reason, and a concrete failure scenario. Reports remain sorted by weighted score, worst first.


### `improve-claude-md`, 1.80, delete

- **Trigger 1:** `skills/house/in-development/improve-claude-md/SKILL.md:3`. Source line: <q>description: improve a CLAUDE.md file using <important if> blocks to improve instruction adherence</q>. Assessment: improve a CLAUDE.md file names the artifact but not the symptoms that distinguish this from general agent-instruction editing, so a model can miss weak adherence unless the user names the file.
- **Actionability 3:** `skills/house/in-development/improve-claude-md/SKILL.md:8`. Source line: <q>When the user provides a CLAUDE.md file (or asks you to improve one), rewrite it following the principles and structure below.</q>. Assessment: Rewrite the CLAUDE.md file gives a direct action, but it prescribes one device before diagnosing the instruction failure.
- **Token economy 1:** `skills/house/in-development/improve-claude-md/SKILL.md:127`. Source line: <q>## Example</q>. Assessment: ## Common `important if` patterns begins a long pattern catalog; that bulk is loaded even when one short conditional needs repair.
- **Correctness 1:** `skills/house/in-development/improve-claude-md/SKILL.md:20`. Source line: <q>Wrap conditionally-relevant sections of the CLAUDE.md in `<important if="condition">` XML tags. This exploits the same XML tag pattern used in Claude Code's own system prompt, giving the model an explicit relevance signal that cuts through the "may or may not be relevant" framing.</q>. Assessment: exploits the same XML tag pattern Claude's system prompts use presents an unverified mechanism as fact, so authors may cargo-cult markup that has no demonstrated privileged effect.
- **Structure 3:** `skills/house/in-development/improve-claude-md/SKILL.md:78`. Source line: <q>## Output Structure</q>. Assessment: ## Output structure provides a usable procedure, but the long examples overwhelm the decision rule.
- **Scope 2:** `skills/house/in-development/improve-claude-md/SKILL.md:61`. Source line: <q>Do not shard into separate files that require the agent to make tool calls to discover, unless the extra context is incredibly verbose or complex.</q>. Assessment: Do not use sub-files, sharding bans valid repository layouts without inspecting repository policy, so a large instruction set can be forced into a worse monolith.
- **Verdict:** The concrete rewrite shape is useful because it turns conditions into visible blocks. The central claim is unsupported and the blanket layout ban is overbroad, so the skill can increase confidence while degrading the actual instruction architecture. Delete it and fold only the conditional-writing pattern into `writing-for-agents` after an evidence-backed test.

### `implement-spec`, 3.00, merge

- **Trigger 2:** `skills/in-progress/implement-spec/SKILL.md:3`. Source line: <q>description: "Implement a specification in code."</q>. Assessment: Implement a spec does not name the required multi-worktree, multi-agent topology, so ordinary implementation requests can invoke a heavyweight coordinator.
- **Actionability 4:** `skills/in-progress/implement-spec/SKILL.md:19`. Source line: <q>1. Read the spec and tickets. Read enough to understand the task graph.</q>. Assessment: Read the spec starts a numbered flow, but selection, agent failure, and rework rules remain implicit.
- **Token economy 4:** `skills/in-progress/implement-spec/SKILL.md:23`. Source line: <q>3. Create a branch, and a draft PR. The PR should be marked as 'closing' the spec issue and tickets.</q>. Assessment: Open a draft PR expresses the delivery sequence with little prose.
- **Correctness 2:** `skills/in-progress/implement-spec/SKILL.md:25`. Source line: <q>4. Use **implementer subagents** to implement each ticket. Each implementer subagent should work in its own worktree, on its own branch.</q>. Assessment: Each agent must work in their own worktree assumes agent capacity and worktree authority, while the skill has no preflight for either.
- **Structure 4:** `skills/in-progress/implement-spec/SKILL.md:27`. Source line: <q>5. Once an **implementer subagent** completes, merge its work to the PR branch with a **merger subagent**.</q>. Assessment: Designate one agent as the merger gives ownership and a coherent merge sequence, though no rollback branch is defined.
- **Scope 2:** `skills/in-progress/implement-spec/SKILL.md:35`. Source line: <q>9. Clean up all **implementer subagent** worktrees.</q>. Assessment: Clean up all worktrees spans planning, delegation, PR creation, review, merge, and cleanup, overlapping `cook`, `to-tickets`, and `use-git-worktree`.
- **Verdict:** Explicit merger ownership reduces integration ambiguity. The trigger hides a specialized parallel-delivery workflow, so a small spec can unexpectedly create PRs and worktrees. Merge this as an optional execution mode inside `cook` rather than maintain a competing top-level workflow.

### `implement`, 3.05, fix

- **Trigger 4:** `skills/engineering/implement/SKILL.md:3`. Source line: <q>description: "Implement a piece of work based on a spec or set of tickets."</q>. Assessment: The picker copy names both accepted inputs clearly, but does not distinguish this short chain from `cook` or `implement-spec`.
- **Actionability 3:** `skills/engineering/implement/SKILL.md:7`. Source line: <q>Implement the work described by the user in the spec or tickets.</q>. Assessment: The instruction is direct, but supplies no decomposition, failure, or tracker-state method.
- **Token economy 5:** `skills/engineering/implement/SKILL.md:7`. Source line: <q>Implement the work described by the user in the spec or tickets.</q>. Assessment: The complete skill is only ten body lines, so it imposes almost no loading cost.
- **Correctness 1:** `skills/engineering/implement/SKILL.md:15`. Source line: <q>Commit your work to the current branch.</q>. Assessment: Commit makes a repository mutation unconditional, conflicting with conservative profiles and repositories that reserve commits for humans.
- **Structure 2:** `skills/engineering/implement/SKILL.md:9`. Source line: <q>Use /tdd where possible, at pre-agreed seams.</q>. Assessment: Use `/tdd` skill to implement is a bare command list with no inputs, gates, failure states, or completion contract.
- **Scope 2:** `skills/engineering/implement/SKILL.md:13`. Source line: <q>Once done, use /code-review to review the work.</q>. Assessment: Use `/code-review` skill chains a broad implementation, review, tracker, and commit lifecycle into a shallow wrapper that duplicates `cook`.
- **Verdict:** Its brevity lowers loading cost. Because it defines neither failure handling nor a permission boundary, it can finish a partial implementation and commit without authority. Fix by making it a documented lightweight `cook` mode or retire the wrapper.

### `teach`, 3.55, fix

- **Trigger 4:** `skills/productivity/teach/SKILL.md:3`. Source line: <q>description: Teach the user a new skill or concept, within this workspace.</q>. Assessment: Teach concepts by building an interactive course is clear, but it does not delimit one lesson from a full curriculum or static explanation.
- **Actionability 5:** `skills/productivity/teach/SKILL.md:49`. Source line: <q>A lesson is the main thing you produce: the unit in which knowledge and skills reach the user. Each lesson is one self-contained HTML file, saved to `./lessons/` and titled `0001-<dash-case-name>.html` where the number increments each time.</q>. Assessment: Build the lesson as a polished, single-page HTML artifact gives a tangible deliverable and presentation constraints.
- **Token economy 1:** `skills/productivity/teach/SKILL.md:12`. Source line: <q>Treat the current directory as a teaching workspace. The state of their learning is captured in this directory in several files:</q>. Assessment: Create and maintain starts a five-file state system before any lesson is validated, adding ceremony for small teaching requests.
- **Correctness 3:** `skills/productivity/teach/SKILL.md:30`. Source line: <q>Before the `RESOURCES.md` is well-populated, your focus should be to find high-quality resources which will help the user acquire knowledge. Never trust your parametric knowledge.</q>. Assessment: Never trust parametric knowledge is a useful caution, but absolute language can force needless browsing for stable concepts.
- **Structure 5:** `skills/productivity/teach/SKILL.md:8`. Source line: <q>The user has asked you to teach them something. This is a stateful request - they intend to learn the topic over multiple sessions.</q>. Assessment: This is stateful anchors a coherent discover, assess, teach, test, and persist loop.
- **Scope 2:** `skills/productivity/teach/SKILL.md:65`. Source line: <q>Lessons are built from reusable **components**, stored in `./assets/`: stylesheets, quiz widgets, simulators, diagram helpers, and anything else a second lesson could reuse.</q>. Assessment: Reuse available libraries and assets mixes pedagogy, curriculum storage, web design, and asset selection in one skill.
- **Verdict:** Persistent learner state supports adaptation because later lessons can build on demonstrated mastery. Mandatory file sprawl and HTML production make a short conceptual lesson expensive and brittle. Fix by adding lightweight and curriculum modes, with persistence only after the user opts into a course.

### `cook`, 3.65, fix

- **Trigger 5:** `skills/house/delivery/cook/SKILL.md:3`. Source line: <q>description: "Cook a task end-to-end: research, plan, implement, test, review, finalize. Use when the user wants a feature implemented, a plan executed, or a fix shipped through the full pipeline."</q>. Assessment: feature implemented, a plan executed, or a fix shipped clearly names end-to-end delivery, though it overlaps the generic `implement` trigger.
- **Actionability 5:** `skills/house/delivery/cook/SKILL.md:14`. Source line: <q>End-to-end implementation: detect intent, research, plan, implement, test, review, finalize. Every major step ends at a **gate**, a stop for human approval, unless the mode says otherwise.</q>. Assessment: Research -> Plan -> Implement -> Test -> Review -> Finalize establishes an ordered pipeline with gates and named modes.
- **Token economy 2:** `skills/house/delivery/cook/SKILL.md:76`. Source line: <q>Finalize always ends with a full-plan sync-back (every phase file, not just the current one), a docs check, a commit offer, and a journal entry in `docs/journals/`; details are in `references/workflow-steps.md` Step 6.</q>. Assessment: A mandatory journal and full-plan synchronization add artifact work to every run, even when the project tracker already holds the durable state.
- **Correctness 1:** `skills/house/delivery/cook/SKILL.md:68`. Source line: <q>| UI work | House design skills: `compose-multiplatform-ui`, `html-design-to-compose` | If Compose UI work |</q>. Assessment: This row names one missing skill, and the next row names missing `simplify`, so valid execution branches terminate at runtime.
- **Structure 5:** `skills/house/delivery/cook/SKILL.md:46`. Source line: <q>A reviewed plan exists before any implementation code, regardless of task simplicity; "simple" tasks are where unexamined assumptions cost the most. `--fast` skips research, never the plan step. Only an explicit user instruction ("just code it", "skip planning") lifts this gate.</q>. Assessment: The plan is a hard gate makes phase transitions explicit, but missing dependencies are not preflighted.
- **Scope 2:** `skills/house/delivery/cook/SKILL.md:61`. Source line: <q>Each phase runs in the agent or skill built for it, never improvised inline:</q>. Assessment: Delegation is encouraged expands the orchestrator across research, planning, design, implementation, testing, review, and tracking, which duplicates several dedicated routers.
- **Verdict:** The gated pipeline supplies a strong end-to-end contract. Missing skill names and duplicated orchestration mean valid requests can stall after planning or fork into inconsistent workflows. Fix the references, define capability checks, and make the journal a compact tracker update rather than a second source of truth.

### `retro`, 3.85, fix

- **Trigger 4:** `skills/in-progress/retro/SKILL.md:3`. Source line: <q>description: "Conduct a retrospective on a coding session."</q>. Assessment: The human picker can select it reliably, though it does not preview that the output is environment improvements rather than a session summary.
- **Actionability 4:** `skills/in-progress/retro/SKILL.md:11`. Source line: <q>1. Call the Skill tool with `writing-for-agents` for the writing style guide.</q>. Assessment: It composes an appropriate writing standard and then gives seven concrete search categories, but no evidence threshold for proposing a change.
- **Token economy 4:** `skills/in-progress/retro/SKILL.md:15`. Source line: <q>3. Look for candidates for improvement in these categories.</q>. Assessment: The compact category list directs the review without a long phase ceremony.
- **Correctness 3:** `skills/in-progress/retro/SKILL.md:31`. Source line: <q>Remember that all work goes through two stages: implementation and review. The implementation agent has the most **context pressure**. They are responsible for exploration, writing code, and debugging failures.</q>. Assessment: This useful distinction is presented as universal, so repositories with different review or agent topology can receive misplaced guidance.
- **Structure 4:** `skills/in-progress/retro/SKILL.md:25`. Source line: <q>4. Present these candidates to the user, in order of severity.</q>. Assessment: Severity ordering gives the output a clear shape, but the scale and tie-breaker are unstated.
- **Scope 4:** `skills/in-progress/retro/SKILL.md:41`. Source line: <q>- `CLAUDE.md`/`AGENTS.md`: these files are pushed to the context window of any agent working in this repo. They should be used incredibly sparingly, usually only for **navigation pointers** to other files.</q>. Assessment: The skill stays on agent-environment changes, though its assumed file set is Claude-centric rather than discovered from repository policy.
- **Verdict:** The category taxonomy turns a vague retrospective into concrete environment candidates. Universal agent-role and file-layout assumptions can recommend the right idea in the wrong place. Fix by discovering the active harness and requiring session evidence for every candidate.

### `diagnosing-bugs`, 3.95, fix

- **Trigger 5:** `skills/engineering/diagnosing-bugs/SKILL.md:3`. Source line: <q>description: Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow.</q>. Assessment: diagnose" and reports of "broken/throwing/failing/slow give the model strong symptom vocabulary.
- **Actionability 5:** `skills/engineering/diagnosing-bugs/SKILL.md:20`. Source line: <q>**This is the skill.** Everything else is mechanical. If you have a **tight** pass/fail signal for the bug (one that goes red on _this_ bug), you will find the cause; bisection, hypothesis-testing, and instrumentation all just consume it. If you don't have one, no amount of staring at code will save you.</q>. Assessment: Run a tight loop leads from reproduction through observation, hypothesis, and falsification.
- **Token economy 3:** `skills/engineering/diagnosing-bugs/SKILL.md:90`. Source line: <q>Generate **3–5 ranked hypotheses** before testing any of them. Single-hypothesis generation anchors on the first plausible idea.</q>. Assessment: Maintain three live hypotheses is useful on hard bugs but mandatory bookkeeping is excessive for a simple deterministic failure.
- **Correctness 2:** `skills/engineering/diagnosing-bugs/SKILL.md:114`. Source line: <q>## Phase 5: Fix + regression test</q>. Assessment: Phase 5: Fix proceeds from a diagnosis request into implementation even though diagnosis alone does not authorize mutation.
- **Structure 5:** `skills/engineering/diagnosing-bugs/SKILL.md:59`. Source line: <q>Phase 1 is done when the loop is **tight** and **red-capable**: you can name **one command** (a script path, a test invocation, a curl) that you have **already run at least once** (show the invocation and its output, redacted), and that is:</q>. Assessment: Evidence gate prevents speculative fixes before a reproduction and discriminating observation exist.
- **Scope 2:** `skills/engineering/diagnosing-bugs/SKILL.md:124`. Source line: <q>1. Turn the minimised repro into a failing test at that seam.</q>. Assessment: Apply the smallest corrective change crosses from cause-finding into fixing, testing, and cleanup despite the advertised diagnosis loop.
- **Verdict:** The evidence gate is strong because it forces hypotheses to compete against observations. The automatic fix phase violates the diagnose-only boundary, so a read-only investigation can mutate code unexpectedly. Split diagnosis from remediation with an explicit authorization gate and scale the hypothesis ledger to complexity.

### `project-organization`, 3.95, fix

- **Trigger 3:** `skills/house/delivery/project-organization/SKILL.md:3`. Source line: <q>description: Organize files, directories, and content structure in any project. Use when creating files, determining output paths, organizing existing assets, or standardizing project layout.</q>. Assessment: Organize files, directories, and content structure in any project is so broad that nearly any file creation can match it.
- **Actionability 5:** `skills/house/delivery/project-organization/SKILL.md:100`. Source line: <q>1. **Scan**: List all files in target dirs, categorize by type</q>. Assessment: 1. Inspect the repository begins a concrete seven-step workflow and gives deterministic placement rules.
- **Token economy 3:** `skills/house/delivery/project-organization/SKILL.md:44`. Source line: <q>All filenames use **kebab-case**, self-documenting names. Three naming modes based on content temporality:</q>. Assessment: All filenames use introduces an extensive universal naming policy that every simple file write must load.
- **Correctness 4:** `skills/house/delivery/project-organization/SKILL.md:38`. Source line: <q>**No row matches** (bug reports, scratch notes, sample data, anything else): leave the file where it is and list it under an **Unmatched** heading in the migration table with a suggested home, for the user to decide. Never invent a new top-level directory unprompted.</q>. Assessment: The fail-closed unmatched path avoids structural invention; the remaining weakness is that move mode never requires an inbound-reference scan.
- **Structure 5:** `skills/house/delivery/project-organization/SKILL.md:18`. Source line: <q>| Mode | Trigger | Behavior |</q>. Assessment: Classify every task into exactly one mode cleanly partitions new artifact, reorganization, and extension decisions.
- **Scope 4:** `skills/house/delivery/project-organization/SKILL.md:52`. Source line: <q>Slugs: lowercase, hyphens only, max 50 chars, readable without opening the file. Date format: `YYMMDD-HHmm` (`date +%y%m%d-%H%M`). Code files defer to language convention (kebab-case JS/TS/Python/Shell, PascalCase C#/Java/Kotlin/Swift, snake_case Go/Rust).</q>. Assessment: Codebase convention exceptions acknowledges local precedence, but the skill still combines naming, plans, reports, assets, temporary files, and code layout.
- **Verdict:** The mode split and fail-closed unmatched path make placement decisions reproducible. Move mode can still break links because it verifies the final tree but never requires inbound-reference discovery. Fix that check and narrow the model trigger to artifact placement or explicit organization work.

### `ask-matt`, 4.00, fix

- **Trigger 5:** `skills/engineering/ask-matt/SKILL.md:3`. Source line: <q>description: Ask which skill or flow fits your situation. A router over the skills in this repo.</q>. Assessment: The user-only picker copy states the routing job directly and no longer depends on persona wording.
- **Actionability 5:** `skills/engineering/ask-matt/SKILL.md:13`. Source line: <q>## The main flow: idea → ship</q>. Assessment: Start here opens a concrete route map across exploration, planning, execution, and review.
- **Token economy 2:** `skills/engineering/ask-matt/SKILL.md:73`. Source line: <q>Read [references/platform-knowledge.md](references/platform-knowledge.md) for what each one covers.</q>. Assessment: Reference material moves detail out of the main route, though the broad map still loads many unrelated flows.
- **Correctness 2:** `skills/engineering/ask-matt/SKILL.md:71`. Source line: <q>Five model-invoked references for when the codebase is **Kotlin Multiplatform / Compose Multiplatform**: `/kmp-module-setup`, `/kmp-ios-integration`, `/compose-multiplatform-ui`, `/kmp-test-seams`, `/kmp-release-and-publish`. Like the vocabulary layer, they run *beneath* the flow rather than as a step in it: the model reaches for them as the work demands, and `/kmp-test-seams` is the one that sits directly under a flow step, supplying `/tdd` with the platform half of the loop. Reach for them directly when the **platform**, not the process, is what you're stuck on.</q>. Assessment: Five Kotlin Multiplatform skills is stale: the catalog contains seven and the router omits `kmp-boundaries` and `kmp-ktor`.
- **Structure 5:** `skills/engineering/ask-matt/SKILL.md:103`. Source line: <q>## Precondition</q>. Assessment: Use the playbooks below only after explicitly separates prerequisite discovery from execution playbooks.
- **Scope 4:** `skills/engineering/ask-matt/SKILL.md:91`. Source line: <q>- **`/grill-me`**: the same relentless interview as `/grill-with-docs`, but **stateless**: it saves nothing locally and builds no `CONTEXT.md`. Reach for it when you are **not working in a working directory** (sharpening a plan, a design, a piece of writing, anything with no repo under it). If you are in a working directory, use `/grill-with-docs` instead: it runs the same interview and leaves a paper trail, so it is strictly the better one.</q>. Assessment: `grill-me` vs `grill-with-docs` resolves a real routing collision, though the persona wrapper makes the overall boundary less obvious.
- **Verdict:** The route map lowers selection cost by arranging skills into actual work flows. A stale count and omitted mobile routes make the authoritative router lie, so KMP requests can be sent to a generic path. Fix the catalog coverage and trigger it on workflow selection, not persona invocation.

### `kmp-ktor`, 4.00, fix

- **Trigger 2:** `skills/house/mobile/kmp-ktor/SKILL.md:3`. Source line: <q>description: Use when setting up or working with Ktor client in KMP or Android projects, covering HttpClient configuration, per-platform engine selection, kotlinx.serialization, bearer auth with refresh, MockEngine testing, and error mapping at the repository boundary.</q>. Assessment: setting up or working with Ktor client promises client setup and engine selection, but the body says otherwise.
- **Actionability 5:** `skills/house/mobile/kmp-ktor/SKILL.md:42`. Source line: <q>In the `Auth` `bearer { refreshTokens { … } }` block, mark the refresh POST with `markAsRefreshTokenRequest()` so it isn't intercepted by the same `Auth` plugin. Without it, a failing refresh triggers another refresh, looping infinitely. It's an `HttpRequestBuilder` extension: call it **inside the request builder block**, not bare in `refreshTokens { }` (where it doesn't compile).</q>. Assessment: The line identifies the exact builder, method, placement, and failure mechanism, so an agent can implement and diagnose the refresh path.
- **Token economy 4:** `skills/house/mobile/kmp-ktor/SKILL.md:10`. Source line: <q>## Plugin install order: `HttpRequestRetry` BEFORE `HttpTimeout`</q>. Assessment: Install plugins in this order front-loads the highest-risk configuration detail without restating Ktor basics.
- **Correctness 5:** `skills/house/mobile/kmp-ktor/SKILL.md:38`. Source line: <q>`expectSuccess = true` makes Ktor throw `ClientRequestException` (4xx) / `ServerResponseException` (5xx) on non-2xx, and that throw **runs before any manual status check**, so an `if (response.status == OK)` branch after it is dead code. Pick one model project-wide: `expectSuccess = true` + `try/catch` (matches the repository pattern), or `expectSuccess = false` + explicit `response.status.isSuccess()` inspection. Never mix them.</q>. Assessment: Set `expectSuccess = true` only when and the retry-before-timeout ordering match current Ktor documentation.
- **Structure 5:** `skills/house/mobile/kmp-ktor/SKILL.md:104`. Source line: <q>Inject `HttpClientEngine` so tests swap in `MockEngine`, reusing the production `createHttpClient` factory so plugin config matches:</q>. Assessment: Inject the engine closes the guidance with a clear testing seam.
- **Scope 4:** `skills/house/mobile/kmp-ktor/SKILL.md:8`. Source line: <q>This reference covers the Ktor client configuration traps: plugin install order, serialization flags, auth refresh, and error mapping. It does not cover the basics of a shared `HttpClient`, engine selection, or `ContentNegotiation` setup. **Related:** [`kmp-boundaries`](../kmp-boundaries/SKILL.md) (where the network boundary sits relative to common code), [`kmp-test-seams`](../kmp-test-seams/SKILL.md) (which source set the `MockEngine` tests below belong in).</q>. Assessment: This skill does not cover basic Ktor setup or engine selection is a crisp body boundary, but it contradicts the trigger rather than resolving it.
- **Verdict:** The plugin-order and injected-engine rules prevent subtle auth, retry, and test failures. The description advertises work the body refuses, so setup requests route here and receive no setup. Fix the description to target hard client configuration or add the promised engine-selection section.

### `claude-handoff`, 4.05, merge

- **Trigger 5:** `skills/in-progress/claude-handoff/SKILL.md:3`. Source line: <q>description: Hand the current conversation off to a fresh background agent that picks up the work immediately.</q>. Assessment: Hand off the current task to Claude is understandable to a human but does not distinguish task delegation from writing a resumable context packet.
- **Actionability 4:** `skills/in-progress/claude-handoff/SKILL.md:8`. Source line: <q>Write a handoff summary of the current conversation so a fresh agent can continue the work. Instead of saving it, launch a background agent seeded with the summary as its prompt: `claude --bg --name "<descriptive name>" "<handoff summary>"`. It starts in the current working directory and returns immediately; the user manages it with `claude agents`.</q>. Assessment: `claude --bg --name` is executable, but no recovery is defined when the CLI is absent, unauthenticated, or returns a partial result.
- **Token economy 5:** `skills/in-progress/claude-handoff/SKILL.md:10`. Source line: <q>Always pass `-n`/`--name` with a descriptive name (e.g. `--name "Fix login bug"`); it sets the display name shown in the job list, session picker, and terminal title.</q>. Assessment: One concrete naming rule makes launched work identifiable without expanding the wrapper.
- **Correctness 3:** `skills/in-progress/claude-handoff/SKILL.md:8`. Source line: <q>Write a handoff summary of the current conversation so a fresh agent can continue the work. Instead of saving it, launch a background agent seeded with the summary as its prompt: `claude --bg --name "<descriptive name>" "<handoff summary>"`. It starts in the current working directory and returns immediately; the user manages it with `claude agents`.</q>. Assessment: launch a background agent could not be verified locally because no `claude` binary is installed, and the handoff has no capability or acknowledgement check.
- **Structure 3:** `skills/in-progress/claude-handoff/SKILL.md:14`. Source line: <q>Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.</q>. Assessment: Pointer-first handoff is well structured, but failure, timeout, and recipient acknowledgement remain undefined.
- **Scope 3:** `skills/in-progress/claude-handoff/SKILL.md:12`. Source line: <q>Include a "suggested skills" section in the summary, naming which skills the next agent should call the Skill tool for.</q>. Assessment: The packet content is useful, but duplicates the transport-neutral `handoff` contract inside a host-specific launcher.
- **Verdict:** Descriptive naming, redaction, and pointer-first context make a compact launch packet. The wrapper assumes an unavailable executable and offers no receipt, so transfer can fail silently in a default install. Merge packet construction into `handoff` and keep this as a capability-checked launcher adapter.

### `ddd`, 4.05, fix

- **Trigger 5:** `skills/house/in-development/ddd/SKILL.md:3`. Source line: <q>description: Run a domain-driven design session end to end. Crunch the knowledge the code and documents already hold, converse in rounds of Discovery Tree questions to settle what they cannot tell you, then return the documents and diagrams that carry the result, including a bounded-context map, an aggregate model, the domain events, and a ubiquitous language glossary. Use when the user wants to model or remodel a domain, carve a monolith or a service into bounded contexts, decide what an aggregate owns and where its consistency boundary sits, find the domain events behind a workflow, reconcile vocabulary that two teams or two services use differently, or reaches for DDD, event storming, or strategic design by name.</q>. Assessment: bounded contexts", "aggregate", "domain events", and "event storming provide rich specialist triggers.
- **Actionability 5:** `skills/house/in-development/ddd/SKILL.md:37`. Source line: <q>**Crunch the running system first.** Where a legacy system exists, it is raw material of exactly the kind described above, and it is the only source that never tires: its table names, class names, endpoints, and enum values are all somebody's earlier answer to the questions you are about to ask. Read it before asking the user for anything, using whatever search and file-reading tools this environment provides.</q>. Assessment: Crunch the knowledge already present begins a rigorous evidence, questioning, modeling, and artifact sequence.
- **Token economy 1:** `skills/house/in-development/ddd/SKILL.md:183`. Source line: <q>### Which documents this session owes</q>. Assessment: ## Artifact 1 begins a large set of mandatory artifact templates in an already long skill, even when the domain is small.
- **Correctness 4:** `skills/house/in-development/ddd/SKILL.md:146`. Source line: <q>Finding facts is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The decisions are the user's: put each to them and wait.</q>. Assessment: One fact, one responsible context is a sound ownership heuristic, but DDD heuristics are sometimes presented as universal constraints.
- **Structure 4:** `skills/house/in-development/ddd/SKILL.md:121`. Source line: <q>Open every round with the tree's state, so the user can see what is settled and redirect you before you spend a round on a branch they do not care about. A session resumed after an interruption starts the same way: reprint the ledger before anything else, since it is the only state the conversation carries.</q>. Assessment: The decision ledger preserves facts, decisions, and unknowns, while the overall workflow has more stages than its entry modes require.
- **Scope 4:** `skills/house/in-development/ddd/SKILL.md:15`. Source line: <q>This skill runs a *session*: several rounds of questions, then a set of artifacts. That shape is too heavy for small work.</q>. Assessment: too heavy for a small, settled model states a good exclusion, though the mandated deliverable set remains large for moderate sessions.
- **Verdict:** The decision ledger and responsibility tests expose real consistency boundaries. Mandatory templates impose high context cost before the problem size is known, so teams can produce ceremony instead of a useful model. Fix with progressive artifact loading and small, standard, and strategic modes.

### `tdd`, 4.05, fix

- **Trigger 5:** `skills/engineering/tdd/SKILL.md:3`. Source line: <q>description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests.</q>. Assessment: test-first" and "red-green-refactor match both explicit methodology requests and integration-test needs.
- **Actionability 4:** `skills/engineering/tdd/SKILL.md:36`. Source line: <q>- **Red before green.** Write the failing test first, then only enough code to pass it. Don't anticipate future tests or add speculative features.</q>. Assessment: Write the smallest failing test starts a crisp behavior slice, but the refactor phase is not operationalized.
- **Token economy 4:** `skills/engineering/tdd/SKILL.md:22`. Source line: <q>**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything, so agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.</q>. Assessment: Confirm the test seam keeps the process centered on the one boundary needed for the next test.
- **Correctness 2:** `skills/engineering/tdd/SKILL.md:38`. Source line: <q>- **Refactoring is not part of the loop.** It belongs to the review stage (see the `code-review` skill), not the red → green implementation cycle.</q>. Assessment: Refactoring is not part of the loop contradicts both the frontmatter promise and the canonical red, green, refactor cycle.
- **Structure 5:** `skills/engineering/tdd/SKILL.md:30`. Source line: <q>- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.</q>. Assessment: One behavior at a time organizes the work into observable, reviewable slices.
- **Scope 4:** `skills/engineering/tdd/SKILL.md:16`. Source line: <q>See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.</q>. Assessment: Use [tests.md] externalizes deep test guidance well, though the trigger also claims broad integration testing beyond the short main loop.
- **Verdict:** Seam confirmation and smallest-failing-test discipline reduce speculative production code. Removing refactoring from a skill that promises red-green-refactor creates a false contract, so users never receive the third phase. Restore an explicit behavior-preserving refactor gate or rename the method honestly.

### `herdr`, 4.10, keep

- **Trigger 5:** `skills/house/platform/herdr/SKILL.md:3`. Source line: <q>description: "Control Herdr, a terminal multiplexer for coding agents. Use only when the user explicitly mentions Herdr or asks to use Herdr to inspect or control panes, tabs, workspaces, commands, or another agent. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work. Requires HERDR_ENV=1."</q>. Assessment: Use only when the user explicitly mentions Herdr provides a precise product and permission gate.
- **Actionability 5:** `skills/house/platform/herdr/SKILL.md:54`. Source line: <q>A pane exists whether or not it contains an agent. `agent start` requires an existing available shell pane and never creates, splits, or moves layout. Use pane commands for ordinary processes. Use agent commands when Herdr must validate agent identity or interpret `idle`, `working`, `blocked`, `done`, and `unknown` lifecycle states.</q>. Assessment: Use the smallest primitive maps inspection, sending, running, waiting, and recovery to concrete commands.
- **Token economy 2:** `skills/house/platform/herdr/SKILL.md:58`. Source line: <q>`idle` means the agent is ready for input and its tab has been seen in the focused Herdr UI. `done` is the same underlying idle state after unseen background work finishes. Focusing the tab or targeting the pane or agent with a focus command marks it seen. CLI reads do not mark it seen. `blocked` means Herdr recognized an approval or question UI. `unknown` means an agent is present but Herdr cannot classify it confidently; it does not prove completion.</q>. Assessment: State model begins a long operational manual that loads even for one status query.
- **Correctness 4:** `skills/house/platform/herdr/SKILL.md:22`. Source line: <q>The installed binary is the authority for command syntax. Start with:</q>. Assessment: Treat the CLI as the authority prevents invented state, though the command surface can drift with the external tool.
- **Structure 5:** `skills/house/platform/herdr/SKILL.md:10`. Source line: <q>Before issuing any control command, verify that this agent is running inside a Herdr-managed pane:</q>. Assessment: First gate" and `skills/house/platform/herdr/SKILL.md:16`, "Stop define safe entry behavior before any control call.
- **Scope 2:** `skills/house/platform/herdr/SKILL.md:187`. Source line: <q>## Safety and coordination rules</q>. Assessment: Safety rules closes a skill that covers nearly the entire multiplexer CLI, making it broad by design.
- **Verdict:** The environment gate and smallest-primitive rule make terminal control auditable and limit side effects. The full CLI handbook is expensive and vulnerable to command drift, so simple status tasks carry unnecessary context. Keep it, but move command detail into progressively loaded references.

### `do-test`, 4.15, fix

- **Trigger 5:** `skills/house/quality/do-test/SKILL.md:3`. Source line: <q>description: "Test a change and return a verdict backed by evidence: new-feature verification or bug-fix regression. Use when the user wants a feature tested, a fix verified, a suite or coverage run, or UI behaviour checked; or when another skill needs testing after implementation."</q>. Assessment: feature tested", "fix verified", "suite or coverage run", and "UI behaviour checked cover the relevant verification intents.
- **Actionability 5:** `skills/house/quality/do-test/SKILL.md:52`. Source line: <q>## 3. Run</q>. Assessment: Execute the evidence plan turns the chosen risk into targeted test commands and observations.
- **Token economy 3:** `skills/house/quality/do-test/SKILL.md:65`. Source line: <q>Exit code is one **surface**. Read every surface the change touches:</q>. Assessment: Exercise every changed surface adds a broad matrix even when the requested test is narrowly scoped.
- **Correctness 2:** `skills/house/quality/do-test/SKILL.md:47`. Source line: <q>A bug fix carries one mandatory row: the reproduction from the report, run against the pre-fix code (`git stash`, or revert the changed file) and seen **red**, then run against the fix and seen green. A reproduction that never went red proves nothing about the fix, so report UNVERIFIED and name the step that failed to produce red.</q>. Assessment: git stash, or revert the changed file suggests destructive or state-changing cleanup without verifying ownership or obtaining authority.
- **Structure 5:** `skills/house/quality/do-test/SKILL.md:14`. Source line: <q>A run ends in a **verdict** on the change, and every verdict cites **evidence** you observed: a command, its output, a surface you read. A green suite is evidence about the suite; it becomes evidence about the change only once the matrix shows the suite covers it.</q>. Assessment: return a verdict backed by evidence gives the workflow a strong, falsifiable terminal contract.
- **Scope 4:** `skills/house/quality/do-test/SKILL.md:84`. Source line: <q>Write the report with `references/report-format.md`; path and naming from the `project-organization` skill. Lead with the verdict:</q>. Assessment: Report stays centered on verification, though UI, coverage, and all platform surfaces make the execution branch wide.
- **Verdict:** Evidence-plan-to-verdict structure prevents a green command from masquerading as behavior proof. Unsafe cleanup wording can hide user changes while trying to isolate a test. Fix by requiring non-mutating isolation first and by treating stash or revert as separately authorized operations.

### `resolving-merge-conflicts`, 4.15, fix

- **Trigger 5:** `skills/engineering/resolving-merge-conflicts/SKILL.md:3`. Source line: <q>description: "Use when you need to resolve an in-progress git merge/rebase conflict."</q>. Assessment: in-progress git merge/rebase conflict is narrow and state-specific.
- **Actionability 4:** `skills/engineering/resolving-merge-conflicts/SKILL.md:6`. Source line: <q>1. **See the current state** of the merge/rebase. Check git history, and the conflicting files.</q>. Assessment: 1. Identify all conflicted files starts a concrete five-step repair path.
- **Token economy 5:** `skills/engineering/resolving-merge-conflicts/SKILL.md:12`. Source line: <q>4. Discover the project's **automated checks** and run them, typically typecheck, then tests, then format. Fix anything the merge broke.</q>. Assessment: Run the relevant checks keeps verification proportionate and the file compact.
- **Correctness 3:** `skills/engineering/resolving-merge-conflicts/SKILL.md:10`. Source line: <q>3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Always resolve; never `--abort`.</q>. Assessment: Never abort the merge/rebase is absolute and can trap a user in an incorrect or accidental operation where abort is the safest recovery.
- **Structure 3:** `skills/engineering/resolving-merge-conflicts/SKILL.md:14`. Source line: <q>5. **Finish the merge/rebase.** Stage everything and commit. If rebasing, continue the rebase process until all commits are rebased.</q>. Assessment: Stage the resolutions and commit lacks separate paths for merge versus rebase, where continuation commands and commit behavior differ.
- **Scope 4:** `skills/engineering/resolving-merge-conflicts/SKILL.md:8`. Source line: <q>2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.</q>. Assessment: preserving the intent of both sides gives a focused semantic objective, though unconditional completion crosses permission boundaries.
- **Verdict:** Intent-preserving resolution is the right target because syntactically clean conflict markers can still break behavior. The no-abort and commit instructions ignore operation type and user authority, so an accidental rebase can be cemented. Fix with state detection, an abort decision gate, and operation-specific continuation.

### `scaffold-exercises`, 4.15, fix

- **Trigger 5:** `skills/misc/scaffold-exercises/SKILL.md:3`. Source line: <q>description: Create exercise directory structures with sections, problems, solutions, and explainers that pass linting. Use when user wants to scaffold exercises, create exercise stubs, or set up a new course section.</q>. Assessment: scaffold exercises", "exercise stubs", and "new course section provide precise educational-project triggers.
- **Actionability 5:** `skills/misc/scaffold-exercises/SKILL.md:46`. Source line: <q>1. **Parse the plan** - extract section names, exercise names, and variant types</q>. Assessment: Create the directory structure leads through naming, templates, registry updates, lint, and verification.
- **Token economy 4:** `skills/misc/scaffold-exercises/SKILL.md:92`. Source line: <q>```bash</q>. Assessment: ## Commands offers copyable patterns, though it repeats mechanics that repository scripts could encode.
- **Correctness 3:** `skills/misc/scaffold-exercises/SKILL.md:69`. Source line: <q>1. Use `git mv` (not `mv`) to rename directories - preserves git history</q>. Assessment: Use `git mv` is sensible for tracked moves but assumes git state and move authority without preflight.
- **Structure 5:** `skills/misc/scaffold-exercises/SKILL.md:54`. Source line: <q>The linter (`pnpm ai-hero-cli internal lint`) checks:</q>. Assessment: Run the exercise linter gives scaffolding an objective completion gate.
- **Scope 1:** `skills/misc/scaffold-exercises/SKILL.md:8`. Source line: <q>Create exercise directory structures that pass `pnpm ai-hero-cli internal lint`, then commit with `git commit`.</q>. Assessment: Commit the scaffold unconditionally bundles directory creation, curriculum design, linting, registry edits, moves, and git commit.
- **Verdict:** Registry and lint verification make generated exercises conform to the course system. Unconditional commit and project-specific assumptions make this unsafe outside its original repository. Fix by declaring the supported repository shape, detecting it, and removing commit authority from the skill.

### `show-me`, 4.15, fix

- **Trigger 5:** `skills/house/in-development/show-me/SKILL.md:3`. Source line: <q>description: Draw the current topic as the smallest true picture, then show the smaller shape that picture exposes. Use when the user asks to see or draw something, when prose is not landing, when a topic has more moving parts than a sentence can hold, or when the question is why something is this complicated.</q>. Assessment: asks to see or draw something" and "why something is this complicated cover both explicit and implicit visualization needs.
- **Actionability 5:** `skills/house/in-development/show-me/SKILL.md:18`. Source line: <q>| The question | The form |</q>. Assessment: Pick the form from the relationship maps relationships to tables, flows, trees, and wireframes.
- **Token economy 3:** `skills/house/in-development/show-me/SKILL.md:105`. Source line: <q>- **One HTML file** for a visual UI, a layout, a state-by-state comparison, or a concept too dense for Mermaid: a diagram, an infographic, or a few slides, whichever fits the point. Use real labels and real data. Where the product has a visual language, borrow its colors, type, spacing, and components; where it has none (a CLI, a library, a native app with no web surface) the page is still the right view, so keep it plain and readable on a phone as well as a desktop. Then open it:</q>. Assessment: Build an HTML artifact introduces a large production branch even when a tiny text diagram would suffice.
- **Correctness 2:** `skills/house/in-development/show-me/SKILL.md:14`. Source line: <q>A tree reads as authoritative whether or not it is true, which makes a guessed picture worse than guessed prose: the reader stops checking. So when the topic is code that already exists, look it up before drawing (`codebase-retrieval`, then read the lines that matter) and carry the real names across. Real functions, files, types, and screens are what let the user check the picture against their code. When the topic is a design that does not exist yet, draw it and label it as the proposal it is.</q>. Assessment: Use `codebase-retrieval`" references a capability absent from this portfolio, and `skills/house/in-development/show-me/SKILL.md:108`, "`Bash(open...)` assumes a macOS UI side effect.
- **Structure 5:** `skills/house/in-development/show-me/SKILL.md:113`. Source line: <q>Before sending, cut every node, file, state, arrow, and boundary the user's current question does not need. The picture is finished when every element left is one they have to see to answer that question, and nothing survives for the sake of completeness. Where you dropped something, leave `…` so the shape stays honest about being partial.</q>. Assessment: First picture: compress" and `skills/house/in-development/show-me/SKILL.md:127`, "Second picture: collapse create a distinctive two-stage reasoning loop.
- **Scope 4:** `skills/house/in-development/show-me/SKILL.md:129`. Source line: <q>Then stop. This skill draws: `codebase-design` carries the vocabulary for reworking an interface, `improve-codebase-architecture` scans for more of the same, and `when-stuck` is for when the smaller shape refuses to appear.</q>. Assessment: When to stop limits elaboration once the smaller shape is visible.
- **Verdict:** Form selection plus compress-and-collapse exposes relationships that prose hides. Missing capability names and platform-specific opening commands can break an otherwise sound workflow. Fix those references and make rich HTML an escalation after the smallest true picture fails.

### `domain-modeling`, 4.20, fix

- **Trigger 5:** `skills/engineering/domain-modeling/SKILL.md:3`. Source line: <q>description: Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a CONTEXT.md, or recording or editing an ADR.</q>. Assessment: codebase terminology", "CONTEXT.md", and "ADR name both conceptual and artifact-level entry points.
- **Actionability 5:** `skills/engineering/domain-modeling/SKILL.md:44`. Source line: <q>### Challenge against the glossary</q>. Assessment: When reading an ADR begins clear read, create, and edit workflows with quality checks.
- **Token economy 4:** `skills/engineering/domain-modeling/SKILL.md:68`. Source line: <q>Only offer to create an ADR when all three are true:</q>. Assessment: An ADR passes gives a compact four-question acceptance test.
- **Correctness 2:** `skills/engineering/domain-modeling/SKILL.md:12`. Source line: <q>Most repos have a single context:</q>. Assessment: The glossary lives in `CONTEXT.md`" and `skills/engineering/domain-modeling/SKILL.md:40`, "ADRs live in `docs/adr/` hardcode defaults that conflict with this repository's `.agents/adr/` policy.
- **Structure 5:** `skills/engineering/domain-modeling/SKILL.md:44`. Source line: <q>### Challenge against the glossary</q>. Assessment: When reading", "When creating", and "When editing divide operations cleanly.
- **Scope 3:** `skills/engineering/domain-modeling/SKILL.md:8`. Source line: <q>Actively build and sharpen the project's domain model as you design. This is the *active* discipline: challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise. (Merely *reading* `CONTEXT.md` for vocabulary is not this skill: that's a one-line habit any skill can do. This skill is for when you're changing the model, not just consuming it.)</q>. Assessment: actively models separates it from passive terminology use, but it combines glossary stewardship and architectural decision records.
- **Verdict:** Separate read, create, and edit contracts keep model changes intentional. Hardcoded locations override the active repository convention, so an ADR can be written into the wrong tree. Fix by discovering repository policy first and treating default locations only as a last resort.

### `improve-codebase-architecture`, 4.20, keep

- **Trigger 4:** `skills/engineering/improve-codebase-architecture/SKILL.md:3`. Source line: <q>description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.</q>. Assessment: improve codebase architecture" and "find deepening opportunities identify design work, though the boundary with `codebase-design` is subtle.
- **Actionability 5:** `skills/engineering/improve-codebase-architecture/SKILL.md:20`. Source line: <q>**Scope before you scan: YAGNI.** Deepening a module pays off by making future changes to it easier, so put extra weight on the parts of the codebase that have recently changed. Decide *where* to look before you look:</q>. Assessment: Explore the codebase starts an evidence-first path through candidate seams, visualization, selection, and implementation planning.
- **Token economy 3:** `skills/engineering/improve-codebase-architecture/SKILL.md:39`. Source line: <q>Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user (`xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows) and tell them the absolute path.</q>. Assessment: temporary HTML file adds UI production cost before the user has selected a candidate.
- **Correctness 4:** `skills/engineering/improve-codebase-architecture/SKILL.md:60`. Source line: <q>Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"</q>. Assessment: Let the user choose correctly keeps architectural tradeoffs with the human, but CDN-backed rendering may fail offline.
- **Structure 5:** `skills/engineering/improve-codebase-architecture/SKILL.md:43`. Source line: <q>For each candidate, render a card with:</q>. Assessment: one card per opportunity makes alternatives comparable before commitment.
- **Scope 4:** `skills/engineering/improve-codebase-architecture/SKILL.md:64`. Source line: <q>Once the user picks a candidate, call the Skill tool with "grilling" to walk the decision tree with them: constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.</q>. Assessment: After selection routes deeper modeling only for the chosen seam, though it still spans discovery and presentation.
- **Verdict:** Comparable opportunity cards make architectural choice evidence-based rather than intuition-led. Mandatory HTML can fail in headless or offline environments and delays a small decision. Keep it, with Markdown as the default and HTML only when visual comparison materially helps.

### `kmp-module-setup`, 4.20, fix

- **Trigger 4:** `skills/house/mobile/kmp-module-setup/SKILL.md:3`. Source line: <q>description: Use when creating, auditing, or upgrading a Kotlin Multiplatform shared module, declaring targets/source sets, wiring the version catalog (Kotlin/AGP/Compose Multiplatform), configuring the iOS framework block, or deciding between expect/actual and interfaces + DI for platform-specific code.</q>. Assessment: creating, auditing, or upgrading a Kotlin Multiplatform shared module is strong but overlaps `kmp-boundaries` on expect/actual decisions.
- **Actionability 5:** `skills/house/mobile/kmp-module-setup/SKILL.md:12`. Source line: <q>Declaring `androidTarget()`, `iosArm64()`, `iosSimulatorArm64()` gives you the default hierarchy free (Kotlin ≥1.9.20), with no manual `dependsOn`:</q>. Assessment: Start from the default hierarchy leads through targets, versions, framework setup, platform seams, and verification.
- **Token economy 3:** `skills/house/mobile/kmp-module-setup/SKILL.md:28`. Source line: <q>kotlin = "2.4.10"                 # check current stable</q>. Assessment: verified matrix embeds version-era detail in the main file, increasing recurring load and staleness risk.
- **Correctness 4:** `skills/house/mobile/kmp-module-setup/SKILL.md:24`. Source line: <q>Pin Kotlin, AGP, and Compose Multiplatform together in `gradle/libs.versions.toml` and bump them together against the official compatibility table, because version drift between the three is the top setup failure.</q>. Assessment: Pin exact versions is sound reproducibility advice, and current Kotlin and Compose sources support the stated era, though the matrix will age.
- **Structure 5:** `skills/house/mobile/kmp-module-setup/SKILL.md:60`. Source line: <q>## Verification</q>. Assessment: Verification loop closes configuration with concrete Gradle and Xcode proof.
- **Scope 4:** `skills/house/mobile/kmp-module-setup/SKILL.md:54`. Source line: <q>| Situation | Use |</q>. Assessment: Choosing the platform seam gives a useful table but partially duplicates the dedicated boundary skill.
- **Verdict:** Exact-version and verification requirements make module setup reproducible across Android and iOS. Embedded version facts and duplicated boundary guidance will drift independently, so two KMP skills can disagree. Fix by moving the matrix to a dated reference and routing seam choice to `kmp-boundaries`.

### `port-from-repo`, 4.20, fix

- **Trigger 4:** `skills/house/platform/port-from-repo/SKILL.md:3`. Source line: <q>description: Bring a capability across from another codebase, study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.</q>. Assessment: bring a capability from one codebase into another clearly signals adaptation work, though it does not distinguish code from process assets.
- **Actionability 5:** `skills/house/platform/port-from-repo/SKILL.md:17`. Source line: <q>Fetch it outside this repository: a shallow clone in a temp directory, or `gh` reads against the API when you only need a few files. Never add it as a submodule, never vendor the tree, never edit it. You are reading a primary source, not acquiring a dependency.</q>. Assessment: Explore the source repository read-only begins a safe discovery, license, adaptation, test, and review path.
- **Token economy 4:** `skills/house/platform/port-from-repo/SKILL.md:25`. Source line: <q>Before any judgement about whether to port, be able to answer four questions:</q>. Assessment: Ask only questions that materially change keeps the interview bounded.
- **Correctness 3:** `skills/house/platform/port-from-repo/SKILL.md:71`. Source line: <q>Then record provenance in the commit message: the source repository, its licence, the specific commit or file path it came from, and what you changed on the way in. A port whose origin is folklore cannot be re-checked when the source fixes a bug.</q>. Assessment: Commit provenance assumes commit authority instead of requiring the provenance to be recorded in the requested artifact or handoff.
- **Structure 5:** `skills/house/platform/port-from-repo/SKILL.md:21`. Source line: <q>Read the licence before you read the code. Porting an approach rather than an expression is the safer footing, but a licence that restricts derivative work is a reason to stop and put it to the user, not a wall to work around.</q>. Assessment: Check license and provenance creates an essential gate before copying.
- **Scope 4:** `skills/house/platform/port-from-repo/SKILL.md:49`. Source line: <q>Decide where it lands before writing anything. Use the `/codebase-design` skill for the vocabulary: the seam it sits behind, how deep the module is, what the interface exposes. Treat the source's boundaries as evidence, not instruction: it drew them for its own codebase.</q>. Assessment: Use `/codebase-design` and later TDD and review composition keep specialized work delegated, though bare slash names weaken portability.
- **Verdict:** The read-only source inspection and license gate reduce accidental contamination. An unconditional provenance commit and bare skill-call syntax can fail under conservative policy or another harness. Fix the permission boundary and use canonical skill references with availability checks.

### `research`, 4.20, fix

- **Trigger 5:** `skills/engineering/research/SKILL.md:3`. Source line: <q>description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.</q>. Assessment: topic researched, docs or API facts gathered clearly identifies evidence-gathering work.
- **Actionability 3:** `skills/engineering/research/SKILL.md:6`. Source line: <q>Spin up a **background agent** to do the research, so you keep working while it reads.</q>. Assessment: Have a background subagent research delegates the whole task without specifying query formation, synthesis, conflict handling, or a fallback when no agent slot exists.
- **Token economy 5:** `skills/engineering/research/SKILL.md:10`. Source line: <q>1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.</q>. Assessment: prefer primary sources delivers its main quality rule in a short file.
- **Correctness 5:** `skills/engineering/research/SKILL.md:11`. Source line: <q>2. Write the findings to a single Markdown file, citing each claim's source.</q>. Assessment: Claim-level citation is the correct evidence contract for both repository and web research.
- **Structure 3:** `skills/engineering/research/SKILL.md:12`. Source line: <q>3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.</q>. Assessment: Write the report to a sensible location leaves naming, overwrite safety, and repository policy unresolved.
- **Scope 4:** `skills/engineering/research/SKILL.md:6`. Source line: <q>Spin up a **background agent** to do the research, so you keep working while it reads.</q>. Assessment: background subagent unnecessarily binds research quality to one execution mechanism instead of defining a research contract.
- **Verdict:** Primary-source preference is the right quality mechanism because it reduces hearsay. The skill outsources its reasoning and leaves the artifact location vague, so it can return inconsistent reports or fail when delegation is unavailable. Fix with an evidence matrix, conflict protocol, path resolution, and local fallback.

### `migrate-to-shoehorn`, 4.25, fix

- **Trigger 5:** `skills/misc/migrate-to-shoehorn/SKILL.md:3`. Source line: <q>description: Migrate test files from `as` type assertions to @total-typescript/shoehorn. Use when user mentions shoehorn, wants to replace `as` in tests, or needs partial test data.</q>. Assessment: mentions shoehorn" and "replace `as` in tests precisely identify the migration.
- **Actionability 4:** `skills/misc/migrate-to-shoehorn/SKILL.md:107`. Source line: <q>1. **Gather requirements** - ask user:</q>. Assessment: Workflow gives find, classify, replace, and test steps, but the search command is not repository-portable.
- **Token economy 4:** `skills/misc/migrate-to-shoehorn/SKILL.md:99`. Source line: <q>| Function        | Use case                                           |</q>. Assessment: Quick decision table compresses selection among `fromPartial`, `fromAny`, and arrays.
- **Correctness 4:** `skills/misc/migrate-to-shoehorn/SKILL.md:65`. Source line: <q>### `as Type` → `fromPartial()`</q>. Assessment: Use `fromPartial`" matches the current public API, though `skills/misc/migrate-to-shoehorn/SKILL.md:20`, "npm install does not mark a test-only helper as a development dependency.
- **Structure 5:** `skills/misc/migrate-to-shoehorn/SKILL.md:99`. Source line: <q>| Function        | Use case                                           |</q>. Assessment: Situation | Use makes transformation choice deterministic.
- **Scope 3:** `skills/misc/migrate-to-shoehorn/SKILL.md:12`. Source line: <q>**Test code only.** Never use shoehorn in production code.</q>. Assessment: test files only is a good boundary, but install, migration, and assertion philosophy remain coupled.
- **Verdict:** The decision table maps assertion shapes to the library API and reduces unsafe casts predictably. The install command can put a test helper in production dependencies, while `grep` ignores repository search conventions. Fix dependency flags and use capability-detected search commands.

### `writing-fragments`, 4.25, keep

- **Trigger 5:** `skills/in-progress/writing-fragments/SKILL.md:3`. Source line: <q>description: "Writing, explore: mine raw fragments, no structure yet."</q>. Assessment: capture raw fragments" and "turn notes into a fragment bank identify pre-draft collection.
- **Actionability 4:** `skills/in-progress/writing-fragments/SKILL.md:9`. Source line: <q>This is pure **explore**: widen the space of what could be written without committing to structure. Committing is _exploit_, a separate skill's job. Run a grilling session that produces fragments, interviewing the user relentlessly about whatever they want to write about. Imposing phases, outlines, or article structure is out of scope here.</q>. Assessment: Explore before writing creates a useful gather-first sequence, though destination discovery is light.
- **Token economy 4:** `skills/in-progress/writing-fragments/SKILL.md:25`. Source line: <q>A fragment is any piece of text that might survive into the final article. It must be _readable by the author_ (the author can tell what it means), but it does not need to define its terms or be comprehensible to a cold reader. The bar is "is this a piece of good writing?", not "is this a self-contained argument?"</q>. Assessment: A fragment is defines the unit compactly and prevents premature prose.
- **Correctness 4:** `skills/in-progress/writing-fragments/SKILL.md:15`. Source line: <q>Capture fragments from the very first thing the user says, including the initial prompt.</q>. Assessment: Starting at the initial prompt prevents loss of the user's original language, though it can also retain setup text that is not useful prose.
- **Structure 4:** `skills/in-progress/writing-fragments/SKILL.md:69`. Source line: <q>Fragments are separated by a horizontal rule (`\n---\n`). No headings inside the body. No tags. No order beyond the order they were added.</q>. Assessment: Format gives a stable artifact shape without excessive ceremony.
- **Scope 4:** `skills/in-progress/writing-fragments/SKILL.md:17`. Source line: <q>On first write, put a single H1 at the top with a working title (it can change later) and nothing else: no metadata, no TOC, no date.</q>. Assessment: The deliberately bare artifact keeps this in capture territory, though file naming is left to conversational memory.
- **Verdict:** A defined fragment unit and no-polish boundary preserve raw observations for later synthesis. Append-only behavior can accumulate duplicates or conflicting fragments because identity is unspecified. Keep it, adding source identifiers and deduplication guidance.

### `codebase-design`, 4.30, fix

- **Trigger 5:** `skills/engineering/codebase-design/SKILL.md:3`. Source line: <q>description: Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary.</q>. Assessment: deep modules", "where a seam goes", and "testable or AI-navigable provide strong architecture vocabulary.
- **Actionability 4:** `skills/engineering/codebase-design/SKILL.md:54`. Source line: <q>When designing an interface, ask:</q>. Assessment: Questions to ask supplies practical design probes, though it stops short of a decision record format.
- **Token economy 4:** `skills/engineering/codebase-design/SKILL.md:14`. Source line: <q>**Module**: anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice. _Avoid_: unit, component, service.</q>. Assessment: Vocabulary concentrates reusable concepts into short definitions.
- **Correctness 3:** `skills/engineering/codebase-design/SKILL.md:99`. Source line: <q>- A **Module** has exactly one **Interface** (the surface it presents to callers and tests).</q>. Assessment: exactly one Interface turns a useful heuristic into a universal rule, which can distort modules with multiple legitimate audiences.
- **Structure 5:** `skills/engineering/codebase-design/SKILL.md:62`. Source line: <q>- **Depth is a property of the interface, not the implementation.** A deep module can be internally composed of small, mockable, swappable parts; they just aren't part of the interface. A module can have **internal seams** (private to its implementation, used by its own tests) as well as the **external seam** at its interface.</q>. Assessment: Principles follows vocabulary with mechanisms, diagnostics, and examples in a clean reference shape.
- **Scope 5:** `skills/engineering/codebase-design/SKILL.md:8`. Source line: <q>Design **deep modules**: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface. Use this language and these principles wherever code is being designed or restructured. The aim is leverage for callers, locality for maintainers, and testability for everyone.</q>. Assessment: shared vocabulary correctly positions this as a foundation that other workflows can compose.
- **Verdict:** A common deep-module vocabulary makes design discussions comparable across skills. The single-interface absolute can force unrelated consumers through one bloated façade. Fix it to prefer the fewest coherent interfaces justified by distinct audiences.

### `grill-with-docs`, 4.30, fix

- **Trigger 5:** `skills/engineering/grill-with-docs/SKILL.md:3`. Source line: <q>description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.</q>. Assessment: The picker copy distinguishes it from stateless `grill-me` by naming the durable artifacts.
- **Actionability 4:** `skills/engineering/grill-with-docs/SKILL.md:7`. Source line: <q>Call the Skill tool twice, for "grilling" and "domain-modeling".</q>. Assessment: The composition is executable when both skills are available, but does not explain whether they run concurrently or share state sequentially.
- **Token economy 5:** `skills/engineering/grill-with-docs/SKILL.md:7`. Source line: <q>Call the Skill tool twice, for "grilling" and "domain-modeling".</q>. Assessment: Delegating both behaviors to their owners eliminates duplicated payload.
- **Correctness 4:** `skills/engineering/grill-with-docs/SKILL.md:7`. Source line: <q>Call the Skill tool twice, for "grilling" and "domain-modeling".</q>. Assessment: The two named skills exist and fit the promised behavior, but the wrapper does not state the shared-artifact handoff.
- **Structure 2:** `skills/engineering/grill-with-docs/SKILL.md:7`. Source line: <q>Call the Skill tool twice, for "grilling" and "domain-modeling".</q>. Assessment: One composition command has no explicit input, ordering, completion, or failure contract.
- **Scope 5:** `skills/engineering/grill-with-docs/SKILL.md:7`. Source line: <q>Call the Skill tool twice, for "grilling" and "domain-modeling".</q>. Assessment: It adds exactly one responsibility to grilling: persist domain language and decisions.
- **Verdict:** Reusing the two authoritative engines prevents duplicated interview and modeling rules. The wrapper leaves their coordination implicit, so one may finish without the other landing the decisions in repository memory. Fix with a one-paragraph shared-state and completion contract.

### `sync-upstream`, 4.30, keep

- **Trigger 5:** `skills/house/platform/sync-upstream/SKILL.md:3`. Source line: <q>description: "Merge mattpocock/skills into this fork: read the delta, resolve conflicts by recipe, assert the boundary, advance the lock, and land the sync PR. Run when upstream has commits this fork does not."</q>. Assessment: sync this osxsystem fork with upstream is repository-specific and unambiguous.
- **Actionability 5:** `skills/house/platform/sync-upstream/SKILL.md:21`. Source line: <q>Playbook step 2 hands you `git log` and `git diff --stat` over `<lock>..upstream/main`. Four things to look for, and one the playbook does not name:</q>. Assessment: Build the upstream delta leads through classification, conflict handling, regeneration, and verification.
- **Token economy 4:** `skills/house/platform/sync-upstream/SKILL.md:11`. Source line: <q>[`.fork/sync-playbook.md`](../../../../.fork/sync-playbook.md) is the procedure: nine numbered steps and every command you will type. Read it and follow it. This skill does not repeat it.</q>. Assessment: Read `MAINTENANCE.md` uses local documentation instead of duplicating all fork policy.
- **Correctness 4:** `skills/house/platform/sync-upstream/SKILL.md:41`. Source line: <q>**Not in the table.** Stop. Do not resolve it yet. Either the fork acquired a divergence nobody recorded, or upstream started writing a path the fork thought was its own. `git log upstream/main -- <path>` settles which: commits there mean the path is upstream's and the fork drifted onto it, while silence means the fork placed something in upstream territory without recording it. Then land the record, a `divergence.md` row plus a `sanctioned-edits.txt` line plus the matching row in the playbook's table, as part of this sync. The next maintainer should meet a documented conflict instead of your surprise.</q>. Assessment: stop on an unknown conflict correctly fails closed, though any upstream layout change can stale the hardcoded paths.
- **Structure 5:** `skills/house/platform/sync-upstream/SKILL.md:31`. Source line: <q>## Classify every conflict before resolving any</q>. Assessment: Classify every changed path makes provenance handling explicit before merge decisions.
- **Scope 1:** `skills/house/platform/sync-upstream/SKILL.md:68`. Source line: <q>**`gh pr create` fails with "must be a collaborator."** `git push` and `gh` authenticate separately. The push goes over SSH while `gh` may be active as an account with only READ here. Check with `gh auth status`, switch with `gh auth switch -u <account>`, and switch back once the PR is merged so the machine is left as you found it. Every `gh` command here also needs `--repo hugues-vnsgn/skills`, `create` and `merge` alike, or it addresses the wrong repository.</q>. Assessment: this repository makes the skill intentionally unusable elsewhere and explains its internal metadata.
- **Verdict:** Path classification and fail-closed conflicts protect the fork boundary during sync. Its extreme repository specificity is appropriate only because it is internal; publication would create a nonfunctional skill. Keep it internal and regression-test it against upstream layout changes.

### `unslop`, 4.30, keep

- **Trigger 4:** `skills/house/writing/unslop/SKILL.md:3`. Source line: <q>description: "Strip AI tells from human-facing prose and give it a voice. Use before publishing or sending anything a person reads: a README, docs page, PR description, release notes, changelog, commit body, blog post, or email. Also use when text is called slop, AI-sounding, generic, corporate, or wordy, or when someone asks to make writing sound human. Skip it for chat replies, one-line commit subjects, and code comments written in passing. For a document an agent reads, run writing-for-agents first and this second."</q>. Assessment: AI-sounding, generic, corporate, or wordy" gives recognizable style symptoms, though "before publishing makes implicit invocation broad.
- **Actionability 5:** `skills/house/writing/unslop/SKILL.md:14`. Source line: <q>1. **Read the whole thing first.** Slop is often structural: three sections restating one idea at three lengths, a summary of a page the reader just read. A sentence-level pass never sees that.</q>. Assessment: Work in three passes turns voice editing into diagnosis, revision, and verification.
- **Token economy 3:** `skills/house/writing/unslop/SKILL.md:25`. Source line: <q>Four registers, because the voice advice below is actively wrong for two of them.</q>. Assessment: Registers begins a long style reference that is loaded even when only one phrase needs repair.
- **Correctness 4:** `skills/house/writing/unslop/SKILL.md:49`. Source line: <q>### When a claim is missing its evidence</q>. Assessment: Interrogate claims correctly ties prose confidence to evidence, though stylistic signals are heuristics rather than proof of machine authorship.
- **Structure 5:** `skills/house/writing/unslop/SKILL.md:111`. Source line: <q>## Report</q>. Assessment: Report closes with a concise change summary and retained uncertainties.
- **Scope 5:** `skills/house/writing/unslop/SKILL.md:123`. Source line: <q>This is an edit pass and it needs prose to edit. Starting from nothing, three parts still apply: set the register before you write, keep [Leave alone](#leave-alone) in view so you do not draft a claim you cannot source, and aim at [Nothing said](#1-nothing-said) rather than fixing it afterwards. For getting from raw notes to a draft, that is `writing-fragments` and `writing-shape`.</q>. Assessment: Do not run on chat replies" and `skills/house/writing/unslop/SKILL.md:127`, "run `writing-for-agents` first clearly bound exclusions and composition.
- **Verdict:** Claim interrogation and register-aware passes remove generic language without flattening voice. The long embedded catalog costs tokens and can encourage checklist editing instead of listening to the draft. Keep it, moving most pattern examples into on-demand references.

### `setup-osxsystem-skills`, 4.35, keep

- **Trigger 5:** `skills/house/platform/setup-osxsystem-skills/SKILL.md:3`. Source line: <q>description: "Configure this repo for the engineering skills: set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills."</q>. Assessment: asks to use this repository's skills in another repository precisely identifies local harness setup.
- **Actionability 5:** `skills/house/platform/setup-osxsystem-skills/SKILL.md:19`. Source line: <q>### 1. Explore</q>. Assessment: Explore the target repository first leads through convention discovery, issue tracking, confirmation, and file changes.
- **Token economy 3:** `skills/house/platform/setup-osxsystem-skills/SKILL.md:104`. Source line: <q>Then write the docs files using the seed templates in this skill folder as a starting point:</q>. Assessment: Reference files supports progressive disclosure, but the main skill still carries multiple provider-specific branches.
- **Correctness 4:** `skills/house/platform/setup-osxsystem-skills/SKILL.md:80`. Source line: <q>Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa); always edit the one that's already there.</q>. Assessment: Never create the counterpart file protects established instruction-file choice, though installation behavior is tied to this fork's current layout.
- **Structure 5:** `skills/house/platform/setup-osxsystem-skills/SKILL.md:63`. Source line: <q>### 3. Confirm and edit</q>. Assessment: Confirm the plan creates a clear gate before target-repository edits.
- **Scope 3:** `skills/house/platform/setup-osxsystem-skills/SKILL.md:9`. Source line: <q>Scaffold the per-repo configuration that the engineering skills assume:</q>. Assessment: instruction file", "issue-tracker guidance", and "skill discovery combine several setup concerns in one repo-specific tool.
- **Verdict:** Target-first discovery and counterpart protection prevent clobbering repository conventions. Provider branches can drift as harnesses change, causing a setup that appears complete but exposes the wrong skills. Keep it internal and add fixture-based setup tests for each supported harness.

### `setup-ts-deep-modules`, 4.35, fix

- **Trigger 5:** `skills/in-progress/setup-ts-deep-modules/SKILL.md:3`. Source line: <q>description: Wire dependency-cruiser into a TypeScript repo so each package is a deep module, with implementation hidden in subfolders and reachable only through its entry-point files. User-invoked.</q>. Assessment: Set up TypeScript package boundaries identifies a concrete architectural setup task, though it overlaps general deep-module design.
- **Actionability 5:** `skills/in-progress/setup-ts-deep-modules/SKILL.md:39`. Source line: <q>### 1. Detect the environment</q>. Assessment: Detect the package manager starts a detailed install, configure, migrate, and prove workflow.
- **Token economy 3:** `skills/in-progress/setup-ts-deep-modules/SKILL.md:24`. Source line: <q>The public surface is the package's **root files**, not one designated `index.ts`. By convention implementation lives in `lib/` and tests in `tests/`, giving every package the same two-folder shape. The rule itself is general, though: *anything* in *any* subfolder is private, so you never extend the config to add a folder.</q>. Assessment: Identify package entry points is valuable, but the long universal playbook loads migration detail for greenfield setup too.
- **Correctness 4:** `skills/in-progress/setup-ts-deep-modules/SKILL.md:41`. Source line: <q>- **Package manager**: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lockb` → bun, else npm. Use it for every command below (`pnpm`/`yarn`/`npm run`/`bunx`).</q>. Assessment: Default to `src/` can invent a layout when an existing repository uses app, lib, or workspace-specific boundaries.
- **Structure 5:** `skills/in-progress/setup-ts-deep-modules/SKILL.md:81`. Source line: <q>This is the completion criterion for the whole skill: a config that doesn't fail on a violation is worthless.</q>. Assessment: Prove the boundary supplies observable verification rather than ending at configuration.
- **Scope 3:** `skills/in-progress/setup-ts-deep-modules/SKILL.md:91`. Source line: <q>Write a `README.md` **in the packages folder** (`<packages-root>/README.md`, next to the packages it governs) covering: the `src/packages/<name>/` layout (entry points at the root, `lib/` for implementation, `tests/` for tests), "import only through a package's entry points (its root files)", and how to run `lint:boundaries`. **Discourage barrel files** explicitly: expose several small entry points instead of re-exporting a whole subtree through one index. Keep it to the copy-me snippet plus the four rules in one paragraph each.</q>. Assessment: Update the project documentation combines architecture design, package setup, source migration, and documentation without separate authorization points.
- **Verdict:** The proof step turns an import policy into an enforced boundary. Layout defaults can override local structure and create a large migration from a setup request. Fix with repository discovery, separate greenfield and retrofit modes, and an explicit migration gate.

### `wayfinder`, 4.35, keep

- **Trigger 4:** `skills/engineering/wayfinder/SKILL.md:3`. Source line: <q>description: Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear.</q>. Assessment: unfinished work" and "pick the next useful task capture navigation, though they overlap tracker triage.
- **Actionability 5:** `skills/engineering/wayfinder/SKILL.md:21`. Source line: <q>The map is a single issue on this repo's issue tracker, labelled `wayfinder:map`, the canonical artifact. Its tickets are child issues of the map.</q>. Assessment: Map the terrain leads through repository state, tracker frontier, human gates, and one selected task.
- **Token economy 4:** `skills/engineering/wayfinder/SKILL.md:69`. Source line: <q>Blocking uses the tracker's **native** dependency relationship: essential because it renders the frontier _visually_ in the tracker's own UI, so the human sees what's takeable without opening the map. Only a tracker that lacks native blocking falls back to a body convention. A ticket is **unblocked** when every ticket blocking it is closed; the **frontier** is the open, unblocked, unclaimed children, the edge of the known.</q>. Assessment: frontier compresses dependency-aware selection into a useful concept.
- **Correctness 4:** `skills/engineering/wayfinder/SKILL.md:75`. Source line: <q>Every ticket is either **HITL** (human in the loop, worked _with_ a human who speaks for themselves) or **AFK**, driven by the agent alone. A HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this).</q>. Assessment: Human-in-the-loop gates correctly stops at decisions requiring ownership, though tracker command details are deferred.
- **Structure 5:** `skills/engineering/wayfinder/SKILL.md:105`. Source line: <q>Two modes. Either way, **never resolve more than one ticket per session**, with the exception of research tickets.</q>. Assessment: End with one recommended ticket gives a crisp terminal contract.
- **Scope 4:** `skills/engineering/wayfinder/SKILL.md:13`. Source line: <q>Wayfinder is **planning** by default: each ticket resolves a decision, and the map is done when the way is clear, with nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off. An effort can override this in its **Notes**, carrying execution into the map itself, but absent that, produce decisions, not deliverables.</q>. Assessment: Plan work, do not perform it cleanly prevents implementation, but it also touches naming, architecture, and tracker health.
- **Verdict:** Frontier selection turns a noisy backlog into one dependency-valid next action. The broad trigger can compete with `triage` when issue metadata is messy. Keep it and sharpen the boundary: triage repairs classification, wayfinder chooses among already viable work.

### `kmp-test-seams`, 4.40, keep

- **Trigger 5:** `skills/house/mobile/kmp-test-seams/SKILL.md:3`. Source line: <q>description: Use when a Kotlin Multiplatform repo raises the question of where a test belongs or which Gradle task proves it, whether commonTest or androidHostTest/iosTest, seams that live in commonMain over platform services, and choosing jvmTest, testDebugUnitTest or iosSimulatorArm64Test to run a slice.</q>. Assessment: where a test belongs and named Gradle tasks match concrete KMP testing questions.
- **Actionability 4:** `skills/house/mobile/kmp-test-seams/SKILL.md:8`. Source line: <q>The platform layer underneath the red → green loop. The loop itself, and what makes a test worth keeping, belong to the `tdd` skill, so run that. This answers the two questions KMP adds to it: **where does the seam go**, and **which Gradle task proves the slice green**.</q>. Assessment: Use this order provides a layered decision path but few worked examples in the main file.
- **Token economy 5:** `skills/house/mobile/kmp-test-seams/SKILL.md:12`. Source line: <q>In a KMP repo, the seam question has a platform dimension: prefer seams that live in `commonMain` (interfaces over platform services, covered by the `kmp-module-setup` skill), so the red-green loop runs in `commonTest` with `kotlin.test` and multiplatform fakes. Tests land in `commonTest` unless they exercise a platform `actual` (then `androidHostTest` / `iosTest`). Run the loop with the cheapest task that covers the seam, `jvmTest` for pure common logic, or `iosSimulatorArm64Test` / `testDebugUnitTest` before claiming a platform-touching slice green. Task map: the `kmp-release-and-publish` skill.</q>. Assessment: Test behavior at the highest shared layer states the governing rule in one sentence.
- **Correctness 4:** `skills/house/mobile/kmp-test-seams/SKILL.md:8`. Source line: <q>The platform layer underneath the red → green loop. The loop itself, and what makes a test worth keeping, belong to the `tdd` skill, so run that. This answers the two questions KMP adds to it: **where does the seam go**, and **which Gradle task proves the slice green**.</q>. Assessment: commonTest or androidHostTest/iosTest reflects current source-set distinctions, though task names can vary by target configuration.
- **Structure 4:** `skills/house/mobile/kmp-test-seams/SKILL.md:8`. Source line: <q>The platform layer underneath the red → green loop. The loop itself, and what makes a test worth keeping, belong to the `tdd` skill, so run that. This answers the two questions KMP adds to it: **where does the seam go**, and **which Gradle task proves the slice green**.</q>. Assessment: Layer 1 through platform layers is coherent, but success criteria are mostly implicit.
- **Scope 4:** `skills/house/mobile/kmp-test-seams/SKILL.md:12`. Source line: <q>In a KMP repo, the seam question has a platform dimension: prefer seams that live in `commonMain` (interfaces over platform services, covered by the `kmp-module-setup` skill), so the red-green loop runs in `commonTest` with `kotlin.test` and multiplatform fakes. Tests land in `commonTest` unless they exercise a platform `actual` (then `androidHostTest` / `iosTest`). Run the loop with the cheapest task that covers the seam, `jvmTest` for pure common logic, or `iosSimulatorArm64Test` / `testDebugUnitTest` before claiming a platform-touching slice green. Task map: the `kmp-release-and-publish` skill.</q>. Assessment: highest shared layer keeps the focus on seam placement while still covering task selection.
- **Verdict:** The highest-shared-layer rule minimizes duplicate tests while preserving platform proof. Variant-dependent task names can fail in differently configured projects. Keep it, adding a discovery command before recommending an exact Gradle task.

### `grill-me`, 4.45, keep

- **Trigger 5:** `skills/productivity/grill-me/SKILL.md:3`. Source line: <q>description: A relentless interview to sharpen a plan or design.</q>. Assessment: The human-facing picker copy names the exact conversational outcome.
- **Actionability 4:** `skills/productivity/grill-me/SKILL.md:7`. Source line: <q>Call the Skill tool with "grilling".</q>. Assessment: The invocation is direct and delegates behavior to its single owner, though it depends on the skill registry.
- **Token economy 5:** `skills/productivity/grill-me/SKILL.md:7`. Source line: <q>Call the Skill tool with "grilling".</q>. Assessment: A one-line alias adds no duplicate interview instructions.
- **Correctness 5:** `skills/productivity/grill-me/SKILL.md:7`. Source line: <q>Call the Skill tool with "grilling".</q>. Assessment: The referenced skill exists and exactly implements the promised interview.
- **Structure 2:** `skills/productivity/grill-me/SKILL.md:7`. Source line: <q>Call the Skill tool with "grilling".</q>. Assessment: The wrapper has no independent input or completion contract, relying entirely on the callee.
- **Scope 5:** `skills/productivity/grill-me/SKILL.md:7`. Source line: <q>Call the Skill tool with "grilling".</q>. Assessment: It is a pure user-facing alias and adds no second responsibility.
- **Verdict:** Delegating to one authoritative interview engine prevents instruction drift. The wrapper is intentionally shallow, so its only maintenance risk is a renamed or unavailable callee. Keep it and cover the reference with catalog validation.

### `kmp-ios-integration`, 4.45, keep

- **Trigger 5:** `skills/house/mobile/kmp-ios-integration/SKILL.md:3`. Source line: <q>description: Use when connecting a Kotlin Multiplatform shared module to an iOS/Xcode app, choosing between direct integration, CocoaPods, SPM, or KMMBridge; setting up embedAndSignAppleFrameworkForXcode or the cocoapods plugin; debugging "pod not found", script-sandboxing, or framework-not-found Xcode errors; or reviewing Kotlin API that Swift will consume (sealed classes, suspend functions, @Throws, generics).</q>. Assessment: "Xcode app", "CocoaPods", "SPM", and concrete error strings provide rich routing signals.
- **Actionability 5:** `skills/house/mobile/kmp-ios-integration/SKILL.md:23`. Source line: <q>1. `binaries.framework {}` declared on the iOS targets.</q>. Assessment: Direct integration checklist gives ordered Xcode and Gradle setup steps.
- **Token economy 3:** `skills/house/mobile/kmp-ios-integration/SKILL.md:12`. Source line: <q>| Pick | When |</q>. Assessment: Choose the integration path loads four delivery modes even when the user has named one.
- **Correctness 4:** `skills/house/mobile/kmp-ios-integration/SKILL.md:41`. Source line: <q>- **`@Throws(Exception::class)` on anything that throws**: otherwise a Kotlin exception **crashes** the app instead of surfacing as a Swift `throws`.</q>. Assessment: Annotate throwable APIs with `@Throws` aligns with current Kotlin Swift/Objective-C interop guidance, though not every throwable internal API should be exported.
- **Structure 5:** `skills/house/mobile/kmp-ios-integration/SKILL.md:12`. Source line: <q>| Pick | When |</q>. Assessment: Path | Use when separates selection from path-specific checklists.
- **Scope 4:** `skills/house/mobile/kmp-ios-integration/SKILL.md:37`. Source line: <q>## Swift-facing API review checklist</q>. Assessment: Review the Swift-facing API correctly includes consumer ergonomics, but broadens beyond build integration.
- **Verdict:** A path table followed by checklists reduces accidental mixing of CocoaPods, direct, SPM, and KMMBridge setup. Loading every path and broad API advice is costly for a known integration mode. Keep it with progressive path references and qualify `@Throws` to exported failure contracts.

### `kmp-release-and-publish`, 4.45, keep

- **Trigger 5:** `skills/house/mobile/kmp-release-and-publish/SKILL.md:3`. Source line: <q>description: Use when shipping a Kotlin Multiplatform app or library, covering Android release builds/Play Store (R8 with shared code), iOS archiving/TestFlight/App Store (privacy manifest, dSYMs), publishing a KMP library to Maven Central, setting up CI (GitHub Actions runner split, konan caching), or choosing which Gradle task runs which tests.</q>. Assessment: Play Store", "TestFlight", "Maven Central", and "CI cover concrete shipping intents.
- **Actionability 5:** `skills/house/mobile/kmp-release-and-publish/SKILL.md:12`. Source line: <q>A KMP Android app is a normal Android app, built with `./gradlew :androidApp:bundleRelease` and standard signing, and Play Store can't tell the difference. The KMP-specific part is **R8**: shared-module code is shrunk too, so reflection users (kotlinx.serialization, Ktor, Koin, Room) in `commonMain` need keep rules. Always QA a minified build; read `missing_rules.txt` on failure. Library modules on the new AGP-KMP plugin publish consumer rules via `androidLibrary.optimization.consumerKeepRules` (the old `consumerProguardFiles` doesn't apply).</q>. Assessment: Android release begins platform-specific checklists and maps tasks to proof.
- **Token economy 3:** `skills/house/mobile/kmp-release-and-publish/SKILL.md:32`. Source line: <q>## CI topology (GitHub Actions)</q>. Assessment: CI shape lives beside three publication workflows, so any one release loads the others.
- **Correctness 4:** `skills/house/mobile/kmp-release-and-publish/SKILL.md:42`. Source line: <q>## Test task map</q>. Assessment: Which test task proves what correctly distinguishes shared, Android, and iOS tests, though store rules and tool versions age quickly.
- **Structure 5:** `skills/house/mobile/kmp-release-and-publish/SKILL.md:23`. Source line: <q>## Library → Maven Central (2026 route)</q>. Assessment: Maven Central and sibling sections provide clear mode separation.
- **Scope 4:** `skills/house/mobile/kmp-release-and-publish/SKILL.md:8`. Source line: <q>Ship KMP apps to the stores, libraries to Maven Central, and set up CI that doesn't burn macOS minutes. Full walkthroughs with YAML/Gradle: [reference.md](reference.md).</q>. Assessment: shipping a Kotlin Multiplatform app or library honestly declares its broad delivery scope.
- **Verdict:** Platform-separated checklists and proof-task mapping reduce false release confidence. Fast-moving store and CI details can stale independently, causing a checklist to pass while submission fails. Keep it, date external facts and split app, library, and CI details into on-demand references.

### `to-prd`, 4.45, fix

- **Trigger 5:** `skills/house/discovery/to-prd/SKILL.md:3`. Source line: <q>description: Turn the current conversation into a Product Requirements Document, synthesis first, questions only for what can't be inferred, saved in the repo and linked from the tracker.</q>. Assessment: turn a product idea into a PRD precisely identifies the requested artifact.
- **Actionability 5:** `skills/house/discovery/to-prd/SKILL.md:17`. Source line: <q>1. Ground yourself in the repo, if you haven't already. Use the project's domain glossary vocabulary (`CONTEXT.md`) throughout the PRD, and respect any ADRs touching this area, because a PRD that contradicts a recorded decision needs to say so explicitly, not silently.</q>. Assessment: Draft the PRD leads through goals, gaps, review, storage, and tracker linkage.
- **Token economy 4:** `skills/house/discovery/to-prd/SKILL.md:39`. Source line: <q><prd-template></q>. Assessment: Template is substantial but directly reusable.
- **Correctness 3:** `skills/house/discovery/to-prd/SKILL.md:33`. Source line: <q>4. Write the PRD using the template below. Write for a reader outside the building: short sentences, no jargon beyond the project glossary, every claim either grounded or flagged. Save it as `PRD-<product-name>.md` wherever the project keeps product documents; if there is no established place, use `docs/product/`.</q>. Assessment: `PRD-<slug>.md` conflicts with the lowercase naming policy in `project-organization`.
- **Structure 5:** `skills/house/discovery/to-prd/SKILL.md:23`. Source line: <q>3. Identify the genuine gaps. Some sections can't be invented on the user's behalf, because they're decisions, not facts:</q>. Assessment: Identify gaps creates a user decision gate rather than inventing product facts.
- **Scope 4:** `skills/house/discovery/to-prd/SKILL.md:35`. Source line: <q>5. Publish a tracker issue titled `PRD: <product name>` containing the Summary section and a link to the file. Do **not** apply the `ready-for-agent` label, because a PRD is not implementable work; it's the anchor that specs and tickets will reference.</q>. Assessment: Link it to the tracker connects discovery to delivery, though tracker mutation needs permission awareness.
- **Verdict:** Explicit gap review keeps assumptions out of the product contract. Conflicting filename rules make two valid skills prescribe incompatible artifacts, so output depends on invocation order. Fix by deferring naming to repository policy and treating tracker updates as a separately authorized step.

### `triage`, 4.45, keep

- **Trigger 5:** `skills/engineering/triage/SKILL.md:3`. Source line: <q>description: Move issues and external PRs through a state machine of triage roles, categorise, verify, grill if needed, and write agent-ready briefs.</q>. Assessment: triage issues", "apply labels", and "work out what is ready give strong tracker-state cues.
- **Actionability 5:** `skills/engineering/triage/SKILL.md:70`. Source line: <q>1. **Gather context.** Read the full issue or PR (body, comments, labels, author, dates; for a PR, the diff too). Parse any prior triage notes so you don't re-ask resolved questions. Explore the codebase using the project's domain glossary, respecting ADRs in the area. Run two checks against the codebase: (a) **redundancy**: search for an existing implementation of the requested behavior by domain concept (not just the request's wording), and report where you looked. If found, it's an already-implemented `wontfix` (step 5). (b) **prior rejection**: read `.out-of-scope/*.md` and surface any that resembles this request.</q>. Assessment: Triage process provides a concrete inspect, classify, label, and verify loop.
- **Token economy 3:** `skills/engineering/triage/SKILL.md:49`. Source line: <q>The maintainer invokes `/triage` and describes what they want in natural language. Interpret the request and act. Examples:</q>. Assessment: Examples and a full state model add weight, but prevent subtle role confusion.
- **Correctness 4:** `skills/engineering/triage/SKILL.md:41`. Source line: <q>Every triaged issue should carry exactly one category role and one state role. If state roles conflict, flag it and ask the maintainer before doing anything else.</q>. Assessment: Exactly one routing role creates deterministic classification, though a tracker may temporarily need no role during atomic updates.
- **Structure 5:** `skills/engineering/triage/SKILL.md:31`. Source line: <q>Five **state** roles:</q>. Assessment: State model makes transitions and terminal states explicit.
- **Scope 4:** `skills/engineering/triage/SKILL.md:13`. Source line: <q>Every comment or issue posted to the issue tracker during triage **must** start with this disclaimer:</q>. Assessment: does not decide implementation order separates classification from `wayfinder` well.
- **Verdict:** An explicit state machine makes label meaning auditable and keeps triage separate from scheduling. The exactly-one rule can briefly conflict with tracker mutation semantics or foreign labels. Keep it, specifying atomic transition behavior and treatment of unknown labels.

### `wait-what`, 4.45, fix

- **Trigger 5:** `skills/productivity/wait-what/SKILL.md:3`. Source line: <q>description: "Stop. That last message did not land: re-pitch it."</q>. Assessment: explain the current topic more slowly captures a recognizable user need and common phrasing.
- **Actionability 5:** `skills/productivity/wait-what/SKILL.md:7`. Source line: <q>Wait, I don't understand where you've got to here. Re-pitch that: give me a little bit of context, talk in ASD-STE100 Simplified Technical English, and use the ubiquitous language from `CONTEXT.md` (follow `CONTEXT-MAP.md` to the right one if the repo has more than one).</q>. Assessment: Re-explain ... in plain language gives a direct action but no method for locating the exact point of confusion.
- **Token economy 5:** `skills/productivity/wait-what/SKILL.md:7`. Source line: <q>Wait, I don't understand where you've got to here. Re-pitch that: give me a little bit of context, talk in ASD-STE100 Simplified Technical English, and use the ubiquitous language from `CONTEXT.md` (follow `CONTEXT-MAP.md` to the right one if the repo has more than one).</q>. Assessment: One sentence carries the complete repitch contract with negligible loading cost.
- **Correctness 4:** `skills/productivity/wait-what/SKILL.md:7`. Source line: <q>Wait, I don't understand where you've got to here. Re-pitch that: give me a little bit of context, talk in ASD-STE100 Simplified Technical English, and use the ubiquitous language from `CONTEXT.md` (follow `CONTEXT-MAP.md` to the right one if the repo has more than one).</q>. Assessment: Repository language preserves local meaning, but the instruction assumes a glossary exists and gives no fallback when neither context file is present.
- **Structure 2:** `skills/productivity/wait-what/SKILL.md:7`. Source line: <q>Wait, I don't understand where you've got to here. Re-pitch that: give me a little bit of context, talk in ASD-STE100 Simplified Technical English, and use the ubiquitous language from `CONTEXT.md` (follow `CONTEXT-MAP.md` to the right one if the repo has more than one).</q>. Assessment: Re-explain is one paragraph with no observable phases or completion condition.
- **Scope 4:** `skills/productivity/wait-what/SKILL.md:7`. Source line: <q>Wait, I don't understand where you've got to here. Re-pitch that: give me a little bit of context, talk in ASD-STE100 Simplified Technical English, and use the ubiquitous language from `CONTEXT.md` (follow `CONTEXT-MAP.md` to the right one if the repo has more than one).</q>. Assessment: current topic stays narrow, though it can overlap any explanatory response without a signal that prose has failed.
- **Verdict:** Simplified English plus repository vocabulary is an efficient repair for jargon-heavy explanations. A missing glossary or unidentified conceptual gap can still produce a shorter version of the same confusion. Fix with a no-glossary fallback and one comprehension check.

### `writing-for-agents`, 4.45, keep

- **Trigger 5:** `skills/productivity/writing-for-agents/SKILL.md:3`. Source line: <q>description: Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md.</q>. Assessment: creating or editing skills" and "AGENTS.md or CLAUDE.md name the exact agent-facing artifacts.
- **Actionability 4:** `skills/productivity/writing-for-agents/SKILL.md:14`. Source line: <q>A pointer does two jobs: state what the material is, and list the **branches** that should trigger reaching it (a branch is a distinct case the document handles, so different runs take different paths through it). Every word of an always-loaded pointer costs on every turn, so it earns even harder pruning than the body:</q>. Assessment: Do two jobs gives a clear routing and instruction-design process, though it lacks a mechanical validation command.
- **Token economy 4:** `skills/productivity/writing-for-agents/SKILL.md:39`. Source line: <q>**Progressive disclosure** is the move down the ladder (out of the main file and behind a pointer) so the top stays legible. Not primarily a token optimisation: it is how the hierarchy is protected. Branching is the cleanest disclosure test: inline what every branch needs, and push behind a pointer what only some branches reach. When a document has steps, in-file reference that should be disclosed buries them and turns attending to them into a coin-flip: a variance lever, not just a legibility one.</q>. Assessment: Progressive disclosure teaches how to control future context cost without excessive examples.
- **Correctness 4:** `skills/productivity/writing-for-agents/SKILL.md:78`. Source line: <q>- Keep each meaning in a **single source of truth**: one authoritative place, so changing the behaviour is a one-place edit. **Duplication** (the same meaning in more than one place) costs maintenance and tokens, and inflates a meaning's prominence on the ladder past its real rank. (The accidental inverse of a leading word, which repeats a token on purpose, never the meaning.)</q>. Assessment: One source of truth correctly prevents mirrored instructions, though every repository still needs local precedence discovery.
- **Structure 5:** `skills/productivity/writing-for-agents/SKILL.md:22`. Source line: <q>Every document and pointer you add spends one of two budgets:</q>. Assessment: Routing layer followed by instruction layer, hierarchy, and quality criteria is a strong conceptual progression.
- **Scope 5:** `skills/productivity/writing-for-agents/SKILL.md:81`. Source line: <q>- Hunt **no-ops** sentence by sentence: an instruction the model already obeys by default pays load to say nothing. The test (does it change behaviour versus the default?) is model-relative, not reader-relative: two people disagreeing about a no-op disagree about the default, and settle it by running the document, not by debate. When a sentence fails, delete the whole sentence rather than trim words from it. The test also grades leading words: a word too weak to beat the default (_be thorough_ when the agent is already thorough-ish) is a no-op, and the fix is a stronger word (_relentless_), not a different technique.</q>. Assessment: If the edit would be a no-op, do not make it gives a disciplined terminal boundary.
- **Verdict:** Separating routing from instruction design explains both why a skill fires and how it steers. The absence of a required repository validator can leave structurally elegant instructions that fail local conventions. Keep it and compose repository-specific checks at completion.

### `loop-me`, 4.50, fix

- **Trigger 5:** `skills/in-progress/loop-me/SKILL.md:3`. Source line: <q>description: Grill me about specs for the workflows I want to build, within this workspace.</q>. Assessment: Iterate on a plan or design through repeated critique is clear but competes with `grilling`, `when-stuck`, and `prototype`.
- **Actionability 5:** `skills/in-progress/loop-me/SKILL.md:8`. Source line: <q>Run a stateful `/grilling` session whose only output is **workflow** specs. Use the grilling discipline (relentless, a round of questions at a time, a recommended answer attached to each) aimed at the vocabulary and goal below. Create, edit, and delete specs as the grilling resolves things.</q>. Assessment: Use `$grilling` for each critique round gives the loop an executable engine.
- **Token economy 4:** `skills/in-progress/loop-me/SKILL.md:18`. Source line: <q>A shared language, reached for only when a workflow calls for it: never a checklist. **Mandate nothing structural**: a workflow needs no AI, no checkpoint, and no schedule unless the grilling shows it does.</q>. Assessment: Do not force a fixed number of rounds prevents ceremony and unnecessary tokens.
- **Correctness 4:** `skills/in-progress/loop-me/SKILL.md:25`. Source line: <q>## Definition of done</q>. Assessment: The skill has an explicit completion section, though its next line demands zero implementer questions, an absolute that can encourage overspecification.
- **Structure 5:** `skills/in-progress/loop-me/SKILL.md:12`. Source line: <q>A **loop** is a recurring pattern in the user's life: their career, their week, their morning, a single repeated activity. Picturing a life as loops within loops reveals how predictable its activities really are, which is what makes them worth **delegating**. Use the lens to find loops worth specifying, and propose ones the user hasn't noticed.</q>. Assessment: Maintain one shared vocabulary preserves state across rounds and prevents semantic drift.
- **Scope 3:** `skills/in-progress/loop-me/SKILL.md:31`. Source line: <q>- `workflows/*.md`: one spec per workflow.</q>. Assessment: A single artifact type keeps the output narrow, but fixed workspace paths reduce portability.
- **Verdict:** A shared loop vocabulary and one-spec-per-workflow rule make repeated-life-process design concrete. Fixed workspace structure and a zero-question completion bar can create excessive detail in an unfamiliar repository. Keep the concept, then add repository discovery and a bounded unknowns section.

### `setup-pre-commit`, 4.50, fix

- **Trigger 5:** `skills/misc/setup-pre-commit/SKILL.md:3`. Source line: <q>description: Set up Husky pre-commit hooks with lint-staged (Prettier), type checking, and tests in the current repo. Use when user wants to add pre-commit hooks, set up Husky, configure lint-staged, or add commit-time formatting/typechecking/testing.</q>. Assessment: add pre-commit hooks", "Husky", and "lint-staged precisely identify the setup.
- **Actionability 5:** `skills/misc/setup-pre-commit/SKILL.md:19`. Source line: <q>Check for `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn), `bun.lockb` (bun). Use whichever is present. Default to npm if unclear.</q>. Assessment: Detect the package manager begins an executable dependency, initialization, configuration, and verification sequence.
- **Token economy 4:** `skills/misc/setup-pre-commit/SKILL.md:53`. Source line: <q>"*": "prettier --ignore-unknown --write"</q>. Assessment: One lint-staged rule covers supported staged files without a long extension list.
- **Correctness 4:** `skills/misc/setup-pre-commit/SKILL.md:32`. Source line: <q>npx husky init</q>. Assessment: The command matches current Husky guidance, though project scripts and package-manager equivalents still need local adaptation.
- **Structure 5:** `skills/misc/setup-pre-commit/SKILL.md:73`. Source line: <q>### 7. Verify</q>. Assessment: Verify requires an actual hook exercise rather than configuration inspection alone.
- **Scope 3:** `skills/misc/setup-pre-commit/SKILL.md:81`. Source line: <q>### 8. Commit</q>. Assessment: Commit the setup unconditionally crosses from tooling configuration into source-control authority.
- **Verdict:** Package-manager detection and a live hook test prove the setup on the actual project. The final commit instruction violates conservative repositories and can include unrelated changes. Fix by ending with a change summary and suggested commit, leaving commit authority to the active policy.

### `git-guardrails-claude-code`, 4.55, keep

- **Trigger 5:** `skills/misc/git-guardrails-claude-code/SKILL.md:3`. Source line: <q>description: Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in Claude Code.</q>. Assessment: prevent destructive git operations and named commands give precise safety triggers.
- **Actionability 5:** `skills/misc/git-guardrails-claude-code/SKILL.md:32`. Source line: <q>The bundled script is at: [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh)</q>. Assessment: Create the guard script leads through scope selection, hook creation, merge, and verification.
- **Token economy 4:** `skills/misc/git-guardrails-claude-code/SKILL.md:12`. Source line: <q>- `git push` (all variants including `--force`)</q>. Assessment: Commands blocked makes the protection set easy to scan, though the embedded script is substantial.
- **Correctness 5:** `skills/misc/git-guardrails-claude-code/SKILL.md:20`. Source line: <q>`git commit -m "explain git push"`, `grep -r "git push" docs/`, and `git pushd /tmp` all run. Splitting on `&&`, `||`, `;`, and `|` first means a dangerous command is still caught when it isn't the leading one (`cd foo && git push`), including behind an env-var prefix or `git -C <path>`.</q>. Assessment: anchored command parsing" and `skills/misc/git-guardrails-claude-code/SKILL.md:22`, "Fail closed describe sound guard behavior, supported by 39 passing harness tests.
- **Structure 5:** `skills/misc/git-guardrails-claude-code/SKILL.md:26`. Source line: <q>### 1. Ask scope</q>. Assessment: Ask the user which scope puts a material policy choice before installation.
- **Scope 2:** `skills/misc/git-guardrails-claude-code/SKILL.md:16`. Source line: <q>- `git checkout .` / `git restore .`</q>. Assessment: branch deletion and the other command families create broad git policy under a Claude Code-specific hook mechanism.
- **Verdict:** Anchored matching plus fail-closed parsing blocks dangerous variants rather than only exact strings. The broad command policy is tied to one host and can become stale as event schemas change. Keep it with versioned fixtures and a clear statement that it complements, not replaces, repository permissions.

### `code-review`, 4.60, keep

- **Trigger 5:** `skills/engineering/code-review/SKILL.md:3`. Source line: <q>description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."</q>. Assessment: review a branch, a PR, work-in-progress changes, or asks to review since X captures concrete review requests and baselines.
- **Actionability 5:** `skills/engineering/code-review/SKILL.md:17`. Source line: <q>### 1. Pin the fixed point</q>. Assessment: Resolve the fixed point begins a deterministic baseline, standards, spec, and synthesis flow.
- **Token economy 4:** `skills/engineering/code-review/SKILL.md:38`. Source line: <q>On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:</q>. Assessment: Fixed point precedence compresses baseline selection into a small decision table.
- **Correctness 4:** `skills/engineering/code-review/SKILL.md:72`. Source line: <q>If the spec is missing, skip the Spec sub-agent and note this in the final report.</q>. Assessment: If there is no originating spec, skip prevents fabricated compliance review, but mandatory parallel agents have no capacity fallback.
- **Structure 5:** `skills/engineering/code-review/SKILL.md:6`. Source line: <q>Two-axis review of the diff between `HEAD` and a fixed point the user supplies:</q>. Assessment: two axes" and `skills/engineering/code-review/SKILL.md:76`, "Keep the axes separate prevent standards findings from being confused with spec defects.
- **Scope 4:** `skills/engineering/code-review/SKILL.md:11`. Source line: <q>Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.</q>. Assessment: Runs both reviews in parallel sub-agents is a focused orchestration choice, though it couples correctness to agent availability.
- **Verdict:** A fixed baseline and separated review axes make findings attributable and reduce vague review commentary. With no sequential fallback, a full agent pool can block a read-only review. Keep it, adding a capacity-aware local or sequential execution path.

### `compose-multiplatform-ui`, 4.60, keep

- **Trigger 5:** `skills/house/mobile/compose-multiplatform-ui/SKILL.md:3`. Source line: <q>description: Use when building shared UI with Compose Multiplatform, deciding between a full-Compose iOS shell and a native SwiftUI shell (iOS 26 Liquid Glass), wiring per-platform entry points (MainActivity, MainViewController, ComposeUIViewController configure), using composeResources/Res, Navigation Compose or Navigation 3 or ViewModel in commonMain, embedding SwiftUI/UIKit in Compose (or vice versa), or debugging iOS-specific Compose issues (a startup crash naming CADisableMinimumFrameDurationOnPhone, frame rate caps, laggy or swallowed touches on native views, VoiceOver skipping interop views, viewModel() crashing on iOS).</q>. Assessment: named shells, entry points, resources, navigation, crashes, input, and VoiceOver issues provide excellent KMP UI routing.
- **Actionability 5:** `skills/house/mobile/compose-multiplatform-ui/SKILL.md:18`. Source line: <q>- **Full-Compose shell** (default): one `ComposeUIViewController` owns everything, tabs and back stack included. Simplest, most code shared, and what the KMP web wizard generates.</q>. Assessment: Choose the iOS shell first gives a decision table followed by platform checklists and debugging loops.
- **Token economy 3:** `skills/house/mobile/compose-multiplatform-ui/SKILL.md:70`. Source line: <q>- SwiftUI **in** Compose: pass a `() -> UIViewController` factory (wrapping `UIHostingController`) from Swift into Kotlin, render it with `UIKitViewController(factory = ...)`.</q>. Assessment: Native interop joins shell choice, resources, navigation, lifecycle, accessibility, and performance in a long main file.
- **Correctness 5:** `skills/house/mobile/compose-multiplatform-ui/SKILL.md:8`. Source line: <q>Shared Compose UI across Android and iOS. Written against **Compose Multiplatform 1.11.x** (Jetpack Compose 1.11.x, Kotlin 2.1+, iOS 14+). Full detail, version tables, and the worked Liquid Glass migration: [reference.md](reference.md).</q>. Assessment: Compose Multiplatform 1.11.1 and its iOS baseline align with current JetBrains release documentation.
- **Structure 5:** `skills/house/mobile/compose-multiplatform-ui/SKILL.md:82`. Source line: <q>## Iteration and verification loop</q>. Assessment: Debugging loop converts known iOS symptoms into observable checks.
- **Scope 4:** `skills/house/mobile/compose-multiplatform-ui/SKILL.md:12`. Source line: <q>Build wiring lives next door: the Gradle module and iOS framework block in `kmp-module-setup`, Xcode integration and the Swift-facing API in `kmp-ios-integration`, platform-capability boundaries in `kmp-boundaries`.</q>. Assessment: Use the sibling skills delegates module, integration, release, and test concerns, though the retained UI surface remains large.
- **Verdict:** Shell-first selection prevents incompatible lifecycle and rendering choices from leaking downstream. A large, time-sensitive UI handbook raises loading and drift cost, so a narrow resource question receives unrelated platform detail. Keep it, moving symptom families and version notes to routed references.

### `prototype`, 4.60, fix

- **Trigger 5:** `skills/engineering/prototype/SKILL.md:3`. Source line: <q>description: Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.</q>. Assessment: throwaway prototype" and "sanity-check clearly identify exploratory implementation.
- **Actionability 5:** `skills/engineering/prototype/SKILL.md:12`. Source line: <q>Identify which question is being answered, using the user's prompt, the surrounding code, or by asking if the user is around:</q>. Assessment: The question selects one of two detailed support files, giving the prototype an executable logic or UI path.
- **Token economy 4:** `skills/engineering/prototype/SKILL.md:21`. Source line: <q>1. **Throwaway from day one, and clearly marked as such.** Locate the prototype code close to where it will actually be used (next to the module or page it's prototyping for) so context is obvious, but name it so a casual reader can see it's a prototype, not production. For throwaway UI routes, obey whatever routing convention the project already uses; don't invent a new top-level structure.</q>. Assessment: Keep it disposable summarizes the main constraint while deeper guidance stays in support files.
- **Correctness 4:** `skills/engineering/prototype/SKILL.md:26`. Source line: <q>6. **Capture it when done.** Fold any validated decision into the real code, then capture the prototype itself as a **primary source**: commit it to a throwaway branch, out of main, and leave a context pointer to that branch on the implementation issue. Capture the answer too (the verdict and the question it settled) in the issue or a commit. The main branch keeps only the validated decision.</q>. Assessment: Preserving the experiment off main makes the evidence recoverable, but the unconditional commit and issue update can exceed the active repository authority.
- **Structure 5:** `skills/engineering/prototype/SKILL.md:8`. Source line: <q>A prototype is **throwaway code that answers a question**. The question decides the shape.</q>. Assessment: answer a design question gives the prototype a falsifiable purpose rather than treating it as early production code.
- **Scope 4:** `skills/engineering/prototype/SKILL.md:17`. Source line: <q>The two branches produce very different artifacts, so getting this wrong wastes the whole prototype. If the question is genuinely ambiguous and the user isn't reachable, default to whichever branch better matches the surrounding code (a backend module → logic; a page or component → UI) and state the assumption at the top of the prototype.</q>. Assessment: The branch choice is tightly bounded, though the default can still produce a costly artifact from an ambiguous request.
- **Verdict:** A named design question and discard rule prevent exploratory code from quietly becoming production. Capture is useful, but unconditional commit and issue updates cross repository-state boundaries. Fix by making capture medium follow active authority and repository policy.

### `to-spec`, 4.60, fix

- **Trigger 5:** `skills/engineering/to-spec/SKILL.md:3`. Source line: <q>description: "Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis of what you've already discussed."</q>. Assessment: Turn an already-understood feature into a written implementation spec clearly requires settled discovery.
- **Actionability 5:** `skills/engineering/to-spec/SKILL.md:13`. Source line: <q>1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.</q>. Assessment: Explore the codebase and the template give a concrete route from evidence to published spec.
- **Token economy 5:** `skills/engineering/to-spec/SKILL.md:15`. Source line: <q>2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.</q>. Assessment: A single compact seam rule replaces a large testing-design digression.
- **Correctness 3:** `skills/engineering/to-spec/SKILL.md:15`. Source line: <q>2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.</q>. Assessment: Preferring fewer high seams is useful, but "the ideal number is one" can collapse legitimately distinct behaviors into an oversized interface.
- **Structure 5:** `skills/engineering/to-spec/SKILL.md:17`. Source line: <q>Check with the user that these seams match their expectations.</q>. Assessment: This focused user gate prevents an unreviewed test architecture from being published.
- **Scope 4:** `skills/engineering/to-spec/SKILL.md:7`. Source line: <q>This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user; just synthesize what you already know.</q>. Assessment: does not run a fresh discovery interview cleanly separates it from discovery, but the output path remains repository-agnostic.
- **Verdict:** Codebase grounding plus seam review makes the specification testable and traceable. The no-interview promise still sits awkwardly beside a mandatory user seam check, and the one-seam ideal is overbroad. Clarify that the check confirms synthesized decisions rather than reopening discovery, and prefer the fewest coherent seams.

### `to-tickets`, 4.60, keep

- **Trigger 5:** `skills/engineering/to-tickets/SKILL.md:3`. Source line: <q>description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker (edges as text in one file per ticket locally, or native blocking links on a real tracker).</q>. Assessment: turn an approved plan/spec into implementation tickets clearly requires an upstream artifact and names the output.
- **Actionability 5:** `skills/engineering/to-tickets/SKILL.md:21`. Source line: <q>If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.</q>. Assessment: Explore the codebase leads through slicing, dependency mapping, user review, and publication.
- **Token economy 4:** `skills/engineering/to-tickets/SKILL.md:31`. Source line: <q>- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer</q>. Assessment: Every ticket must concentrates the acceptance contract into four rules.
- **Correctness 4:** `skills/engineering/to-tickets/SKILL.md:42`. Source line: <q>### 4. Quiz the user</q>. Assessment: Quiz the user correctly gates uncertain slicing, though tracker-specific publication commands are necessarily external.
- **Structure 5:** `skills/engineering/to-tickets/SKILL.md:58`. Source line: <q>### 5. Publish the tickets to the configured tracker</q>. Assessment: Publish only after approval creates an explicit external-write boundary.
- **Scope 4:** `skills/engineering/to-tickets/SKILL.md:65`. Source line: <q>Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.</q>. Assessment: Return the ready frontier connects the ticket graph to execution without implementing it.
- **Verdict:** Behavior slices, explicit dependencies, and approval-before-publication produce tickets an agent can actually execute. The generic tracker handoff can lose semantics if a provider lacks parents or blockers. Keep it, requiring a capability map and a lossless fallback representation.

### `use-git-worktree`, 4.60, keep

- **Trigger 5:** `skills/house/platform/use-git-worktree/SKILL.md:3`. Source line: <q>description: Create an isolated git worktree under `.worktrees/` before starting work, via `git worktree add` on a `feat/` or `fix/` branch. Use when beginning a feature, a bug fix, a refactor, a dependency upgrade, or an implementation plan that will touch more than one file, even when the user never says "worktree". Skip it for one-line and single-file edits, and stay in place when the user says to work on the current branch. Also use when unsure whether the session is already inside a worktree.</q>. Assessment: feature, bug fix, refactor, dependency upgrade plus multi-file scope gives clear isolation triggers.
- **Actionability 5:** `skills/house/platform/use-git-worktree/SKILL.md:20`. Source line: <q>**Lines 1 and 2 differing means you are in a linked worktree.** Stop, report the path and branch, and do not nest a second one. Equal means a plain checkout, so carry on. Line 3 is the branch, line 4 is the repo root.</q>. Assessment: Detect whether the session is already in a worktree begins a safe preflight before creation.
- **Token economy 4:** `skills/house/platform/use-git-worktree/SKILL.md:17`. Source line: <q>git rev-parse --path-format=absolute --git-dir --git-common-dir --abbrev-ref HEAD --show-toplevel</q>. Assessment: One command supplies every value needed for the isolation check, while the surrounding explanation documents several subtle Git edge cases.
- **Correctness 4:** `skills/house/platform/use-git-worktree/SKILL.md:28`. Source line: <q>`feat/<slug>` for a feature, `fix/<slug>` for a bug fix, kebab-case slug from the task: `feat/oauth-login`, `fix/crash-on-rotate`. Anything that is not a bug fix takes `feat/`, refactors and upgrades included. Two prefixes is a deliberate choice, so do not invent a third. The worktree path mirrors the branch, so `.worktrees/feat/oauth-login`.</q>. Assessment: The taxonomy is deterministic and accommodates prototypes under `feat/`; its main portability cost is imposing a house convention on repositories with their own branch policy.
- **Structure 5:** `skills/house/platform/use-git-worktree/SKILL.md:55`. Source line: <q>Name the base ref explicitly. Omit it and git branches from the main checkout's current `HEAD`, which this skill's whole premise says you left parked wherever the user had it, so the new branch quietly forks from last week's feature work. Use the default branch tip, `origin/main` or whatever this repo calls it, and fall back to the local default branch when there is no remote. Report whichever you used.</q>. Assessment: Choose the base deliberately makes branch origin an explicit decision.
- **Scope 4:** `skills/house/platform/use-git-worktree/SKILL.md:68`. Source line: <q>## Report</q>. Assessment: Report the worktree path ends after workspace isolation rather than absorbing implementation.
- **Verdict:** Existing-worktree detection and deliberate base selection prevent nested or misbased work. The closed prefix set can conflict with a target repository's own branch policy. Keep the mechanics and explicitly let documented repository conventions override the house prefix default.

### `wizard`, 4.60, keep

- **Trigger 5:** `skills/engineering/wizard/SKILL.md:3`. Source line: <q>description: Generate an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover. Don't invoke this for steps the agent can perform itself.</q>. Assessment: "steps only they can perform", credentials, dashboards, migrations, and cutovers precisely identify human-only workflows.
- **Actionability 5:** `skills/engineering/wizard/SKILL.md:18`. Source line: <q>Work out every manual step the human must take and every value that gets captured along the way. Read the repo first, don't ask cold:</q>. Assessment: Inspect the repository leads through confirmation, script generation, human execution, and static verification.
- **Token economy 3:** `skills/engineering/wizard/SKILL.md:10`. Source line: <q>The delightful UX is already solved by [template.sh](template.sh): stage-by-stage progress, confirmation gates, cross-platform URL opening (including WSL), hidden secret entry, idempotent `.env` upserts, `gh secret`/`gh variable` writes, and a closing summary. **Your job is only to scope the procedure and author its stages.** The library above the `STAGES` marker is identical in every wizard; that consistency is the point: never hand-edit it.</q>. Assessment: template and extensive Bash guidance add cost, though the generated artifact needs rigor.
- **Correctness 5:** `skills/engineering/wizard/SKILL.md:37`. Source line: <q>Hold the bar the template sets: open the URL before asking for its value, use `ask_secret` for anything secret, `write_env` every persisted value, `set_secret` only the values CI actually needs, and `confirm` before any irreversible action. Each `stage` clears the screen so only the current step is visible: keep a stage to one focused task so nothing the human needs scrolls away. Don't touch the library above the marker.</q>. Assessment: Pause before irreversible steps provides the essential destructive-action boundary.
- **Structure 5:** `skills/engineering/wizard/SKILL.md:23`. Source line: <q>Then show the user the ordered list of stages and the values each produces, and confirm: they may add, drop, or reorder.</q>. Assessment: Confirm the plan separates discovery from generating an executable assistant.
- **Scope 4:** `skills/engineering/wizard/SKILL.md:12`. Source line: <q>A wizard is ephemeral by default: built for one run, saved to a scratch or `scripts/` path, deleted when the job's done. Commit it only when the user wants a repeatable setup path that should live in the repo.</q>. Assessment: ephemeral prevents the one-off wizard from becoming unsupported product code, though migration and provisioning remain broad domains.
- **Verdict:** Human checkpoints and irreversible-step pauses make a generated wizard safer than a static checklist. A generic Bash template can still encode provider-specific assumptions that static checks miss. Keep it, requiring dry-run support where possible and explicit manual rollback text.

### `bro`, 4.70, keep

- **Trigger 5:** `skills/house/in-development/bro/SKILL.md:3`. Source line: <q>description: Restate the last message in plain human language, with no jargon.</q>. Assessment: The picker copy states both the source and transformation in one sentence.
- **Actionability 5:** `skills/house/in-development/bro/SKILL.md:9`. Source line: <q>Restate your last message. Stop using jargon and speak coherently. State it more simply and concisely, like one human talking to another.</q>. Assessment: The command directly changes diction, coherence, and length without adding another task.
- **Token economy 5:** `skills/house/in-development/bro/SKILL.md:9`. Source line: <q>Restate your last message. Stop using jargon and speak coherently. State it more simply and concisely, like one human talking to another.</q>. Assessment: Keep it short matches the skill's purpose with almost no loading cost.
- **Correctness 5:** `skills/house/in-development/bro/SKILL.md:9`. Source line: <q>Restate your last message. Stop using jargon and speak coherently. State it more simply and concisely, like one human talking to another.</q>. Assessment: Restating rather than changing the claim preserves the substance of the prior answer.
- **Structure 2:** `skills/house/in-development/bro/SKILL.md:9`. Source line: <q>Restate your last message. Stop using jargon and speak coherently. State it more simply and concisely, like one human talking to another.</q>. Assessment: One line is enough for the transformation, but it has no check that the second explanation landed.
- **Scope 5:** `skills/house/in-development/bro/SKILL.md:9`. Source line: <q>Restate your last message. Stop using jargon and speak coherently. State it more simply and concisely, like one human talking to another.</q>. Assessment: It touches only the immediately preceding message and adds no new analysis.
- **Verdict:** A one-line plain-language transformation is both cheap and reliably bounded. Without a comprehension check it can repeat the same conceptual gap with shorter words. Keep it and add a single invitation to identify what still does not land.

### `when-stuck`, 4.70, keep

- **Trigger 5:** `skills/house/platform/when-stuck/SKILL.md:3`. Source line: <q>description: Techniques for design and architecture stuck-ness. Use when a design keeps sprouting special cases, when every option feels forced, or when the same problem recurs in different places.</q>. Assessment: "special cases", "every option feels forced", and recurring problems give strong architectural stuckness signals.
- **Actionability 5:** `skills/house/platform/when-stuck/SKILL.md:22`. Source line: <q>**Reach for it when** you catch yourself saying it has to be done this way, or the design feels forced but you cannot say why.</q>. Assessment: Invert the burden supplies a concrete sequence for reframing the design.
- **Token economy 4:** `skills/house/platform/when-stuck/SKILL.md:12`. Source line: <q>| What is stuck | Use |</q>. Assessment: Symptom | Likely pressure turns recurring failure shapes into a compact diagnostic table.
- **Correctness 4:** `skills/house/platform/when-stuck/SKILL.md:54`. Source line: <q>**Reach for it when** every conventional option is inadequate and you need something you have not thought of yet.</q>. Assessment: collision rightly treats repeated exceptions as boundary evidence, though heuristics cannot prove a redesign is warranted.
- **Structure 5:** `skills/house/platform/when-stuck/SKILL.md:60`. Source line: <q>## Done when</q>. Assessment: Done when supplies observable exit criteria rather than endless ideation.
- **Scope 5:** `skills/house/platform/when-stuck/SKILL.md:10`. Source line: <q>**This is for design and architecture stuck-ness only.** Two neighbours own the other kinds, and reaching for this one instead wastes the session:</q>. Assessment: Pick the smallest technique keeps the skill diagnostic and avoids absorbing full architecture work.
- **Verdict:** Mapping symptoms to pressures and choosing one small technique gives stuck teams a falsifiable next move. Heuristics can overinterpret local mess as architectural failure if evidence is thin. Keep it, with a reminder to validate the suspected pressure against one concrete case.

### `kmp-boundaries`, 4.75, keep

- **Trigger 5:** `skills/house/mobile/kmp-boundaries/SKILL.md:3`. Source line: <q>description: Use when common code needs to reach a platform API and you are picking the boundary shape, whether a common interface with per-platform bindings, expect/actual, or separate platform implementations. Covers capability granularity, keeping actuals thin, the Activity-owned platform-UI binding, declaring a custom intermediate source set to share code across a target subset (such as Android + Desktop JVM), and the AGP-9 constraints that shape what can live in shared code.</q>. Assessment: common code needs to reach a platform API plus named boundary shapes and AGP 9 gives exact routing language.
- **Actionability 5:** `skills/house/mobile/kmp-boundaries/SKILL.md:10`. Source line: <q>- **Keep `commonMain` semantic**: describe *what* the product needs, not Android/iOS mechanics: `currentRegion()`, never `currentRegionFromAndroidLocale(context)`.</q>. Assessment: The positive rule and counterexample make the first boundary decision immediately usable.
- **Token economy 4:** `skills/house/mobile/kmp-boundaries/SKILL.md:20`. Source line: <q>**Related:** [`kmp-ktor`](../kmp-ktor/SKILL.md) (network boundary), [`compose-multiplatform-ui`](../compose-multiplatform-ui/SKILL.md) (Compose-MP mechanics and SwiftUI/UIKit interop). For the iOS↔Swift bridge, meaning `@Throws`, sealed-class exhaustiveness, SKIE, and the rest of the Swift-facing API review, see the "Swift-facing API review checklist" in [`kmp-ios-integration`](../kmp-ios-integration/SKILL.md) when authoring the iOS-side implementation.</q>. Assessment: Related platform concerns are routed to sibling skills rather than duplicated, while the main file still retains substantial examples.
- **Correctness 5:** `skills/house/mobile/kmp-boundaries/SKILL.md:98`. Source line: <q>## AGP-9 KMP-library constraints (structural, since they shape what can live in shared code)</q>. Assessment: AGP 9 constraints and `skills/house/mobile/kmp-boundaries/SKILL.md:100`, current source-set facts align with JetBrains migration guidance.
- **Structure 5:** `skills/house/mobile/kmp-boundaries/SKILL.md:83`. Source line: <q>⚠️ **This section is our own convention, not JetBrains guidance.** The rules above are sourced from the official docs; the table below is accumulated team judgment. Treat it as a starting position to argue with, not an authority, since JetBrains publish no domain-category guidance of this kind either way.</q>. Assessment: Convention or requirement? explicitly labels preference versus tool constraint.
- **Scope 4:** `skills/house/mobile/kmp-boundaries/SKILL.md:24`. Source line: <q>The single most common Android boundary mistake: passing `applicationContext` / `LocalContext.current` into a binding that actually needs an `Activity`, then papering over the lifecycle gap with `Intent.FLAG_ACTIVITY_NEW_TASK`. That flag is a smell, because it hides that this is a foreground-UI operation. Hold an `Activity` instead.</q>. Assessment: Do not pass an Activity gives a focused platform-UI boundary, though source-set configuration slightly broadens the seam-design task.
- **Verdict:** Narrow-capability ordering and convention labeling prevent platform leakage from masquerading as a Kotlin requirement. Embedded AGP-era facts will age and can invalidate a correct design recipe. Keep it, date the compatibility section and verify it on each Kotlin or AGP release.

### `writing-beats`, 4.75, keep

- **Trigger 5:** `skills/in-progress/writing-beats/SKILL.md:3`. Source line: <q>description: Writing, exploit; assemble raw material into a journey of beats, grounding each term before a beat leans on it.</q>. Assessment: Turn raw writing fragments into stronger prose beats describes transformation but overlaps `writing-shape` and `unslop` without a boundary cue.
- **Actionability 5:** `skills/in-progress/writing-beats/SKILL.md:15`. Source line: <q>1. **Establish the prerequisites.** Before any beats, settle with the user what the audience already knows walking in: the concepts that are **grounded** from the start. Everything else must be grounded by a beat before a later beat can use it. See [Grounding](#grounding).</q>. Assessment: This creates a checkable constraint for every later candidate beat.
- **Token economy 4:** `skills/in-progress/writing-beats/SKILL.md:27`. Source line: <q>Every **concept** has to be **grounded** before a beat can lean on it: the audience either walked in knowing it or met it in an earlier beat. A beat that reaches for an ungrounded concept loses the reader; that is the one move the journey can't make. The unit is the concept, not the word for it: a beat can lean on an idea the reader lacks even with no jargon in sight. Where a concept has a name (a **term**), grounding it means landing the idea and the term together.</q>. Assessment: Ground every change concentrates the key editorial constraint, although examples repeat advice found in sibling writing skills.
- **Correctness 5:** `skills/in-progress/writing-beats/SKILL.md:62`. Source line: <q>- Append one beat at a time. Never write ahead.</q>. Assessment: Incremental writes preserve the user's choice of direction instead of silently drafting past it.
- **Structure 5:** `skills/in-progress/writing-beats/SKILL.md:19`. Source line: <q>5. Loop steps 3–5 until the article reaches a natural end.</q>. Assessment: The candidate, choose, write, reread loop gives the workflow a coherent repeated structure.
- **Scope 4:** `skills/in-progress/writing-beats/SKILL.md:9`. Source line: <q>The user has passed (or will pass) a markdown file of raw material. This is **exploit**: the exploring is done, the pile is fixed. Commit to a path through it and mine the pile to fill each beat.</q>. Assessment: Use this skill after `writing-fragments` occupies nearly the same post-draft space as `writing-shape`, so routing depends on subtle wording.
- **Verdict:** Reachable-beat selection turns article sequence into explicit user choices. It shares grounding and file mechanics with `writing-shape`, but its unit and branching interaction are genuinely different. Keep both, sharpen the picker boundary to journey-by-beat versus thesis-by-paragraph, and deduplicate shared reference prose.

### `writing-shape`, 4.75, keep

- **Trigger 5:** `skills/in-progress/writing-shape/SKILL.md:3`. Source line: <q>description: "Writing, exploit: shape raw material into an article, paragraph by paragraph."</q>. Assessment: Shape rough writing into a coherent draft is understandable but does not sharply exclude `writing-beats` or `unslop`.
- **Actionability 5:** `skills/in-progress/writing-shape/SKILL.md:21`. Source line: <q>1. **Read the pile.** Read the input file in full. Form a sense of what's in it.</q>. Assessment: The first step grounds later candidate openings in the complete source rather than a partial excerpt.
- **Token economy 4:** `skills/in-progress/writing-shape/SKILL.md:30`. Source line: <q>Every **concept** has to be **grounded** before a block can lean on it: the reader either walked in knowing it or met it in an earlier block. A block that reaches for an ungrounded concept loses the reader. The unit is the concept, not the word for it: a block can lean on an idea the reader lacks even with no jargon in sight. Where a concept has a name (a **term**), grounding it means landing the idea and the term together.</q>. Assessment: Ground every structural choice states the central constraint compactly, though some rhythm guidance duplicates its sibling.
- **Correctness 5:** `skills/in-progress/writing-shape/SKILL.md:71`. Source line: <q>Append to the article file as each block is agreed. Re-read the file from disk before every write: the user may have edited between turns. Never overwrite blindly. If the user wants a paragraph rewritten, edit that specific paragraph in place; leave the rest alone.</q>. Assessment: Rereading before each narrow edit preserves concurrent user changes and limits overwrite risk.
- **Structure 5:** `skills/in-progress/writing-shape/SKILL.md:9`. Source line: <q>The user has passed (or will pass) a markdown file of raw material. Treat it as the input pile: anything from a tidy list of fragments to a wall of unstructured prose to a transcript. The format does not matter. Read it end-to-end before doing anything else.</q>. Assessment: Read the whole source starts a coherent diagnose, outline, and reshape procedure.
- **Scope 4:** `skills/in-progress/writing-shape/SKILL.md:13`. Source line: <q>If the user did not say where to save the article, ask once and remember the path.</q>. Assessment: The output is one remembered article path, though that path is not validated against repository placement rules.
- **Verdict:** Candidate openings and paragraph-by-paragraph growth keep the article's thesis under user control. Shared grounding prose with `writing-beats` raises maintenance cost, but the workflows are not duplicates. Keep it, cross-link the sibling choice, and move common grounding rules to one shared reference.

### `to-questionnaire`, 4.85, keep

- **Trigger 5:** `skills/productivity/to-questionnaire/SKILL.md:3`. Source line: <q>description: Turn a decision you can't fully answer into a questionnaire for someone else to fill in.</q>. Assessment: turn a plan, decision, or idea into a structured questionnaire names the input and deliverable exactly.
- **Actionability 5:** `skills/productivity/to-questionnaire/SKILL.md:12`. Source line: <q>1. **Who is it going to?** Ask, in one exchange, the recipient's role, expertise, and relationship to the user. This fixes the questionnaire's tone and how much context it must carry. Done when you know who the recipient is and what they know that the user doesn't.</q>. Assessment: Ask only questions leads through uncertainty selection, one-at-a-time questioning, recording, and output.
- **Token economy 5:** `skills/productivity/to-questionnaire/SKILL.md:20`. Source line: <q>Frame the document as a **discovery questionnaire**: the user lacks context, the recipient holds it. Order questions most-important-first, since async means you may only get one pass, and group them under `##` headings by theme once there are more than a handful. Write it using the template below.</q>. Assessment: Order questions by leverage concentrates prioritization into a compact rule.
- **Correctness 4:** `skills/productivity/to-questionnaire/SKILL.md:14`. Source line: <q>2. **What do you need back?** Ask, in one exchange, the specific decisions or facts the user can't resolve alone and needs from this person. Done when you have a concrete list of what the user must walk away able to do or decide.</q>. Assessment: Outcome-first scoping keeps the questionnaire relevant, but there is no check that the named recipient actually holds the needed knowledge.
- **Structure 5:** `skills/productivity/to-questionnaire/SKILL.md:24`. Source line: <q># <Questionnaire title></q>. Assessment: Output template gives a stable handoff artifact.
- **Scope 5:** `skills/productivity/to-questionnaire/SKILL.md:16`. Source line: <q>3. **Write the questionnaire.** Draft questions aimed at the gap from steps 1–2, following the Document structure below. Write it to `to-questionnaire-<slug>.md` in the current directory (slug from the topic) and report the path. Done when the file exists and every item the user named in step 2 is covered by a question.</q>. Assessment: When uncertainty is resolved, write supplies a narrow and observable endpoint.
- **Verdict:** Leverage ordering minimizes user effort while preserving the decisions that matter. An unanswerable first question can stall the whole sequence because deferral is undefined. Keep it, adding defer, evidence-gather, and unresolved-output states.

### `grilling`, 4.90, keep

- **Trigger 5:** `skills/productivity/grilling/SKILL.md:3`. Source line: <q>description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.</q>. Assessment: "stress-test", "grill", and named trigger phrases provide unusually clear invocation cues.
- **Actionability 5:** `skills/productivity/grilling/SKILL.md:10`. Source line: <q>Format a round like so:</q>. Assessment: Ask one decision-bearing question creates a repeatable evidence and challenge loop.
- **Token economy 5:** `skills/productivity/grilling/SKILL.md:8`. Source line: <q>Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.</q>. Assessment: Work in rounds expresses the control model with minimal prose.
- **Correctness 5:** `skills/productivity/grilling/SKILL.md:26`. Source line: <q>Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.</q>. Assessment: Separate facts from decisions prevents preferences from being laundered into evidence.
- **Structure 4:** `skills/productivity/grilling/SKILL.md:24`. Source line: <q>Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.</q>. Assessment: recompute the frontier maintains state well, though there is no explicit timeout or fatigue escape.
- **Scope 5:** `skills/productivity/grilling/SKILL.md:28`. Source line: <q>The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.</q>. Assessment: Stop when supplies clear terminal conditions and leaves artifact production to other skills.
- **Verdict:** One decision-bearing question per round plus a recomputed frontier exposes assumptions without losing conversational state. The only material gap is user fatigue or unavailable evidence, which can leave the loop technically open. Keep it and add an explicit pause-with-ledger outcome.

### `handoff`, 4.90, keep

- **Trigger 5:** `skills/productivity/handoff/SKILL.md:3`. Source line: <q>description: Compact the current conversation into a handoff document for another agent to pick up.</q>. Assessment: Hand off the current task to another agent is clear but does not mention resumability, which is its real differentiator.
- **Actionability 5:** `skills/productivity/handoff/SKILL.md:8`. Source line: <q>Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.</q>. Assessment: Save the handoff as a markdown file in a temporary directory gives an artifact but not a collision-safe naming or cleanup rule.
- **Token economy 5:** `skills/productivity/handoff/SKILL.md:10`. Source line: <q>Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.</q>. Assessment: The required additions fit in six short body lines and avoid copying full referenced artifacts.
- **Correctness 5:** `skills/productivity/handoff/SKILL.md:14`. Source line: <q>Redact any sensitive information, such as API keys, passwords, or personally identifiable information.</q>. Assessment: Redact secrets supplies the critical safety boundary, though it does not define how to detect sensitive material.
- **Structure 4:** `skills/productivity/handoff/SKILL.md:16`. Source line: <q>If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.</q>. Assessment: If the user supplied arguments adds one branch, while validation, acknowledgement, and failed transfer are missing.
- **Scope 5:** `skills/productivity/handoff/SKILL.md:12`. Source line: <q>Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.</q>. Assessment: Use progressive disclosure keeps the packet focused, but the unspecified receiving agent leaves the transport boundary fuzzy.
- **Verdict:** A redacted, pointer-rich packet reduces restart cost for the next agent. This skill only writes the packet, so recipient acknowledgement belongs to a transport adapter, but collision-safe naming and cleanup are still missing. Keep it and add those two file-lifecycle rules.

## Phase 2: portfolio analysis

### Overlap and duplication map

| Cluster | Overlap evidence | Why both might exist | Failure scenario | Decision |
|---|---|---|---|---|
| `implement`, `cook`, `implement-spec` | All accept an implementation request; `implement` is a nine-line chain, `cook` owns the full delivery pipeline, and `implement-spec` adds parallel worktrees and a merger. | Lightweight, full-pipeline, and parallel modes are legitimate. | "Implement this spec" can select any of three skills, producing anything from an immediate commit to a draft PR and several worktrees. | Make `cook` the router. Retain lightweight and parallel as named modes, then retire the two wrappers. |
| `grilling`, `grill-me`, `grill-with-docs`, `loop-me` | Three wrappers invoke `grilling`; two add a fixed downstream artifact and one repeats rounds. | Stress-test, questionnaire production, domain modeling, and repeated critique are different outcomes. | A plan critique can trigger both `grilling` and `loop-me`, then accidentally flow into a questionnaire or spec before uncertainty closes. | Keep `grilling` as engine. Give each wrapper a deliverable-specific trigger, input contract, gate, and no-output stop state. |
| `writing-fragments`, `writing-shape`, `writing-beats`, `unslop` | They form a plausible sequence. Shape and beats share exploit, grounding, and file-safety prose, but one grows a thesis paragraph by paragraph while the other lets the user choose a journey beat by beat. | Capture, thesis structure, narrative route, and voice are useful stages. | Picker copy does not make the shape-versus-beats choice vivid, so a user can enter the wrong interaction model. | Keep all four, cross-link the choice, and move shared grounding and file-safety prose to one reference. |
| `handoff`, `claude-handoff` | Both assemble current context for another agent; one writes a packet and the other launches a host-specific process. | Content and transport are distinct concerns. | The host-specific command is unavailable, so no packet is retained and no recipient acknowledges the transfer. | Keep `handoff` as the transport-neutral packet contract. Move Claude launch into a separately detectable adapter. |
| `tdd`, `do-test` | Both select seams and run tests; TDD creates behavior in slices, while do-test verifies an existing change. | Construction and independent verification are valid separate phases. | "Test this fix" invokes TDD and starts changing production code instead of only verifying it. | State the boundary in both descriptions: TDD builds test-first; do-test observes and returns a verdict. |
| `project-organization`, `to-prd` | Both prescribe output filenames and directories. | One owns repository placement and one owns PRD content. | One skill creates `PRD-foo.md`; the other requires lowercase filenames, making order determine compliance. | Make project-organization the sole naming resolver; artifact skills request a logical artifact type, not a fixed filename. |
| `bro`, `wait-what` | Both repitch the immediately preceding answer in simpler language. `wait-what` adds ASD-STE100 and repository vocabulary; `bro` asks only for concise human speech. | A fast no-jargon alias and a domain-language corrective are distinct response modes. | With no cross-link, a user cannot tell whether the glossary-aware version will help or add more terminology. | Keep both; state plain human restatement versus controlled technical repitch in their picker copy. |
| `kmp-module-setup`, `kmp-boundaries` | Both advise interface versus expect/actual and source-set placement. | Setup needs a short routing summary; boundary design needs the full decision model. | The duplicated tables drift across Kotlin or AGP releases and agents choose different seams. | Keep one sentence and link in module setup; retain all decision detail in boundaries. |
| `research`, absent `codebase-retrieval` | Research delegates evidence work, while two skills refer to a retrieval skill that is not present. | Repository research and external research benefit from a shared evidence contract. | Show-me or do-test routes to a nonexistent skill before it can inspect real code. | Define a capability-neutral repository-search rule, or add a real retrieval skill and register it everywhere. |
| `ask-matt`, all user-reachable skills | `ask-matt` is the portfolio router, but its mobile section lists five of seven KMP skills. | A human-scale map is valuable even when the catalog is authoritative. | The router sends Ktor or platform-boundary questions to generic module setup. | Generate coverage checks from the catalog and retain curated ordering by hand. |

### Trigger simulation: ten realistic requests

This is a paper simulation against the descriptions and invocation policy, not a measured model run. It exposes which descriptions are candidates for a future trigger eval set.

| User request | Likely activation | Collision or miss | Desired route |
|---|---|---|---|
| "Implement the approved checkout spec and get it ready to merge." | `implement`, `cook`, `implement-spec` | Three implementation orchestrators differ radically in side effects. | `cook`, standard mode; parallel mode only if the user asks for it or the plan warrants it. |
| "Debug why scrolling freezes after returning from a native iOS view." | `diagnosing-bugs`, `compose-multiplatform-ui` | Healthy composition, but diagnosis currently continues into a fix. | Diagnose with Compose reference; stop before mutation unless asked to fix. |
| "Where should this camera permission API cross into commonMain?" | `kmp-boundaries`, possibly `kmp-module-setup` | Setup's seam table competes with the deeper specialist. | `kmp-boundaries` only, with module setup as background if configuration changes follow. |
| "I have a product idea but no requirements yet. Turn it into something engineering can review." | `to-prd`, possibly `grill-with-docs` | PRD can begin with gaps, but domain workflow may over-escalate. | `to-prd`; route to grilling only when material decisions are unresolved. |
| "This paragraph sounds like AI. Keep my voice but make it tighter." | `unslop`, `writing-beats`, `writing-shape` | Three editing skills touch cadence and sentence shape. | `unslop`; call structural shaping only if the argument itself is disordered. |
| "What should I work on next? The backlog is a mess." | `wayfinder`, `triage` | Both inspect issue state, but only one repairs classifications. | `triage` first when labels are invalid, then `wayfinder` to choose one ready item. |
| "Make a quick clickable version so we can decide between these navigation ideas." | `prototype`, `show-me`, `compose-multiplatform-ui` | Visualization and production UI references can crowd a throwaway experiment. | `prototype` UI branch, consulting Compose UI only if the target is actually Compose. |
| "Explain this architecture again. I still do not see why we need three adapters." | `wait-what`, `show-me`, `codebase-design` | All three legitimately match different parts of the request. | `show-me` with codebase-design vocabulary; use wait-what's adaptation loop if the first picture fails. |
| "Move our half-written work to another agent without losing context." | `handoff`, `claude-handoff` | Content contract and host-specific transport are indistinguishable at trigger level. | `handoff`; invoke a transport adapter only when the user names it and it is available. |
| "Set up Ktor auth refresh and prove retries do not hang forever." | `kmp-ktor`, `kmp-test-seams`, `do-test` | Good specialist composition, but Ktor's description falsely promises engine setup too. | Ktor configuration, test-seam choice, then an evidence verdict. |

### Capability gaps

1. **No executable behavior assurance.** Symptom: all structural suites pass while broken skill names and contradictory instructions survive. Reason: the checks validate schema, links known to their own rules, metadata, and lexical similarity, not whether an agent follows a skill successfully. Failure: a release stays green while `cook` routes to `simplify`, which does not exist.
2. **No retained trigger corpus.** Symptom: the only collision check is a Jaccard threshold of 0.80, and the observed maximum is 0.185. Reason: lexical overlap is a weak proxy for semantic routing, and 26 user-invoked skills are excluded. Failure: `implement`, `cook`, and `implement-spec` all match the same user intent without tripping CI.
3. **No capability/reference registry.** Symptom: cross-skill names are free-form prose. Reason: references are not resolved against the catalog. Failure: renaming or deleting a skill leaves executable-looking dead routes in wrappers and references.
4. **No mutation contract.** Symptom: `commit`, `stash`, `revert`, branch creation, PR creation, and tracker writes appear inside skills without a common authorization vocabulary. Reason: each author improvised its own completion semantics. Failure: a diagnostic or verification request changes user state.
5. **No external-fact freshness contract.** Symptom: KMP versions, AGP constraints, store rules, and CLI syntax live in skill bodies without reviewed dates. Reason: correctness has no owner or expiry signal. Failure: a technically polished checklist becomes wrong after a platform release.
6. **No incident-to-regression loop.** Symptom: observed routing failures and human corrections have no standard capture shape. Reason: feedback can become prose or disappear from a session instead of entering Beads and a future eval. Failure: the same bad trigger or unsafe step recurs across sessions.
7. **No transport abstraction for handoff or delegation.** Symptom: host commands are embedded in content-oriented skills. Reason: packet construction, process launch, and agent-capacity management are not separate capabilities. Failure: the workflow is unusable when `claude`, Herdr, or a free subagent slot is absent.

### Portfolio conventions

What is standardized well:

- Every one of the 58 skills has parseable frontmatter and `agents/openai.yaml`. The mechanism works because metadata and invocation configuration are present everywhere, which lets the harness inspect the whole collection uniformly.
- Invocation is deliberately binary: 26 skills are human-only and 32 are model-reachable. The mechanism prevents a concise picker description from being judged as if it were model routing prose.
- Fork provenance is explicit in `.fork/catalog.yaml`, `.fork/sanctioned-edits.txt`, and bucket placement. This prevents local capability work from contaminating upstream territory during sync.
- High-scoring skills state a defining constraint early: `prototype` answers a question, `kmp-boundaries` chooses the narrowest capability, and `grilling` asks one decision-bearing question. The mechanism gives the agent a small invariant to steer by.
- The strongest workflows have observable gates: `do-test` returns an evidence verdict, `to-tickets` publishes only after approval, and `grilling` stops on explicit conditions. This makes completion falsifiable.

What is not standardized:

- Cross-skill calls use slash commands, bare names, prose names, and missing capability labels. Without one resolver, a rename produces silent dead branches.
- Permissions are local prose rather than a shared state model. The symptom is unconditional `commit`, `revert`, or `launch`; the likely failure is work performed outside the user's requested authority.
- Branch and filename conventions have multiple owners. The symptom is direct contradiction; the likely failure is output that is compliant with one skill and invalid under another.
- Progressive disclosure is uneven. Some large skills use excellent references, while other long skills embed every path. The likely failure is unnecessary context cost and slower steering on narrow requests.
- Correctness evidence is not attached to volatile claims. The likely failure is silent staleness because a passing structural suite cannot distinguish a current platform fact from an obsolete one.

## Phase 3: prioritized improvement plan

Priority reflects failure severity, not score alone. P0 items can break execution, violate authority, or make the router factually wrong. P1 items cause repeated ambiguity or maintenance drag. P2 items improve efficiency after safety and routing are stable.

### P0: fix before the next release

1. **Remove unresolved capability names.** These edits are fork-owned and can be made without entering vendor territory.

   - `skills/house/delivery/cook/SKILL.md:68`
     - Old: `| UI work | House design skills: compose-multiplatform-ui, html-design-to-compose | If Compose UI work |`
     - New: `| UI work | compose-multiplatform-ui | If Compose UI work |`
   - `skills/house/delivery/cook/SKILL.md:69`
     - Old: `| Simplify | simplify skill | When the diff breaches thresholds |`
     - New: `| Simplify | Main loop: simplify only the touched diff, then run the repository formatter and linter | When the diff breaches thresholds |`
   - `skills/house/delivery/cook/SKILL.md:87`
     - Old: ``Runs internally: project-organization, do-test, code-review, simplify``
     - New: ``Runs internally: project-organization, do-test, code-review``
   - `skills/house/in-development/show-me/SKILL.md:14`
     - Old: `look it up before drawing (codebase-retrieval, then read the lines that matter)`
     - New: `search it with the repository's available code-search tools, then read the lines that matter before drawing`
   - `skills/house/quality/do-test/references/test-matrix.md:33`
     - Old: `every caller of each changed symbol (codebase-retrieval, then grep the symbol)`
     - New: `every caller of each changed symbol, found with the repository's available code-search tool (prefer rg when present)`

2. **Repair the authoritative router.** This upstream path is already sanctioned for fork edits.

   - `skills/engineering/ask-matt/SKILL.md:71`
     - Old: `Five model-invoked references ...: /kmp-module-setup, /kmp-ios-integration, /compose-multiplatform-ui, /kmp-test-seams, /kmp-release-and-publish.`
     - New: `Seven model-invoked references ...: /kmp-module-setup, /kmp-boundaries, /kmp-ktor, /kmp-ios-integration, /compose-multiplatform-ui, /kmp-test-seams, /kmp-release-and-publish.`
   - Update `skills/engineering/ask-matt/references/platform-knowledge.md` in the same change so both new routes state their boundary. Add a catalog-to-router coverage check that fails if a user-reachable skill has no route or explicit exemption.

3. **Stop diagnosis before mutation unless remediation is authorized.** `diagnosing-bugs` is upstream territory and is not currently sanctioned. Send this fix upstream or add the path and rationale to the fork's sanctioned-edit machinery before changing it locally.

   - `skills/engineering/diagnosing-bugs/SKILL.md:114`
     - Old heading: `## Phase 5: Fix + regression test`
     - New heading: `## Phase 5: Remediation gate`
     - Insert immediately below: `If the user asked only for diagnosis, stop here with the cause, evidence, minimized reproduction, and proposed regression seam. Continue into the steps below only when the user asked for a fix or separately authorizes remediation.`

4. **Restore the method promised by TDD.** `tdd` is unsanctioned upstream territory, so use the same upstream-or-sanction path.

   - `skills/engineering/tdd/SKILL.md:38`
     - Old: `Refactoring is not part of the loop. It belongs to the review stage ...`
     - New: `Refactor after green when a small behavior-preserving cleanup improves the seam or removes duplication. Keep larger architectural changes for code-review, then begin the next cycle with a new failing test.`

5. **Retire the unsupported `improve-claude-md` mechanism.** Delete the internal beta skill, its catalog entry, and its marketplace group entry through the generator. Preserve only the evidence-neutral rule in `writing-for-agents`: conditional guidance should name the condition under which it applies. Do not retain claims that XML has privileged adherence behavior until a live-fire comparison proves them.

### P1: resolve recurring routing and ownership ambiguity

1. Make `cook` the sole end-to-end implementation router. Represent lightweight, standard, and parallel delivery as modes. Deprecate `implement` and `implement-spec` only through the upstream sync process, since both are vendor-owned.
2. Keep `writing-beats` and `writing-shape` as separate interaction modes, cross-link their picker descriptions, and extract duplicated grounding and file-safety rules into one shared reference. Add paired selection tests that differ by desired unit: narrative beat versus paragraph block.
3. Make `handoff` own the packet schema and acknowledgement. Keep host launchers outside it, detected by capability and invoked only when the user names the transport.
4. Make `project-organization` the only naming resolver. Replace hardcoded filenames in artifact skills with logical artifact types and repository-policy lookup.
5. Move KMP version matrices and fast-moving store facts into dated references with `verified_on`, `source`, and `review_after` fields. Keep stable decision rules in the main skill.
6. Add a shared mutation vocabulary to the authoring standard: `read`, `workspace-write`, `repository-state`, `external-state`, and `destructive`. Every step above workspace-write needs an explicit user or repository authority gate.
7. Add sequential fallbacks to subagent-dependent skills, especially `research` and `code-review`, so capacity affects latency rather than correctness.
8. Rework wrapper skills around Trigger, Structure, Steering: a distinct deliverable in the description, an input and output contract in the body, and one authoritative engine beneath it.

### P2: reduce cost and improve maintainability

1. Move command encyclopedias and alternate platform paths from `herdr`, `compose-multiplatform-ui`, `kmp-ios-integration`, and `kmp-release-and-publish` into routed references.
2. Add lightweight modes to `teach`, `ddd`, and `setup-ts-deep-modules`; load persistent state or full artifact suites only after the request needs them.
3. Add deferral states to `grilling` and `to-questionnaire` for fatigue and unavailable evidence.
4. Add discovery commands before exact task names in `kmp-test-seams` and before project layouts in setup skills.
5. Replace universal wording such as "exactly one interface" with testable preference plus exception criteria.
6. Add a transport-neutral receipt and cleanup contract to `handoff`.

### Do not touch

- Do not edit vendor-owned files outside `.fork/sanctioned-edits.txt`. A low score is not permission to fork upstream bytes. Submit upstream changes or sanction them with a recorded divergence rationale.
- Do not hand-edit `.claude-plugin/marketplace.json`; regenerate it after catalog changes.
- Do not collapse the user-invoked versus model-invoked distinction. Human picker copy and model routing descriptions serve different mechanisms.
- Do not rewrite `grilling`, `to-questionnaire`, `kmp-boundaries`, or `when-stuck` wholesale. Their leading invariants and stop conditions are portfolio exemplars.
- Do not weaken `git-guardrails-claude-code` parsing without extending its passing fixture suite. Its behavior is one of the few mechanically exercised skill effects.
- Do not create a second hand-maintained catalog. Any index or route coverage view must be generated from `.fork/catalog.yaml` plus small curated annotations.

## Phase 4: continuous skill-upgrade system

### 1. Live-fire testing protocol

Use four gates, cheapest first. A skill version cannot advance if an earlier gate fails.

| Gate | What runs | Minimum evidence | Failure means |
|---|---|---|---|
| Static | Existing `skillcheck`, `forkcheck`, guardrail suites, frontmatter parsing, local link resolution, and no-em-dash scan | One clean CI run | Packaging or repository contract is broken. Do not run model evals. |
| Trigger | A retained corpus of realistic should-trigger, should-not-trigger, and sibling-confusion prompts | Model-reachable skills: at least 10 positive, 10 negative, and 5 sibling pairs, each run three times. User-only skills: picker-choice tests against two nearest siblings. | Description or invocation policy routes unreliably. Change only the trigger layer first. |
| Steering | Run the skill on representative fixtures, with and without the candidate version | At least 5 tasks: ordinary, edge, missing prerequisite, denied mutation, and recovery. Grade required actions, prohibited actions, output contract, token use, and latency. | Body instructions do not cause the intended behavior. Change structure or steering, not just description wording. |
| Adversarial | Apply stale docs, missing tools, dirty worktree, conflicting repository policy, prompt injection in source material, and full agent capacity | Every safety assertion passes; no unauthorized external or destructive action | The skill is unsafe under realistic environmental pressure. Block release. |

Protocol details:

1. Snapshot the current skill as the baseline and give candidate and baseline the same fixture and model configuration.
2. Blind the grader to version identity. For subjective output, use paired human review; for commands, files, and citations, prefer mechanical assertions.
3. Run each nondeterministic case three times. Treat one severe unauthorized action as a release blocker, not an averageable miss.
4. Record pass rate, severe failures, median input and output tokens, median elapsed time, and human preference. A candidate wins only if it introduces no severe regression and either improves its target metric by 10 percentage points or wins at least 60 percent of paired human judgments.
5. Keep 20 percent of trigger and steering cases held out. Promote based on held-out results, not the prompts used to tune the skill.
6. Convert every production incident into a minimal regression case before editing the skill. This connects the observed symptom to a test that would have failed before the repair.

Recommended fixture layout, as a proposal rather than a task tracker:

```text
evals/
  portfolio/
    trigger-corpus.jsonl
    collision-pairs.jsonl
  skills/<skill-name>/
    cases.jsonl
    fixtures/
    assertions.yaml
    baselines/<version>.json
  incidents/
    regressions.jsonl
```

### 2. Feedback capture

Beads remains the only task system. Capture a failure with:

```text
Title: [skill-feedback] <skill>: <observable symptom>
Type: bug
Priority: P0, P1, or P2 by user impact
Body:
  Request: exact user wording, redacted
  Expected route and behavior:
  Actual route and behavior:
  Environment and available capabilities:
  Authority level granted:
  Evidence: transcript pointer, files, commands, or screenshots
  Suspected layer: Trigger | Structure | Steering | External fact
  Nearest sibling involved:
  Regression case added: path or pending reason
```

Triage rules:

- P0: unauthorized destructive or external action, secret exposure, dead capability route in a release path, or a router that sends work to the wrong safety boundary.
- P1: repeatable trigger collision, missing recovery branch, stale volatile fact, or output that violates its declared contract.
- P2: token waste, weak examples, unclear copy, or a low-frequency ergonomics issue.
- Close the bead only when the minimal regression fails on the old version, passes on the candidate, and the portfolio collision suite remains green.

### 3. Versioning and review cadence

- Add `version: 1.0.0` to each `SKILL.md` frontmatter in one catalog-wide baseline change. Thereafter, a substantive edit must bump that skill's version. Patch means clearer steering with the same trigger and output contract. Minor means a trigger, output, permission, or workflow contract changes compatibly. Major means rename, removal through deprecation, or incompatible invocation behavior. Typos and link repairs that do not change behavior need no bump.
- Use Changesets for user-visible repository releases, separately from the per-skill version. A CI diff check should fail when `SKILL.md` behavior changes without a version bump, and should reject invalid semantic versions.
- Store live-fire results under the immutable git revision and skill version. Never overwrite a baseline after promotion.
- Review P0 and P1 incidents weekly. Review model-reachable trigger corpora monthly. Review volatile external facts monthly or by their explicit `review_after` date. Run a complete 58-skill portfolio audit quarterly and before a major catalog release.
- Require an owner from `.fork/catalog.yaml` to approve trigger and permission changes. Require a second reviewer for destructive or external-state capabilities.
- At each catalog change, regenerate marketplace and catalog views, refresh docs and role pages where behavior changed, re-read `ask-matt`, run route coverage, then run the relevant live-fire slice.

### 4. Compact `INDEX.md`

Do not maintain 58 entries by hand. Generate the inventory and links from `.fork/catalog.yaml`, then layer this short decision map on top. This is the proposed human-facing content:

```markdown
# Skill index

Start with the outcome you need. Each link opens the skill instructions. For the full catalog by role and provenance, see README.md.

## Decide what to do

- Unclear idea: to-prd
- Pressure-test a decision: grilling
- Turn settled decisions into a spec: to-spec
- Split an approved spec into work: to-tickets
- Choose the next ready item: wayfinder
- Repair issue labels and readiness: triage

## Build or change code

- Ship work end to end: cook
- Try an idea without keeping the code: prototype
- Build test-first: tdd
- Diagnose a hard bug: diagnosing-bugs
- Verify a feature or fix: do-test
- Review against standards and spec: code-review
- Resolve an active merge or rebase: resolving-merge-conflicts

## Design the codebase

- Choose a module seam: codebase-design
- Find architectural deepening opportunities: improve-codebase-architecture
- Clarify domain terms or decisions: domain-modeling
- Escape a design full of special cases: when-stuck

## Kotlin Multiplatform

- Create or upgrade the shared module: kmp-module-setup
- Choose a platform boundary: kmp-boundaries
- Configure a Ktor client: kmp-ktor
- Connect the shared module to iOS: kmp-ios-integration
- Build shared Compose UI: compose-multiplatform-ui
- Put tests at the right layer: kmp-test-seams
- Release an app or publish a library: kmp-release-and-publish

## Workbench and communication

- Isolate work in a worktree: use-git-worktree
- Bring a capability from another repository: port-from-repo
- Hand work to another agent: handoff
- Create a human-run setup or migration wizard: wizard
- Explain a complex shape visually: show-me
- Re-explain something more slowly: wait-what

## Writing

- Capture raw material: writing-fragments
- Shape a draft: writing-shape
- Remove generic AI voice before publication: unslop
- Write instructions for agents: writing-for-agents
```

The generator should append a compact alphabetical table for all skills, including internal and beta status, without promoting them into the top-level README. This preserves the catalog as the source of truth while giving humans an outcome-first entry point.

### 5. Authoring standard for new skills

Apply the repository's three rules in order.

**Trigger**

1. Name the user-visible job, concrete trigger phrases, and the nearest sibling that should not fire.
2. State invocation mode. User-only picker copy must be short and discriminating; model-reachable descriptions need enough symptoms and nouns for routing.
3. Add trigger evals before promotion: positive, negative, and sibling pairs. A description is not done because it reads well.

**Structure**

1. Start with one defining invariant. If it cannot fit in one sentence, the skill may contain multiple jobs.
2. Declare prerequisites, capability checks, inputs, ordered steps, gates, output contract, stop state, and recovery state.
3. Keep stable decisions in `SKILL.md`; move commands, large examples, platform variants, and volatile facts into named references loaded only when needed.
4. Resolve other skills through catalog-valid names. CI must reject an unknown reference.
5. Name the mutation level of every state-changing step. Never smuggle commit, push, PR, tracker, external message, stash, revert, cleanup, or deletion into "done."

**Steering**

1. Write observable instructions: what the agent reads, decides, changes, verifies, reports, and must not do.
2. Give exception criteria for preferences and absolute rules only for real invariants.
3. Include ordinary, edge, missing-capability, denied-authority, and recovery eval cases.
4. Measure effect against a baseline. Retain severe-failure counts, task success, tokens, time, and human preference.
5. Promotion requires a clean static suite, held-out trigger evidence, live-fire steering evidence, docs and router synchronization, and an owner review.

Definition of done for a new skill:

- It has one catalog entry, correct invocation configuration, valid references, required README and docs registration, and no unsanctioned vendor edits.
- Its trigger wins against its two nearest siblings on held-out prompts.
- Its normal and recovery paths complete on fixtures without unauthorized state change.
- Its output contract can be graded from evidence, not from author intent.
- Its volatile facts carry primary sources and review dates.
- Its user-facing prose passes the repository's no-em-dash rule and the `unslop` checker where applicable.

## Validation record

- Audit integrity: 58 inventory rows, 58 trait rows, 58 score rows, 58 per-skill reports, and 348 dimension citations. Every citation quote occurs on its stated source line. Every weighted total matches the rubric, and both the scorecard and reports run from worst to best.
- Repository structure: `skillcheck.py --json` returned 691 PASS and no failures.
- Trigger similarity: `check-confusable-skills.py` returned PASS across 32 model-invoked descriptions, with 26 user-invoked descriptions excluded by design and a maximum Jaccard similarity of 0.185.
- Fork safety: `forkcheck.py` returned 7 PASS, and `test_forkcheck.sh` returned 26 PASS with no failures.
- Functional guardrail: `test_guardrail.sh` returned 39 PASS with no failures.
- Human-facing prose: the `unslop` checker reported four strict findings and 36 candidates. The four strict characters occur inside exact source quotations, where changing them would corrupt audit evidence. Candidate terms were retained where they are source quotations or repository terms of art. The report itself introduces no em dash characters.

## Final assessment

The portfolio is structurally disciplined but behaviorally under-tested. Its best skills are genuinely strong: they name a narrow invariant, expose a decision procedure, and stop on evidence. Its weakest skills are not merely verbose or terse. They either advertise one job and perform another, call capabilities that do not exist, or cross mutation boundaries without authority.

The immediate release risk is small enough to repair quickly: remove five unresolved reference occurrences, correct one router section, restore the advertised TDD loop, gate diagnosis before remediation, and retire one unsupported internal technique. The durable upgrade is larger but straightforward: turn Trigger, Structure, Steering into executable gates backed by Beads incidents, retained evals, held-out prompts, and owner-reviewed versions. That system would make the next audit an evidence comparison instead of another static reading exercise.
