---
name: ddd
description: Run a domain-driven design session on an idea or an existing repo, and return a context map and glossary, plus aggregates and events if you go deep.
disable-model-invocation: true
metadata:
  author: osxsystem
---

**Crunch** what the project knows, **converse** to settle what it cannot tell you, then **return** the artifacts.

Speak the model out loud, walking each scenario in its own terms. The ear catches an awkward model before a diagram does: a sentence that will not say cleanly is a model asking to change.

## 1. Crunch

Pick the entry from what exists:

- **Redesign**, where a repo exists: read it before asking anything. If it is too large to read, name the modules you crunch and the ones you leave out.
- **Idea**, before any code: ask for one workflow end to end, in the user's words, and crunch that reply.

Then write a short **crunch report** before the first question, every line carrying its evidence: a `path:line` on a redesign, the user's quoted words on an idea.

- **Known**: each term that crosses a module boundary (for an idea, each noun the workflow leans on) and what it means.
- **Fractured**: one concept wearing two names (`Order` and `Purchase` on one table), or one name carrying two concepts (`Account` as the login and as the money). A fracture is a boundary trying to surface: this list is worth the most.
- **Implicit**: a rule the code enforces or the user assumes without ever naming it: a hard-coded 10% overbooking margin, "a refund always goes back to the same card".
- **Unknown**: what no source can tell you: intent, policy, and what the business does when a rule breaks.

A redesign also draws the **today** context map from the code here, facts only.

Where the code and the user disagree about a term, put both to the user and ask which keeps the word: the user owns meaning, and the code is evidence of what the system does now.

## 2. Converse

Work the branches in **rounds**. The **frontier** is every question whose prerequisites are settled: ask the whole frontier in one round, then wait. A question that depends on one still open this round belongs to a later round.

### The branches

| Branch | Asks | Depends on |
| --- | --- | --- |
| `subdomains` | what the session is for, then what is core, supporting, generic | nothing |
| `contexts` | where the boundaries fall, what each side owns | `subdomains` |
| `language` | inside each context, what a term means and excludes | `contexts` |
| `integration` | how each pair of contexts talks, who bends to whom | `contexts` |
| `aggregates` | what stays consistent together, entity or value, the invariant held at every commit | `language` |
| `events` | what the domain announces, what reacts, who owns that policy | `aggregates` |

Seed every branch from the crunch report: a fracture becomes a `contexts` or `language` question, an implicit rule an invariant candidate for `aggregates`.

Below `contexts`, each context forks its own `language` and `aggregates`, and its subdomain class sets the budget. **Core** gets the full fork and the full argument. **Supporting** gets the fork, but take your own recommendation where the user has no opinion. **Generic** gets one question: who supplies it, and what its ACL translates. Cap a round at eight questions, the ones that unblock most.

### A round of Discovery Questions

Every round takes this shape:

```
subdomains ✅ · contexts ⏳ · language 🔒 · integration 🔒

✅ **Checkpoint** · `subdomains`
- <one decision, in the user's own words where they gave you words>
- <one decision>
→ Correct any line, or carry on.

⁉️ **Q2.1** - `<branch>` · <context, on a fork> - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

💡 <your recommended answer>
↩️ <the one fact that would change it>

---

⁉️ **Q2.2** - `<branch>` - ...
```

- **Strip**: `✅` settled, `⏳` on the frontier, `🔒` waiting on a prerequisite, `⏸️` parked, plus `(n held)` for questions the cap pushed back. It is the session's only state, so a resumed session reprints it first.
- **Numbers**: `Q<round>.<n>`, with `n` running across the whole round, so a late answer still binds to its question.
- **`💡`**: where it rests on a business fact only the user holds, flag it as a guess to check.
- **`↩️`**: where the recommendation genuinely cannot flip, say why in one clause.
- **Checkpoint**: a branch reaches it when every question seeded for it is answered and no new one has appeared. Its dependents open in the same round.

Read each reply against the questions you asked: say back which you took as answered, keep the rest on the frontier, and file an unasked-for answer under its branch. When a correction or a late answer breaks a settled branch, reopen it and re-ask whatever stood on the decisions it voids.

The user can park a branch in one line. Settle whatever depends on it on your own recommendation, listed as inferred in the Coverage note.

When a round argues about how a few things relate, sketch three to five of them and redraw as answers land.

### Facts are yours, decisions are theirs

Look up every fact yourself, through a sub-agent where one exists, and ask the rest of the frontier meanwhile: only the questions downstream of a lookup wait, and each lookup reports its `path:line` or command. Intent, policy, and priority are the user's decisions: put each one to them, because a guessed decision turns the model into a description of the code.

### The stop question

Close round 3 with one more question, `stop` in its branch slot: once `language` and `integration` settle, stop with the context map and glossary, or go deep into `aggregates` and `events`? Recommend deep where a core context still carries an Implicit rule or an Unknown about consistency. On a stop, the return opens with the checkpoints still owed.

The conversation is done when the frontier is empty: every branch settled, parked, or cut at the stop question.

## 3. Return

Produce one artifact per settled branch, in the notation [ARTIFACTS.md](./ARTIFACTS.md) fixes. Read the section for each artifact you owe before writing it.

| Settled branch | Artifact |
| --- | --- |
| `contexts` | target context map, beside the today map on a redesign |
| `integration` | pattern labels on the map's edges |
| `language` | ubiquitous language glossary |
| `aggregates` | model diagram per aggregate cluster |
| `events` | event table, plus a sequence diagram once three or more contexts take part |

Close with the Coverage note.

Then call the Skill tool with "domain-modeling" to land the glossary in the project's `CONTEXT.md`, and any ADR the session earned.

## Guardrails

- **Mark what you inferred.** An entry nobody confirmed and no code supports says so in the Coverage note, or goes back to the user as a question.
- **Elicit every invariant.** Each aggregate root's invariant comes from the user's answer to "what must hold at every commit". The invariant is the reason the boundary exists, so a composed one invents the boundary.
- **Speak the glossary.** When an artifact needs a word the glossary lacks, take it back to `language` as a missing term.
