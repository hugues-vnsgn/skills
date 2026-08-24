# Skills for business analysts

The path from "we think we want this" to tickets an engineer can pick up without asking you a single clarifying question. Read it in order, because each section feeds the next.

Every skill here is one whose `audience` names `analyst` in [`.fork/catalog.yaml`](../../.fork/catalog.yaml), the single source of truth for who a skill is for. Each entry links to its docs page, or straight to `SKILL.md` where the skill has none (beta, `misc/`, `in-progress/`).

You invoke any of them by typing `/<name>`. Entries marked _(auto)_ the agent can also reach for on its own when the task fits.

## Understand the domain

- **[grill-with-docs](../engineering/grill-with-docs.md)**: the workhorse. A relentless interview about the plan that writes the glossary and the decision records as it goes, so the understanding survives the session.
- **[domain-modeling](../engineering/domain-modeling.md)** _(auto)_: reach for this the moment two people use one word for two things. It stress-tests the term against edge cases and records the winner.
- **[research](../engineering/research.md)** _(auto)_: a question of fact (a regulation, an API's real behaviour, what a competitor does) goes to a background agent and comes back as a cited file, not an opinion.

## Turn it into work

- **[to-prd](../house/discovery/to-prd.md)**: for initiative-scale work, turn the grilled conversation into a PRD first: why it's worth building, for whom, and what success looks like. That is the document a stakeholder outside engineering signs off on. It refuses unripe ideas and marks undecided targets `⚠ TBD` rather than inventing them. A single well-scoped feature skips this.
- **[to-spec](../engineering/to-spec.md)**: the conversation is settled; publish it as a spec on the tracker. It synthesises what was already discussed rather than interviewing you again.
- **[to-tickets](../engineering/to-tickets.md)**: split the spec into tracer-bullet tickets, each declaring what blocks it, on the tracker or as local files.

## Sharpen the thinking

- **[grill-me](../productivity/grill-me.md)**: the same interview as `/grill-with-docs` without the doc-writing, for a decision that does not need a paper trail.
- **[grilling](../productivity/grilling.md)** _(auto)_: the interview primitive the grill skills run on; the agent reaches for it on any "grill me" phrasing.
- **[to-questionnaire](../productivity/to-questionnaire.md)**: a decision you cannot make alone becomes a Markdown questionnaire for the one person who can. It grills you about the send, not the subject.
- **[wait-what](../productivity/wait-what.md)**: an answer came back in implementation dialect. Get it re-pitched in your project's vocabulary instead of nodding along.

## Write it up

Three passes over the same material, in this order: one workflow, not three options. Then a fourth over the finished draft.

- **[writing-fragments](../../skills/in-progress/writing-fragments/SKILL.md)**: explore: mine the raw notes for what is actually being claimed, no structure yet.
- **[writing-beats](../../skills/in-progress/writing-beats/SKILL.md)**: exploit: assemble the fragments into a journey, grounding each term before a beat leans on it.
- **[writing-shape](../../skills/in-progress/writing-shape/SKILL.md)**: exploit: shape it into the finished document, paragraph by paragraph.
- **[unslop](../house/writing/unslop.md)** _(auto)_ runs the edit pass: cut the AI tells from the finished draft, and refuse to soften a claim to do it. Anything unsourced comes back flagged rather than smoothed.

## Long sessions

- **[handoff](../productivity/handoff.md)**: compact a long discovery session into a document another agent can resume from.
- **[claude-handoff](../../skills/in-progress/claude-handoff/SKILL.md)**: the same, handed straight to a fresh background agent that continues immediately.
- **[teach](../productivity/teach.md)**: learn a domain or a technique across several sessions, with this directory as the workspace that remembers where you got to.

## Where to look next

- The whole set, one table with origin and owner: [CATALOG.md](../../CATALOG.md)
- Other roles: [engineer](./engineer.md), [designer](./designer.md), [QA](./qa.md), [staff engineer](./staff.md)
