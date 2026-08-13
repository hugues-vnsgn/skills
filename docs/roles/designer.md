# Skills for designers

Twelve skills, none of which require you to write Kotlin. They cover the three things design work keeps needing from an agent: something to react to, someone to argue with, and a way to get the thinking written down.

Every skill here is one whose `audience` names `designer` in [`.fork/catalog.yaml`](../../.fork/catalog.yaml), the single source of truth for who a skill is for. Each entry links to its docs page, or straight to `SKILL.md` where the skill has none (beta, `misc/`, `in-progress/`).

You invoke any of them by typing `/<name>`. Entries marked _(auto)_ the agent can also reach for on its own when the task fits.

## Get something in front of you

- **[prototype](../engineering/prototype.md)** _(auto)_ — the fastest way to stop arguing about a UI in the abstract: several radically different variations, toggleable from one route, thrown away afterwards.
- **[compose-multiplatform-ui](../team/mobile/compose-multiplatform-ui.md)** _(auto)_ — what the shared UI layer can and cannot express, before you spec a screen against it: how resources, navigation, and SwiftUI/UIKit interop actually behave on both platforms.

## Sharpen the idea

- **[grill-me](../productivity/grill-me.md)** — hand over a design you believe in and get interviewed until every branch is resolved. The unresolved branches are the point.
- **[grilling](../productivity/grilling.md)** _(auto)_ — the interview primitive behind `/grill-me`; the agent runs it when you say "grill me on this", so you rarely type it.
- **[to-questionnaire](../productivity/to-questionnaire.md)** — the call is not yours alone. Turn it into a questionnaire for the person who can make it, answerable async or in one meeting.
- **[wait-what](../productivity/wait-what.md)** — the agent said something in engineering dialect and it did not land. Fire this and get it re-pitched in plain English using your project's own vocabulary.

## Write it up

Three passes over the same material, in this order — they are one workflow, not three options.

- **[writing-fragments](../../skills/in-progress/writing-fragments/SKILL.md)** — explore: mine the raw material for what you actually think, with no structure yet.
- **[writing-beats](../../skills/in-progress/writing-beats/SKILL.md)** — exploit: assemble the fragments into a journey, grounding each term before the argument leans on it.
- **[writing-shape](../../skills/in-progress/writing-shape/SKILL.md)** — exploit: shape the result into the finished piece, paragraph by paragraph.

## Long sessions

- **[handoff](../productivity/handoff.md)** — the session got long. Compact it into a document the next agent picks up cold.
- **[claude-handoff](../../skills/in-progress/claude-handoff/SKILL.md)** — the same handoff, but straight into a fresh background agent that carries on immediately.
- **[teach](../productivity/teach.md)** — learn something over several sessions (a design system's constraints, how the mobile stack fits together) with this directory as the workspace that remembers your progress.

## Where to look next

- The whole set, one table with origin and owner: [CATALOG.md](../../CATALOG.md)
- Other roles: [engineer](./engineer.md), [analyst](./analyst.md), [QA](./qa.md), [staff engineer](./staff.md)
