# Skills for QA engineers

Thirteen skills covering the quality loop: what a test is worth, where it lives, what happens when something breaks, and how a build reaches you. Read in order the first time.

Every skill here is one whose `audience` names `qa` in [`.fork/catalog.yaml`](../../.fork/catalog.yaml), the single source of truth for who a skill is for. Each entry links to its docs page, or straight to `SKILL.md` where the skill has none (beta, `misc/`, `in-progress/`).

You invoke any of them by typing `/<name>`. Entries marked _(auto)_ the agent can also reach for on its own when the task fits.

## The loop

- **[tdd](../engineering/tdd.md)** _(auto)_ — red-green-refactor, one vertical slice at a time. It owns the loop and the standard for what makes a test worth keeping.
- **[kmp-test-seams](../team/mobile/kmp-test-seams.md)** _(auto)_ — on a Kotlin Multiplatform repo, the two questions `/tdd` cannot answer: does this test belong in `commonTest` or a platform source set, and which Gradle task actually proves the slice green.
- **[code-review](../engineering/code-review.md)** _(auto)_ — review a diff on two axes at once: standards, and whether it does what the originating ticket asked. The second axis is the one that catches shipped-but-wrong.
- **[do-test](../../skills/team/quality/do-test/SKILL.md)** _(auto)_ — verify a feature or a bug fix: derive a test matrix, run it, read every surface, and report a SHIP/BLOCKED/UNVERIFIED verdict backed by evidence. Beta.

## When something is broken

- **[diagnosing-bugs](../engineering/diagnosing-bugs.md)** _(auto)_ — the discipline for a bug nobody can explain: build a loop that goes red on *this* bug, minimise it, then hypothesise — before anyone proposes a fix.
- **[triage](../engineering/triage.md)** — move incoming issues and external PRs through a state machine of triage roles, ending in a brief an agent can act on.

## Getting a build to test

- **[kmp-release-and-publish](../team/mobile/kmp-release-and-publish.md)** _(auto)_ — how the Android and iOS builds are actually produced: R8 over shared code, archive and TestFlight, and the CI task split. Read it when a build behaves differently from a debug run.

## Sharpen and communicate

- **[grill-me](../productivity/grill-me.md)** — get interviewed about a test plan or a risk assessment until the gaps surface.
- **[grilling](../productivity/grilling.md)** _(auto)_ — the interview primitive the grill skills run on; the agent reaches for it on any "grill me" phrasing.
- **[to-questionnaire](../productivity/to-questionnaire.md)** — an acceptance question only product or design can answer becomes a questionnaire they can fill in async.
- **[wait-what](../productivity/wait-what.md)** — a reproduction or a fix came back in dialect you cannot verify against. Get it re-pitched in plain English.

## Long sessions

- **[handoff](../productivity/handoff.md)** — compact a long investigation into a document the next agent picks up cold.
- **[claude-handoff](../../skills/in-progress/claude-handoff/SKILL.md)** — the same, straight into a fresh background agent that carries on immediately.
- **[teach](../productivity/teach.md)** — learn a testing technique or an unfamiliar part of the stack over several sessions, with this directory as the stateful workspace.

## Where to look next

- The whole set, one table with origin and owner: [CATALOG.md](../../CATALOG.md)
- Other roles: [engineer](./engineer.md), [designer](./designer.md), [analyst](./analyst.md), [staff engineer](./staff.md)
