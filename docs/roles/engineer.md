# Skills for software engineers

The full daily set: shaping work, building it, reviewing it, and the mobile layer underneath. Read top to bottom the first time — the order is roughly the order you meet these skills on a real piece of work.

Every skill here is one whose `audience` names `engineer` in [`.fork/catalog.yaml`](../../.fork/catalog.yaml), the single source of truth for who a skill is for. Each entry links to its docs page, or straight to `SKILL.md` where the skill has none (beta, `misc/`, `in-progress/`).

You invoke any of them by typing `/<name>`. Entries marked _(auto)_ the agent can also reach for on its own when the task fits.

## Set up the repo, once

- **[setup-osxsystem-skills](../team/platform/setup-osxsystem-skills.md)** — run this before anything else in a new repo: it picks the issue tracker, the triage labels, and where docs get written. `/triage`, `/to-spec` and `/to-tickets` do nothing sensible until it has.
- **[git-guardrails-claude-code](../../skills/misc/git-guardrails-claude-code/SKILL.md)** _(auto)_ — install the hook that blocks `git push`, `reset --hard` and friends before an agent can run them.
- **[setup-pre-commit](../../skills/misc/setup-pre-commit/SKILL.md)** _(auto)_ — wire Husky + lint-staged so formatting, types and tests run at commit time instead of in review.
- **[setup-ts-deep-modules](../../skills/in-progress/setup-ts-deep-modules/SKILL.md)** — TypeScript repos only: enforce that each package is reachable only through its entry point.

## The main flow

- **[ask-matt](../engineering/ask-matt.md)** — you are lost, or unsure which of these fits. Start here and it routes you.
- **[grill-with-docs](../engineering/grill-with-docs.md)** — the interview that hardens a vague plan into a decided one, writing the glossary and ADRs as it goes.
- **[to-spec](../engineering/to-spec.md)** — the conversation is decided; turn it into a spec on the tracker. It does not re-interview you.
- **[to-tickets](../engineering/to-tickets.md)** — break the spec into tracer-bullet tickets with their blocking edges declared.
- **[implement](../engineering/implement.md)** — build a ticket or spec end to end, driving `/tdd` at the agreed seams and closing with `/code-review`.
- **[cook](../../skills/team/delivery/cook/SKILL.md)** _(auto)_ — the gated alternative to `/implement`: a research → plan → implement → test → review pipeline that stops for your approval between steps. Beta.
- **[tdd](../engineering/tdd.md)** _(auto)_ — the red-green-refactor loop itself, one vertical slice at a time.
- **[do-test](../../skills/team/quality/do-test/SKILL.md)** _(auto)_ — after the build: derive a test matrix from the change, run it, and get a SHIP/BLOCKED/UNVERIFIED verdict backed by evidence. Beta.
- **[code-review](../engineering/code-review.md)** _(auto)_ — review the diff since a fixed point on two axes at once: does it follow the repo's standards, and does it do what the spec asked?

## While you are building

- **[codebase-design](../engineering/codebase-design.md)** _(auto)_ — the vocabulary for deep modules and where a seam goes, when the shape of the code is the question.
- **[prototype](../engineering/prototype.md)** _(auto)_ — a throwaway artifact that answers one design question, rather than arguing about it.
- **[domain-modeling](../engineering/domain-modeling.md)** _(auto)_ — when two people are using one word for two things, pin the term down and record it.
- **[research](../engineering/research.md)** _(auto)_ — delegate the reading to a background agent and get back a cited Markdown file instead of a guess.
- **[project-organization](../../skills/team/delivery/project-organization/SKILL.md)** _(auto)_ — where any output file goes and what it's called: plans, reports, journals, assets, and their markdown templates. Beta.
- **[wizard](../engineering/wizard.md)** _(auto)_ — the steps only a human can do (dashboards, credentials, a cutover) become an interactive bash script that walks them through it.
- **[migrate-to-shoehorn](../../skills/misc/migrate-to-shoehorn/SKILL.md)** _(auto)_ — mechanical: replace `as` assertions in TypeScript tests with shoehorn.
- **[scaffold-exercises](../../skills/misc/scaffold-exercises/SKILL.md)** _(auto)_ — mechanical: stub out an exercise tree (problems, solutions, explainers) for course material.

## When it goes wrong

- **[diagnosing-bugs](../engineering/diagnosing-bugs.md)** _(auto)_ — a bug you cannot explain, or a performance regression. Builds a loop that goes red on *this* bug before anything is fixed.
- **[when-stuck](../../skills/team/platform/when-stuck/SKILL.md)** _(auto)_ — not a bug: the design will not resolve, every option feels forced, or special cases keep accreting.
- **[resolving-merge-conflicts](../engineering/resolving-merge-conflicts.md)** _(auto)_ — work an in-progress merge or rebase hunk by hunk, by intent, and finish it — never `--abort`.
- **[wait-what](../productivity/wait-what.md)** — the agent's last message did not land. Fire this instead of nodding along.

## Mobile — Kotlin Multiplatform + Compose

- **[kmp-module-setup](../team/mobile/kmp-module-setup.md)** _(auto)_ — targets, source sets, the version catalog, and the `expect`/`actual`-vs-interface call.
- **[kmp-test-seams](../team/mobile/kmp-test-seams.md)** _(auto)_ — where a test lives (`commonTest` vs a platform source set) and the cheapest Gradle task that proves the slice. Sits underneath `/tdd`, not instead of it.
- **[compose-multiplatform-ui](../team/mobile/compose-multiplatform-ui.md)** _(auto)_ — shared UI: entry points per platform, resources, navigation and ViewModel in common code, SwiftUI/UIKit interop.
- **[kmp-ios-integration](../team/mobile/kmp-ios-integration.md)** _(auto)_ — getting the framework into Xcode, and the Swift-facing API review that stops Kotlin idioms leaking awkwardly.
- **[kmp-release-and-publish](../team/mobile/kmp-release-and-publish.md)** _(auto)_ — Android release with R8 over shared code, iOS archive and TestFlight, Maven Central, CI runner split.
- **[kmp-boundaries](../../skills/team/mobile/kmp-boundaries/SKILL.md)** _(auto, beta)_ — common code needs a platform API and you are picking the boundary shape: `expect`/`actual`, a common interface with platform bindings, or separate screens.
- **[kmp-ktor](../../skills/team/mobile/kmp-ktor/SKILL.md)** _(auto, beta)_ — the HTTP layer: engine per platform, serialization, bearer auth with refresh, `MockEngine` in tests, error mapping at the repository edge.
- **[kotlin-multiplatform](../../skills/team/mobile/kotlin-multiplatform/SKILL.md)** _(auto, beta)_ — the share-or-specialise call itself, and which source set the answer belongs in.

## Work bigger than one session

- **[wayfinder](../engineering/wayfinder.md)** — the work is too big to hold in one session: map it as decision tickets and resolve them one at a time.
- **[improve-codebase-architecture](../engineering/improve-codebase-architecture.md)** — periodic: scan for deepening opportunities, then grill through the one you pick.
- **[triage](../engineering/triage.md)** — move issues and external PRs through the triage state machine into agent-ready briefs.
- **[handoff](../productivity/handoff.md)** — compact this conversation into a document the next agent can pick up.
- **[claude-handoff](../../skills/in-progress/claude-handoff/SKILL.md)** — same idea, but hands off to a fresh background agent that starts immediately.
- **[loop-me](../../skills/in-progress/loop-me/SKILL.md)** — you want to build a workflow of your own and need the spec grilled out of you first.

## Thinking out loud

- **[grill-me](../productivity/grill-me.md)** — get interviewed about a plan until every branch is resolved. The general-purpose version of `/grill-with-docs`.
- **[grilling](../productivity/grilling.md)** _(auto)_ — the interview primitive the grill skills run on; you rarely invoke it directly.
- **[to-questionnaire](../productivity/to-questionnaire.md)** — the decision needs someone else. Turn it into a questionnaire they can fill in async.
- **[teach](../productivity/teach.md)** — learn a concept over several sessions, with this directory as the workspace that remembers where you got to.

## Working on the skills themselves

- **[writing-for-agents](../productivity/writing-for-agents.md)** _(auto)_ — before you edit a `SKILL.md`, a `CLAUDE.md`, or any document an agent reaches by pointer: they are written for a reader who cannot ask a follow-up question.
- **[port-from-repo](../team/platform/port-from-repo.md)** — another repo does something well and you want it here. Study it, argue against it, then adapt it to this codebase's idiom instead of transplanting it.
- **[herdr](../../skills/team/platform/herdr/SKILL.md)** _(auto, beta)_ — drive Herdr's panes, tabs and workspaces from an agent. Only reaches for it when you name Herdr, and only with `HERDR_ENV=1` set.

## Where to look next

- The whole set, one table with origin and owner: [CATALOG.md](../../CATALOG.md)
- Other roles: [designer](./designer.md), [analyst](./analyst.md), [QA](./qa.md), [staff engineer](./staff.md)
