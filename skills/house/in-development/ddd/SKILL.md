---
name: ddd
description: Run a domain-driven design session end to end. Crunch the knowledge the code and documents already hold, converse in rounds of Discovery Tree questions to settle what they cannot tell you, then return the documents and diagrams that carry the result, including a bounded-context map, an aggregate model, the domain events, and a ubiquitous language glossary. Use when the user wants to model or remodel a domain, carve a monolith or a service into bounded contexts, decide what an aggregate owns and where its consistency boundary sits, find the domain events behind a workflow, reconcile vocabulary that two teams or two services use differently, or reaches for DDD, event storming, or strategic design by name.
metadata:
  author: osxsystem
  internal: true
---

Three movements, in order: **crunch** the knowledge that already exists, **converse** to settle what it cannot tell you, and **return** documents and diagrams that carry the result.

The order is a ratchet, and each movement feeds the next. Crunching without conversing maps yesterday's misunderstandings. Conversing without crunching spends the user's attention on facts sitting in their own project. Returning documents before either produces a confident diagram that is wrong, which is worse than no diagram: a model that looks settled stops getting checked.

## When another skill fits better

This skill runs a *session*: several rounds of questions, then a set of artifacts. That shape is too heavy for small work.

- One term to pin down, one ADR to record, a glossary to keep current while you build something else: call the Skill tool with "domain-modeling". It owns `CONTEXT.md` and `docs/adr/`, and this skill hands its output there rather than inventing a second format.
- A plan or a decision to stress-test with no domain model in it: call the Skill tool with "grilling". Same round-and-frontier machinery, without the domain branches.
- One picture of something already understood: call the Skill tool with "show-me".

## How far to run

Two shapes, and the user picks at the start rather than discovering the cost in round four.

**Strategic pass**: `subdomains`, `contexts`, `integration`. Two rounds, returning a context map and a coverage note. The right size for "where do the boundaries go" when nobody is modelling anything yet. `integration` names each pattern from what crosses the boundary today rather than from settled events, and the coverage note says so, because that is a weaker claim than the full pass makes. On this pass `integration` reaches the frontier when `contexts` settles, since `events` never opens.

**Full pass**: every branch, six rounds or more, returning a model.

Say which one you are running, and what it costs, before the first round goes out. Someone who wanted a boundary sketch and got six rounds of aggregate questions did not get a better answer, they got a longer one.

## 1. Crunching Knowledge

### Brainstorming and experimenting

Talk through scenarios in the model's own terms, because the ear catches an awkward model faster than a diagram does: a sentence that will not say cleanly is a model asking to change. The raw material is everything the project already holds, the domain experts, the users of the current system, the documents written for the business, and the legacy code itself.

**Crunch the running system first.** Where a legacy system exists, it is raw material of exactly the kind described above, and it is the only source that never tires: its table names, class names, endpoints, and enum values are all somebody's earlier answer to the questions you are about to ask. Read it before asking the user for anything, using whatever search and file-reading tools this environment provides.

**Bound the crunch before you run it.** On a repo too large to read, name the modules the user's question actually touches, say which you are leaving out, and crunch those. The `Known` list is bounded by what crosses a module boundary, which bounds the terms but not the reading, and a crunch that quietly runs out of room produces a confidently short `Fractured` list. A short `Fractured` list under-seeds every branch below it. A stated exclusion is recoverable; a silent truncation is not.

**Where there is no system yet**, the raw material is the user's own account of the business plus whatever documents exist, so this movement inverts: the first round listens rather than reports. Ask for one workflow end to end, in their words, and crunch that. The fractures are there too, in the same word used two ways inside one paragraph, and they seed the tree exactly as a table name would. An empty crunch report is not permission to fall back on a generic checklist, which is the one thing this session is built not to be.

| Source | What it yields |
| --- | --- |
| existing glossaries, context maps, decision records | terms and boundaries already settled, and the reasons |
| schema and migrations | entities, identity, and which fields are genuinely required |
| module and package layout | where somebody already drew a boundary |
| API contracts, event payloads, queue and topic names | the language that crosses process lines |
| enums, status fields, state machines | the lifecycle the domain thinks in |
| test names | behaviour the team believed was worth pinning down |

Then write the **crunch report**, short, before any question reaches the user:

- **Known**: every term that crosses a module boundary, and what the code says it means, each with a `path:line` so the user can check you. A term living inside one module is not the session's problem yet, and listing all of them buries the few that are.
- **Fractured**: one concept wearing two names (`Order` and `Purchase` on the same table), or one name carrying two concepts (`Account` as the login and as the money).
- **Unknown**: what the code cannot tell you. Intent, policy, and what the business does when a rule is violated.

**Where the crunch and the user disagree**, that is a `language` question rather than a fact for you to settle. The user is the authority on what a term means, and the code is the evidence of what it currently does, so put both: "the schema treats `Account` as the login (`db/schema.sql:3`), and you are using it for the money. Which keeps the word?" Quietly preferring either source throws away the more interesting half of the finding.

### Ubiquitous Language

Cultivate one language where the experts' jargon and the team's design vocabulary intersect, and speak it in every scenario you describe: a project whose experts and builders talk past each other is modelling two different domains.

**Every fracture is a boundary trying to surface.** A word that means two things usually means the two meanings belong on opposite sides of a line nobody has drawn yet, so the **Fractured** list is the highest-value finding of this movement. Together with **Unknown**, it seeds the tree: root questions are derived from what this project actually contradicts, rather than picked off a generic checklist, and that is what keeps the next movement about this domain instead of about DDD.

## 2. Conversation with the user, or an agent instance

After the first step of **Brainstorming and experimenting**, design a series of questions. ***Discovery Tree Questions*** enable the Agent to proactively explore edge cases, primary data flows, and system constraints with the user.

Format the ***Discovery Questions*** as below:

```
⁉️ **Q3.2** - `<branch>` - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

💡 <your recommended answer>
↩️ <the one fact that would change it>

---

⁉️ **Q3.3** - `<branch>` - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

💡 <your recommended answer>
↩️ <the one fact that would change it>
```

The `↩️` line carries the one fact that would change the recommendation, and it is in the template rather than beside it because it is the first thing to fall out of a wide round. It gives the user the cheapest possible reply when you guessed wrong: a correction rather than an essay. Where a recommendation genuinely could not go the other way, say why in one clause instead of leaving the line blank.

Number questions `Q<round>.<n>`, where the round count goes up each time a batch goes out and `n` runs across the whole round rather than restarting per branch, so a late answer can still be attributed after the round has moved on. The branch slot gives a reply like "park language, the rest look right" something to bind to.

### Rounds and the frontier

The **frontier** is every question whose prerequisites are already settled: the ones askable now without guessing at answers you have not heard yet. Ask the whole frontier in one round, then wait.

Each round, the user's answers reshape the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a later round, not this one.

### The branches

Domain questions depend on each other in a fixed order, so this tree has known branches rather than an ad-hoc shape. A branch reaches the frontier once the branches it depends on are settled.

| Branch | Asks | Depends on |
| --- | --- | --- |
| `subdomains` | what is core, what is supporting, what is generic and buyable | nothing |
| `contexts` | where the boundaries fall, and what each side owns | `subdomains` |
| `language` | inside each context, what a term means and what it excludes | `contexts` |
| `aggregates` | what has to be consistent together, what may lag, which of these has identity and which is a value, and what must hold at every commit | `language` |
| `events` | what the domain announces, what reacts to each announcement, and whether the reaction is a policy someone owns | `aggregates` |
| `integration` | how each pair of contexts talks, and who bends to whom | `contexts`; plus `events` on a full pass |

The dependencies are real rather than bureaucratic. A term means one thing in Billing and another in Fulfilment, so `language` cannot resolve until `contexts` says which side you are standing on. An aggregate is a consistency boundary drawn around named things, so it needs the names first. Ask out of order and you collect answers about a `Payment` before anyone has agreed which context owns it, and every answer below inherits that.

Below `contexts` the branches fork per context, and that is where a round gets its width. `language` for Billing and `language` for Ledger are separate nodes that settle independently, and Billing's `aggregates` waits only on Billing's `language`. Where a round spans more than one branch, order the questions by branch: the label in each question carries the grouping, so the user can still park a whole branch in one sentence.

A subdomain class is a budget rather than a label. **Core** earns the full tree: its own `language` fork, its own `aggregates`, its own events. **Supporting** earns the tree but not the argument, so take your own recommendation where the user has no opinion. **Generic** earns one question, who supplies it and what its ACL translates, and no fork below `contexts` at all. Classifying Tax as generic and then modelling its aggregates spends the session's scarcest resource, the user's attention, on the part of the domain nobody wins by understanding.

This is also what keeps a round answerable. The fork is only as wide as the classes allow: four contexts where one is generic is three forks, not four. Where the frontier still runs past eight questions, ask the eight that unblock the most branches, hold the rest, and let the ledger show how many are held. A round the user abandons settles nothing.

Seed each branch from the crunch report: a fracture is a `contexts` question, a term the code uses two ways is a `language` question, a transaction spanning four tables is an `aggregates` question.

### The ledger

Open every round with the tree's state, so the user can see what is settled and redirect you before you spend a round on a branch they do not care about. A session resumed after an interruption starts the same way: reprint the ledger before anything else, since it is the only state the conversation carries.

| Branch | State | Seeded | Answered |
| --- | --- | --- | --- |
| `subdomains` | settled | 2 | 2 |
| `contexts` | frontier | 5 | 3 |
| `language` | blocked on `contexts` | 4 | 0 |
| `aggregates` | blocked on `language` | 2 | 0 |
| `events` | blocked on `aggregates`, probing queue topology | 1 | 0 |
| `integration` | parked, at the user's call | 0 | 0 |

The states: `frontier` (askable now), `blocked on <branch>` (a prerequisite is unsettled), `settled`, `reopened` (a settled branch that a later answer invalidated), and `parked` (the user chose to skip it, and it stays on the ledger so the model can say what it does not cover). `probing` rides alongside rather than replacing them, because a probe dispatched now usually feeds a branch that opens several rounds later.

A later answer that invalidates a settled branch reopens it **once**: restate the checkpoint it voids, mark every branch beneath it `blocked` on it again, and carry the discarded decisions into the coverage note so a reader can see what changed and why. A fracture found below `contexts` is the common case, but the rule holds anywhere in the tree. A second reopen of the same branch means the question is genuinely unsettled rather than mis-answered, so say that plainly and park it. Reopening is what keeps the ratchet honest, since an answer surfacing late is the whole reason the second movement exists, and bounding it at one per branch is what keeps the session finite.

**Seeded** counts the questions derived for that branch so far, and it grows as answers land. A blocked branch showing zero is unwritten rather than empty: what to ask about aggregates is not knowable until the language is settled, so promising a total up front would be a guess dressed as a plan.

**Answered** counts the seeded questions the user has actually settled. The two numbers together are what let a branch be partly done: `frontier` at 3 of 5 is a real state, and the next round re-asks the two still open rather than the whole branch.

Read a reply against the questions you asked rather than for a shape. Someone who answers Q3.2 and Q3.4 and ignores the rest has answered two, so the count moves by two and the others stay open. Someone who answers in prose has still settled whatever the prose settles: say back which questions you took as answered, because a misattributed answer propagates down the whole subtree beneath it. An answer to something you never asked is still a fact worth keeping, so file it against the branch it belongs to and re-derive that branch's seeds.

Parking a branch does not strand the branches beneath it. Settle each dependent on your own recommendation, mark it `settled (inferred)`, and carry every one of those into the coverage note. The session still lands a model, and the reader can see exactly which parts of it nobody agreed to.

### Facts are yours, decisions are theirs

Finding facts is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The decisions are the user's: put each to them and wait.

Where this environment has no sub-agent to dispatch, run the lookup yourself before the round goes out. The rule is about who carries the burden, not about which tool carries it.

A returning probe reports the fact and where it found it (`path:line`, or the command it ran), so checking the probe costs the user no more than checking you. Intent, policy, priority, and what the business wants when a rule breaks are the decisions: they are not discoverable, and guessing one to keep a round moving is how a model ends up describing the code instead of the domain.

### Checkpoints

A branch reaches its checkpoint at the end of the round in which `Answered` reaches `Seeded` and no new seed lands. Stop and restate it, then get a yes before the branches below it open.

Checkpoints ride in the next round's preamble, under the ledger, while other branches are still open. The round is the unit of the user's attention, and splitting it into one confirmation per context spends six turns to save none. Only when a checkpoint is the last thing outstanding, with nothing else on the frontier, does it become its own turn and wait. Either way the branches below it stay `blocked` until the yes lands.

```
✅ **Checkpoint** · `<branch>`
- <one decision, in the user's own words where they gave you words>
- <one decision>
→ Confirm, or correct any line. `<dependent branches>` open on your yes.
```

The tree compounds, so this is not ceremony. Every `aggregates` answer stands on a `language` answer, which stands on a `contexts` answer. A boundary the user never actually agreed to costs one confirmation to catch here and a whole subtree to unwind later.

The session is done when the frontier is empty: every branch settled or parked, nothing left silently assumed.

## 3. Return Documents and Diagrams

### Informal UML diagrams can anchor a discussion

Sketch three to five objects central to the issue at hand, and redraw as the discussion moves: a sketch that changes mid-conversation is part of the talking rather than a record of it. What it pins is what the discussion needs pinned, the names and the relationships between them.

### Written Design Documents

Written documents complement code and speech rather than repeating either. Running code already specifies behaviour precisely, so a document that restates it has no reader: write the intent, the large-scale structure, and the domain meaning the programming language cannot express.

Document a small chosen subset rather than the system, because a document covering everything goes stale everywhere at once. Pair each diagram with prose, since the diagram carries the structural choice and only the text can say what was simplified away. Keep a sketch in conversation casual, because its roughness tells the reader the model is still moving.

Selective modelling is what decides the set below.

### Which documents this session owes

Selective modelling, above, decides the set: produce the artifact for every branch that settled, and where a branch was parked, name the gap where its artifact would have gone.

| Settled branch | Artifact |
| --- | --- |
| `contexts` | context map, its edges labelled once `integration` settles too |
| `language` | ubiquitous language glossary |
| `aggregates` | model diagram |
| `events` | event table, plus a flow diagram once three or more contexts take part |

[ARTIFACTS.md](./ARTIFACTS.md) carries the notation for each and a worked example. Read the section for every artifact you owe before writing it. Casual and informal is right for a sketch in conversation; a returned artifact is read by people who were not in the room, so a fixed shape is what lets two sessions on the same project be compared at all.

Close with a coverage note saying what the model covers and what it deliberately does not. A model is a choice about what to leave out, and the second half is what stops a reader assuming the diagram is the whole system.

### Persist it

The artifacts are this session's output; a project's glossary and decision records are its memory. Call the Skill tool with "domain-modeling" to land them there. The glossary in [ARTIFACTS.md](./ARTIFACTS.md) is already written in that skill's `CONTEXT.md` shape, so it copies across rather than needing a translation.

Offer an ADR only for a decision that is hard to reverse, surprising without its context, and the result of a real trade-off. A context boundary usually qualifies. A term almost never does.

## Definitions

**Domain**: A sphere of knowledge, influence, or activity.

**Model**: A system of abstractions that describes selected aspects of a **domain** and can be used to solve problems related to that **domain**.

## Guardrails

- **Mark what you inferred.** A glossary entry no expert confirmed and no code supports reads exactly like one that was, and the reader has no way to tell them apart. Say so in the entry, or take it back to the user as a question.
- **An invariant is elicited, not composed.** If you reach the model diagram without having asked what must hold at every commit, that is an open `aggregates` question rather than a note for you to write. The invariant is the reason the boundary exists, so inventing one invents the boundary.
- **Draw only what the tree settled.** An artifact covering an open branch renders guesses in the same notation as decisions. Park the branch and name the gap instead.
- **Keep every artifact in the glossary's language.** When a diagram needs a word the glossary does not have, you have found a missing term rather than a labelling problem: take it back to the `language` branch.
