## What it does

`unslop` edits a draft to remove the patterns that make writing read as machine-written, then checks that something is left behind: a claim, a number, a mechanism, an opinion. It treats the tells as symptoms rather than the disease, so cutting them is only half the job. The other half is voice, because a paragraph stripped to beige reads as machine-made just as loudly as one stuffed with `pivotal moment` and `seamless`.

It refuses to change what a sentence claims. Where the only way to remove a tell would be to alter, soften, or drop a fact, the sentence stays and the problem is reported to you instead. That is the constraint the whole skill is built around: an editing pass that quietly rewrites claims produces prose that reads better and says something the author never meant, and you would have no way to notice.

## When to reach for it

Type `/unslop`, or the agent reaches for it automatically when a task fits.

| Situation | Reach for |
| --- | --- |
| You are about to publish prose a person reads: README, docs page, PR description, release notes, blog post, email | `/unslop`, before publishing rather than after |
| Something you or an agent wrote reads generic, corporate, or wordy and you cannot say why | `/unslop`, whose ranked tell list usually names it in the first three sections |
| The document is written for an *agent*: a `SKILL.md`, `AGENTS.md`, `CLAUDE.md`, a reference reached by a pointer | [writing-for-agents](https://aihero.dev/skills-writing-for-agents) first, because the reader is different, and `unslop` second on its prose |
| You have raw notes and no draft yet | [writing-fragments](https://github.com/hugues-vnsgn/skills/blob/main/skills/in-progress/writing-fragments/SKILL.md) and its two successors. `unslop` is the last pass, not the first |

## Register, and why it comes first

The skill sets the register before it edits anything, because half its own advice is wrong in the wrong place.

| Register | Covers | Voice |
| --- | --- | --- |
| Reference | README, API and config docs, changelog, commit body, spec | None. The reader wants the fact and wants to leave. |
| Argument | Blog post, essay, design doc, ADR, PR description, release notes | Opinions expected, with the reason attached. |
| Conversation | Chat reply, email, review comment, issue comment | Opinions, contractions, short sentences. |

Every tell applies to all three. The voice advice applies to the last two only. Dropping `I find this approach elegant` into an API reference is its own kind of slop: the writer performing personality where the reader wanted a signature. Where the register is ambiguous the skill asks, and where it cannot ask it picks Reference, because over-neutral prose is a smaller failure than a config doc with a personality.

## The two tiers

The skill ships `scripts/check-tells.py`, which finds every tell that is pattern matching rather than judgment. Roughly a third of them are: em dashes, curly quotes, decorative emoji, a fixed vocabulary, a handful of fixed constructions. An agent hunting those by eye is slow and misses some, and every miss looks like the skill did nothing.

What comes back is split in two, and the split is the point:

- **strict** has near-zero false positives. Fix every hit.
- **candidate** is a word or shape that is usually a tell and sometimes is the project's real vocabulary. The agent decides each one.

That second tier exists because the alternative is worse. A checker that reports `harness`, `surface`, and `primitive` as strict errors will rename the things your codebase actually calls that, and cost every future reader the ability to search for them. Where a project genuinely calls the thing a harness, that *is* the concrete word.

Code is never prose to the checker: fenced blocks, inline spans, link targets, and indented blocks are masked before matching, so line and column numbers stay true while the content stays invisible. The skill applies the same rule by eye, which is why quoted material, transcripts, and changelog entries reporting someone else's words come back untouched. Slop inside a quotation is evidence.

## Ranked, not exhaustive

The tells are ordered by how much slop each accounts for, so a pass that runs out of room has still done the valuable part. The first section is the one no regex reaches and the hardest to fix: **nothing said**. Ask what a sentence tells the reader to do or know, and cut it if the answer is neither an instruction, a fact, nor a number.

`the database stays close at hand`, `SQL you can read`, and `types that follow your schema` each name a feeling. The fixes name a mechanism: `.toSQL()` returns the exact string sent to the database; a column rename fails the build. Then the brutal version of the same test, worth applying to any paragraph you are proud of: if the sentence could appear unchanged in another project's docs, it says nothing about this one.

## Common questions

**Does it rewrite my whole document?**

No, and the report is how you check. It lists the tells it fixed, and separately anything it flagged instead of changing. The second list is where it used judgment on your behalf, which is where it is most likely to have been wrong, so read that one first. An unslopped draft is also nearly always shorter; if the word count went up, explanation got added where decoration should have been cut.

**It keeps flagging a word my project actually uses. Is the list wrong?**

Probably not, but the fix is on your side. A written style guide outranks the skill's list, and the skill is told to read one if it exists. Without a style guide, the abstract-noun tells stay candidates and get judged case by case, which means the same word can be flagged on Monday and left alone on Tuesday. Writing it down once is cheaper than arguing with a linter forever.

**Why is it model-invoked when it applies to almost everything?**

Because triggering happens per turn, not per sentence. A description claiming a skill always applies buys nothing: the agent still decides at the start of a turn whether to consult it, so the useful thing to put in a description is the list of situations that should make it look. If you want the guarantee rather than the tendency, that lever is a rule in your own `CLAUDE.md` or a hook, not the skill's frontmatter.

## It's working if

- The draft got shorter, and nothing you claimed went missing.
- The report names something it refused to change, and the refusal is a claim you could not source either.
- Your project's own vocabulary survived, including the abstract-sounding words that are the real names of things.
- A reference doc came back with no opinions in it, and an essay came back with more.
- Rerunning the checker on the edited file returns few strict hits, and the candidates that remain are ones you can defend.

## Where it fits

A reach-for-it-anytime standalone, and the last pass before anything is published. Its closest neighbour is [writing-for-agents](https://aihero.dev/skills-writing-for-agents), because the two split on who reads the document and applying the wrong one costs you either the human's ear or the agent's predictability. For the analyst's writing chain it sits after [writing-shape](https://github.com/hugues-vnsgn/skills/blob/main/skills/in-progress/writing-shape/SKILL.md), which produces the finished draft that `unslop` then edits. For the whole map, ask [ask-matt](https://aihero.dev/skills-ask-matt).
