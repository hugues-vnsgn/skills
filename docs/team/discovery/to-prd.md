## What it does

`to-prd` turns the current conversation into a Product Requirements Document — the document that says why something is worth building, for whom, and what success looks like, in language a CEO, BA, and engineer all read the same way. It synthesises first and interviews last: every section it can defend from what was already discussed gets drafted without asking, and only the decisions no agent can make for you — Key Result targets, contacts, the first-version cut — earn one batched round of questions. A decision you defer survives into the document as a visible `⚠ TBD — <who decides>` marker rather than being quietly invented.

The PRD lands as `PRD-<name>.md` in the repo (wherever the project keeps product documents, `docs/product/` otherwise), with a tracker issue linking to it — deliberately *not* labelled ready-for-agent, because a PRD is the anchor specs reference, not implementable work.

## When to reach for it

You invoke this by typing `/to-prd` — the agent won't reach for it on its own.

| Situation | Reach for |
| --- | --- |
| An initiative has been grilled and the why/for-whom needs its own document before anyone specs | `/to-prd` |
| The conversation is settled and you want *buildable* work on the tracker | [to-spec](https://aihero.dev/skills-to-spec) — the what/how/tests, downstream of the PRD |
| The idea is still two sentences of "maybe we should…" | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) first — `to-prd` will refuse an unripe idea and send you there anyway |
| A single well-scoped feature | Skip the PRD; go straight to [to-spec](https://aihero.dev/skills-to-spec) |

## Prerequisites

Publishing the tracker link assumes an issue tracker is configured — run [setup-osxsystem-skills](../platform/setup-osxsystem-skills.md) once per repo if it isn't. The PRD file itself is written regardless. A project glossary (`CONTEXT.md`) isn't required, but the PRD is markedly better with one: the skill writes in the glossary's vocabulary and calls `domain-modeling` when it hits a term the glossary doesn't pin down.

## Ripeness, and why the skill refuses

The failure mode of every PRD generator is the confident document built on nothing — invented OKR numbers, a market segment nobody named, a solution section describing a vibe. `to-prd` treats that as the thing to prevent: facts are the agent's job, decisions are yours, and a section that is neither gets flagged, not filled. When *most* sections would be gaps, the idea isn't ripe, and the skill declines to write the document at all — interviewing eight sections into existence produces a transcript of guesses wearing a PRD's clothes. It routes you to [grill-with-docs](https://aihero.dev/skills-grill-with-docs) and tells you why, section by section.

## Common questions

**How is a PRD different from the spec `to-spec` writes?**

The PRD is upstream and audience-broader: why this is worth building, for whom, and how success is measured — the document a non-engineer signs off on. The spec is what to build, on which seams, and how it's tested. One PRD typically anchors several specs, and each spec references it. If your PRD is growing user stories, or your spec is restating market context, the boundary has slipped.

**Why doesn't `grill-with-docs` hand off to `to-prd` automatically?**

Because what follows a grilling is a branch, not a line: a small feature goes straight to `to-spec`, a design question detours through `prototype`, a too-big effort goes to `wayfinder`, and only initiative-scale work wants a PRD. Forward routing lives in one place — [ask-matt](https://aihero.dev/skills-ask-matt) — so no single successor gets hard-wired into the grilling. Writing the PRD is a decision you make, which is also why the skill is user-invoked.

**When should I skip the PRD entirely?**

When the work is one feature with an obvious owner and no audience beyond the team building it. The PRD earns its keep at initiative scale — multi-spec efforts, anything a stakeholder outside engineering needs to read and react to. PRD-ing everything is over-process; the tell is documents nobody reads.

## It's working if

- Every number in the document traces to something someone actually said — targets you never gave appear as `⚠ TBD`, not as plausible figures.
- It didn't re-ask anything the conversation already answered.
- The Assumptions section contains at least one thing you *didn't* say — a belief the draft surfaced that the team can now validate or kill.
- Thin ideas get refused with a route to `/grill-with-docs`, not a hollow template.
- The PRD reads in your project's vocabulary, and your BA could sign it without edits.

## Where it fits

A chain step: `grill-with-docs → domain-modeling → to-prd → to-spec → to-tickets → implement → code-review` — the stop between sharpened thinking and buildable work, for work big enough to deserve it. Its closest neighbours are [grill-with-docs](https://aihero.dev/skills-grill-with-docs), because an unripe idea gets sent back there, and [to-spec](https://aihero.dev/skills-to-spec), because every spec that grows out of the initiative should reference the PRD. For the whole map, ask [ask-matt](https://aihero.dev/skills-ask-matt).
