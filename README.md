# hugues-vnsgn/skills

[![skills.sh](https://skills.sh/b/hugues-vnsgn/skills)](https://skills.sh/hugues-vnsgn/skills)

What this fork adds on top of upstream:

- **`skills/house/`**: the fork's own skills, grouped by domain: [`mobile/`](./skills/house/mobile/README.md) for Kotlin Multiplatform + Compose Multiplatform development, [`platform/`](./skills/house/platform/README.md) for the toolchain itself
- Fork conventions in [MAINTENANCE.md](./MAINTENANCE.md) and [CUSTOMIZING.md](./CUSTOMIZING.md)

## Installation (30-second setup)

### 1. Get the skills

```bash
npx skills@latest add hugues-vnsgn/skills
```

Skills are grouped by domain: **Engineering**, **Productivity**, and one group per house domain (**Mobile**, **Platform**, and so on). Each group header takes a single keystroke to select everything under it. Pick the groups or the individual skills you want, then choose which coding agents to install them on. **Expand **Platform** and make sure `setup-osxsystem-skills` is ticked.**

Claude Code, Codex, Cursor, Pi and 70-odd other agents are offered by name. **[omp (oh-my-pi)](https://omp.sh) is not yet listed by name, so choose the `agents` target**, which writes to `~/.agents/skills`, the location omp reads natively.

The installer writes the skills into your repo as ordinary files you own and can edit. Nothing updates behind your back; pull the latest changes when you want them with `npx skills update`.

### 2. Run `/setup-osxsystem-skills`

In your agent, run it once per repo. It will:

- Ask you which issue tracker you want to use (GitHub, Linear, or local files)
- Ask you what labels you apply to tickets when you triage them (`/triage` uses labels)
- Ask you where you want to save any docs we create

### 3. Bam, you're ready to go.

## Reference

**Looking for what applies to your job rather than the whole list?** Each role page carries a curated reading order, with a line on why you'd reach for each skill: [software engineer](./docs/roles/engineer.md) · [designer](./docs/roles/designer.md) · [business analyst](./docs/roles/analyst.md) · [QA engineer](./docs/roles/qa.md) · [staff engineer](./docs/roles/staff.md). Every skill with its origin, domain, audience and owner is in [CATALOG.md](./CATALOG.md).

The sections below list every skill by bucket. These split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them (e.g. `/grill-me`); their job is to orchestrate. **Model-invoked** skills can be invoked by you _or_ reached for automatically by the agent when the task fits; they hold the reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Engineering

Skills I use daily for code work.

**User-invoked**

- **[ask-matt](./skills/engineering/ask-matt/SKILL.md)**: Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)**: Grilling session that also builds your project's domain model, sharpening terminology and updating `CONTEXT.md` and ADRs inline.
- **[triage](./skills/engineering/triage/SKILL.md)**: Move issues through a state machine of triage roles.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)**: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it to the issue tracker. No interview, just synthesizes what you've already discussed.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)**: Break any plan, spec, or conversation into a set of tracer-bullet tickets, each declaring its blocking edges, written as text in a local file, or as native blocking links on a real tracker.
- **[implement](./skills/engineering/implement/SKILL.md)**: Build the work described by a spec or set of tickets, driving `/tdd` at pre-agreed seams and closing out with `/code-review` before committing.
- **[wayfinder](./skills/engineering/wayfinder/SKILL.md)**: Plan a huge chunk of work, more than one agent session can hold, as a shared map of decision tickets on the issue tracker, and resolve them one at a time until the way to the destination is clear.

**Model-invoked**

- **[prototype](./skills/engineering/prototype/SKILL.md)**: Build a throwaway prototype to answer a design question, either a single shareable HTML file for state/logic questions, or several radically different UI variations toggleable from one route.
- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)**: Disciplined diagnosis loop for hard bugs and performance regressions: build a feedback loop that goes red on this bug → minimise → hypothesise → instrument → fix → regression-test.
- **[research](./skills/engineering/research/SKILL.md)**: Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file in the repo, run as a background agent.
- **[tdd](./skills/engineering/tdd/SKILL.md)**: Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model: challenge terms against the glossary, stress-test with edge-case scenarios, and update `CONTEXT.md` and ADRs inline.
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface.
- **[code-review](./skills/engineering/code-review/SKILL.md)**: Two-axis review of the diff since a fixed point: **Standards** (does it follow the repo's coding standards, plus a Fowler smell baseline?) and **Spec** (does it faithfully implement the originating issue/spec?), run as parallel sub-agents so neither pollutes the other.
- **[resolving-merge-conflicts](./skills/engineering/resolving-merge-conflicts/SKILL.md)**: Work through an in-progress git merge or rebase conflict hunk by hunk, resolving by intent traced to each side's primary source, then finish the operation (never `--abort`).
- **[wizard](./skills/engineering/wizard/SKILL.md)**: Generate an interactive bash wizard that walks a human through steps only they can perform: provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the design tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)**: Compact the current conversation into a handoff document so another agent can continue the work.
- **[teach](./skills/productivity/teach/SKILL.md)**: Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[to-questionnaire](./skills/productivity/to-questionnaire/SKILL.md)**: Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can, filled in async, or together over a meeting. It grills you about the send (who it's for, what you need back), not the subject.
- **[wait-what](./skills/productivity/wait-what/SKILL.md)**: Fire this the moment a message doesn't land. The agent re-pitches it with the context you're missing, in plain English, using your `CONTEXT.md` vocabulary.

**Model-invoked**

- **[grilling](./skills/productivity/grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the design tree is resolved. The reusable interview primitive behind `grill-me`, `grill-with-docs`, `triage`, `wayfinder` and `improve-codebase-architecture`.
- **[writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md/CLAUDE.md, and any doc an agent reaches by a pointer.

### Discovery

House skills for the phase before the spec, turning an idea into documents a CEO, BA, and engineer can all read the same way. Fork addition, see [skills/house/discovery/README.md](./skills/house/discovery/README.md).

**User-invoked**

- **[to-prd](./skills/house/discovery/to-prd/SKILL.md)**: Turn the current conversation into a Product Requirements Document, covering why it's worth building, for whom, and what success looks like. Synthesis first, one batched round of questions for the decisions only you can make; saved in the repo, linked from the tracker.

### Mobile

House skills for Kotlin Multiplatform + Compose Multiplatform development (Android + iOS/Swift). Fork addition, see [skills/house/mobile/README.md](./skills/house/mobile/README.md).

**Model-invoked**

- **[kmp-module-setup](./skills/house/mobile/kmp-module-setup/SKILL.md)**: Scaffold or audit a shared KMP module: targets, source-set hierarchy, version catalog (Kotlin/AGP/CMP pinned together), framework block, expect/actual vs interfaces + DI.
- **[kmp-ios-integration](./skills/house/mobile/kmp-ios-integration/SKILL.md)**: Connect the shared framework to Xcode: direct vs CocoaPods vs SPM vs KMMBridge, setup checklists, and a Swift-facing API review checklist (@Throws, sealed classes, coroutines, SKIE).
- **[compose-multiplatform-ui](./skills/house/mobile/compose-multiplatform-ui/SKILL.md)**: Shared Compose UI: per-platform entry points, composeResources/Res, Navigation and ViewModel in common code, SwiftUI/UIKit interop both directions, iOS performance and accessibility.
- **[kmp-release-and-publish](./skills/house/mobile/kmp-release-and-publish/SKILL.md)**: Ship it: Android release with R8 over shared code, iOS archive/TestFlight (privacy manifest, dSYMs), Maven Central via the Central Portal, CI runner split with konan caching.
- **[kmp-test-seams](./skills/house/mobile/kmp-test-seams/SKILL.md)**: The platform layer under the red-green loop: seams in `commonMain`, `commonTest` vs `androidHostTest`/`iosTest`, and the cheapest Gradle task that proves a slice green.

### Platform

House skills for the toolchain itself: repo configuration, porting capabilities in, unsticking a design. Fork addition, see [skills/house/platform/README.md](./skills/house/platform/README.md).

**User-invoked**

- **[setup-osxsystem-skills](./skills/house/platform/setup-osxsystem-skills/SKILL.md)**: Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo before using the other engineering skills.
- **[port-from-repo](./skills/house/platform/port-from-repo/SKILL.md)**: Bring a capability across from another codebase. Study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.

### Writing

House skills for prose a human reads, as opposed to the agent-facing documents `writing-for-agents` covers. Fork addition, see [skills/house/writing/README.md](./skills/house/writing/README.md).

**Model-invoked**

- **[unslop](./skills/house/writing/unslop/SKILL.md)** cuts the AI tells out of a draft and gives it a voice back. Sets the register first (reference, argument, conversation, instruction), never changes a claim without telling you, and ships a checker that finds the mechanical tells so judgment goes to the rest.

## Repository layout

The tree is split by **provenance**, meaning who owns the bytes, rather than by audience. If you're looking for *your* skills, use the [role pages](./docs/roles/engineer.md) or [CATALOG.md](./CATALOG.md) instead of walking the folders.

```
skills/
├── engineering/          # ═══ UPSTREAM — vendor territory, byte-frozen ═══
├── productivity/         #   never moved, renamed, or edited; every deliberate
├── misc/                 #   divergence is enumerated in .fork/sanctioned-edits.txt
├── in-progress/          #   and enforced by CI (scripts/harness/forkcheck.py)
├── deprecated/
│
└── team/                 # ═══ FORK — upstream never writes here ═══
    ├── mobile/           #   KMP/CMP skills: kmp-module-setup, kmp-ios-integration,
    │                     #   compose-multiplatform-ui, kmp-release-and-publish,
    │                     #   kmp-test-seams
    └── platform/         #   toolchain skills: setup-osxsystem-skills,
                          #   port-from-repo, when-stuck (beta)
                          #   (design/, discovery/, quality/ are created when
                          #    their first skill lands — no empty folders)

docs/
├── engineering/  productivity/    # docs pages mirroring the upstream buckets
├── team/                          # docs pages mirroring skills/house/
└── roles/                         # per-role reading orders: engineer, designer,
                                   #   analyst, qa, staff

.fork/                    # fork control plane: catalog.yaml (source of truth for
                          #   origin/domain/audience/owner), upstream.lock,
                          #   divergence.md, sanctioned-edits.txt, sync-playbook.md
CATALOG.md                # generated from .fork/catalog.yaml — do not hand-edit
```

Skills install **flat by name** (`scripts/link-skills.sh`), so a skill's folder never changes how it's invoked. The layout exists for maintenance and upstream syncs, not for users. The sync procedure lives in [.fork/sync-playbook.md](./.fork/sync-playbook.md).

The **osxsystem fork** of [mattpocock/skills](https://github.com/mattpocock/skills): a personal setup, customized for mobile development with **Kotlin Multiplatform + Compose Multiplatform** (Android + iOS/Swift).

> [!NOTE]
> This project uses [mattpocock/skills](https://github.com/mattpocock/skills), Matt Pocock's agent skills for real engineering. All credit for the engineering, productivity, and misc skills goes to the upstream author; read the [upstream README](https://github.com/mattpocock/skills#why-these-skills-exist) for the philosophy behind them.
