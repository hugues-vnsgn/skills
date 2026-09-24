## What it does

`ddd` runs a domain-driven design session end to end: it works out where the boundaries in a domain fall and what each word means inside them, then writes that down. It reads before it asks. On an existing repo it reads the code first; on an idea it asks for one workflow in your own words and reads that. So every question it puts to you comes from a contradiction it found, not from a generic DDD checklist.

What comes back is a context map (on a redesign, today's map beside the target), a ubiquitous language glossary handed to `domain-modeling` for the project's `CONTEXT.md`, and a Coverage note saying what the model settles, what it parks, and what it guessed. Going deep adds a model diagram per aggregate and an event table.

## When to reach for it

You invoke this by typing `/ddd`, and the agent won't reach for it on its own.

| Situation | Reach for |
| --- | --- |
| A codebase whose boundaries or vocabulary need redrawing | `/ddd`, the redesign entry |
| A product idea with no code yet, where the words and boundaries are still loose | `/ddd`, the idea entry |
| One term to pin down, or one decision to record | [domain-modeling](https://aihero.dev/skills-domain-modeling) |
| A plan to stress-test with no domain model in it | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| The model is settled and the *why* needs a document | [to-prd](./to-prd.md) |

## Prerequisites

None to start. At the end the glossary goes to `domain-modeling`, which writes it into the project's `CONTEXT.md`, or into one `CONTEXT.md` per context where a `CONTEXT-MAP.md` exists, so run it from the directory where that file should live.

## The crunch report

Before the first question, the session writes a short report in four lists, each line carrying its evidence (a `path:line`, or your quoted words):

- **Known**: the terms that cross a boundary, and what they mean now.
- **Fractured**: one concept wearing two names, or one name carrying two concepts. A fracture is a boundary trying to surface, so this is the list worth the most.
- **Implicit**: a rule the code enforces or you assume without ever naming it. Naming it is how a hidden concept joins the model.
- **Unknown**: what no source can tell it: intent, policy, and what the business does when a rule breaks.

## The short path and the stop question

The conversation runs in rounds, each a batch of numbered questions with a recommendation and the one fact that would flip it, so most answers are a single line. Facts are its job: anything it can look up, it looks up, through a [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) where the [harness](https://www.aihero.dev/ai-coding-dictionary/harness) has one, and only decisions reach you.

| Round | Settles |
| --- | --- |
| 1 | what the session is for, and which subdomain is core, supporting, or generic |
| 2 | the bounded contexts and what each owns |
| 3 | each context's language, how the contexts integrate, and the **stop question** |
| deep | aggregates and their invariants, then domain events |

The stop question asks whether to return now with the map and glossary or go deep. It recommends going deep only where the core still hides a consistency rule. The short path costs about three replies on a repo and four on an idea, where the first reply is your workflow.

## Common questions

**Does it build the thing?**

No. It ends with a map, a glossary, and a Coverage note. Building is the main flow's job, starting from [to-prd](./to-prd.md) or [to-spec](https://aihero.dev/skills-to-spec).

**How much does a session cost?**

The reading is the expensive part. A redesign reads the modules in scope before the first question, so name the ones that matter and the ones to leave out; an idea costs almost nothing to crunch. After that it's a few short rounds, and going deep adds about two more.

**Can I just accept every recommendation?**

The session will finish, but on a domain the agent is guessing at, the model becomes the agent's rather than yours. Read the questions it marks as a guess: in testing, the one answer that changed the model came on a question marked that way.

## It's working if

- The first questions quote your code or your own words back at you.
- The Fractured list names a word your team uses two ways that nobody had noticed.
- Most of your replies fit on one line: "a", "take the three", "stop".
- The glossary's _Avoid_ lines are words you actually hear in meetings.
- The Coverage note lists what was inferred and what was cut, so nothing reads as agreed that you never agreed.

## Where it fits

A reach-for-it-anytime standalone at the front of discovery, whose output feeds the main flow: `ddd → to-prd → to-spec → to-tickets → implement`. Its closest neighbours are [domain-modeling](https://aihero.dev/skills-domain-modeling), because it lands the glossary and is the tool for a single term, and [grill-with-docs](https://aihero.dev/skills-grill-with-docs), the lighter interview when there is no model to build. For the whole map, ask [ask-matt](https://aihero.dev/skills-ask-matt).
