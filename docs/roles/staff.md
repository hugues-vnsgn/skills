# Skills for staff engineers

The skills that operate above a single ticket: shaping work other people will do, deciding architecture, reviewing, and growing the toolchain itself. The engineer page has the rest of the daily set — this one is what the role adds on top.

Every skill here is one whose `audience` names `staff` in [`.fork/catalog.yaml`](../../.fork/catalog.yaml), the single source of truth for who a skill is for. Each entry links to its docs page, or straight to `SKILL.md` where the skill has none (beta, `misc/`, `in-progress/`).

You invoke any of them by typing `/<name>`. Entries marked _(auto)_ the agent can also reach for on its own when the task fits.

## Know the map

- **[ask-matt](../engineering/ask-matt.md)** — the router over every user-invoked skill and how the flows connect. Worth reading once end to end rather than only when lost, because routing other people is part of the job.

## Shape the work

- **[grill-with-docs](../engineering/grill-with-docs.md)** — the interview that turns a direction into decided architecture, leaving ADRs and a glossary behind as evidence of *why*.
- **[to-prd](../house/discovery/to-prd.md)** — for initiative-scale work, anchor the *why* in a PRD before anyone specs: the document non-engineering stakeholders sign, which every spec that follows references. Skip it for a single well-scoped feature.
- **[to-spec](../engineering/to-spec.md)** — publish the decided conversation as a spec, without a second interview.
- **[to-tickets](../engineering/to-tickets.md)** — split it into tracer-bullet tickets with explicit blocking edges, so parallel work is safe.
- **[wayfinder](../engineering/wayfinder.md)** — for work too big for one agent session: a shared map of decision tickets, resolved one at a time. This is the one that scales past a spec.
- **[triage](../engineering/triage.md)** — put incoming issues and external PRs through a state machine, ending in briefs someone else can pick up.

## Decide the shape of the code

- **[codebase-design](../engineering/codebase-design.md)** _(auto)_ — the shared vocabulary: deep modules, seams, what belongs behind an interface. Adopt it and reviews stop being taste arguments.
- **[improve-codebase-architecture](../engineering/improve-codebase-architecture.md)** — periodic maintenance: scan the codebase for deepening opportunities, get an HTML report, grill through the one you pick.
- **[when-stuck](../../skills/house/platform/when-stuck/SKILL.md)** _(auto)_ — five moves for a design that will not resolve: inversion, the scale game, the simplification cascade, meta-pattern, collision. For design stuck-ness only — a bug goes to `/diagnosing-bugs`.
- **[domain-modeling](../engineering/domain-modeling.md)** _(auto)_ — pin down a term the team is using two ways, and record the decision where the next person will find it.
- **[research](../engineering/research.md)** _(auto)_ — delegate the reading to a background agent; get back cited primary sources instead of a plausible answer.

## Review

- **[code-review](../engineering/code-review.md)** _(auto)_ — standards and spec-fidelity reviewed as parallel sub-agents, so neither pollutes the other. The spec axis is the one a human reviewer usually skips.

## Grow the toolchain

- **[setup-osxsystem-skills](../house/platform/setup-osxsystem-skills.md)** — run once per repo to configure the tracker, triage labels and docs layout every other skill assumes.
- **[port-from-repo](../house/platform/port-from-repo.md)** — bring a capability across from another codebase: study it, argue against it, then adapt it to this codebase's idiom rather than transplanting it.
- **[sync-upstream](../../skills/house/platform/sync-upstream/SKILL.md)** — drive the upstream merge: read the delta, classify each conflict before resolving it, and land the sync PR without breaking the lock. Maintainers only. Beta.
- **[writing-for-agents](../productivity/writing-for-agents.md)** _(auto)_ — how to write a skill, an `AGENTS.md`, or any document an agent reaches by pointer. Read before authoring a house skill.
- **[project-organization](../../skills/house/delivery/project-organization/SKILL.md)** _(auto)_ — the conventions every output file follows: where plans, reports, journals and assets live, and their markdown templates. Beta.
- **[loop-me](../../skills/in-progress/loop-me/SKILL.md)** — get the spec for a workflow you want to build grilled out of you first.
- **[herdr](../../skills/house/platform/herdr/SKILL.md)** _(auto)_ — drive Herdr's panes, tabs and workspaces from an agent when you are fanning work out across terminals. Requires `HERDR_ENV=1`. Beta.

## Interview and communicate

- **[grill-me](../productivity/grill-me.md)** — get interviewed until every branch of a decision is resolved. A long session usually means the scope was too big — that is itself the finding.
- **[grilling](../productivity/grilling.md)** _(auto)_ — the primitive the grill skills run on, and the one to reach for when another skill needs an interview.
- **[to-questionnaire](../productivity/to-questionnaire.md)** — a decision that needs someone else's authority becomes a questionnaire, answered async or in one meeting.
- **[wait-what](../productivity/wait-what.md)** — a message did not land. Re-pitch it in the project's own vocabulary rather than moving on.
- **[teach](../productivity/teach.md)** — a stateful workspace for taking someone (or yourself) through a concept across several sessions.

## Long sessions

- **[handoff](../productivity/handoff.md)** — compact a session into a document another agent resumes from.
- **[claude-handoff](../../skills/in-progress/claude-handoff/SKILL.md)** — the same, handed to a fresh background agent that starts immediately.

## Where to look next

- The whole set, one table with origin, domain, audience and owning team: [CATALOG.md](../../CATALOG.md)
- How the fork is organised and synced: [MAINTENANCE.md](../../MAINTENANCE.md)
- Other roles: [engineer](./engineer.md), [designer](./designer.md), [analyst](./analyst.md), [QA](./qa.md)
