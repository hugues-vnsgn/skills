## What it does

`unslop` edits a draft to remove the patterns that make writing read as machine-written, then checks that something is left behind: a claim, a number, a mechanism, an opinion. It treats the tells as symptoms rather than the disease, so cutting them is only half the job. The other half is voice, because a paragraph stripped to beige reads as machine-made just as loudly as one stuffed with `pivotal moment` and `seamless`.

It never changes what a sentence claims without telling you. That is the constraint the whole skill is built around, because an editing pass that quietly rewrites claims produces prose that reads better and says something the author never meant, and you would have no way to notice.

Quietly is the operative word. When a claim has no source, or states a result without the mechanism behind it, the skill has three moves and picks one: leave the sentence and flag it, cut it and say in the report that it cut it, or write the missing explanation and mark it in place as its own inference, like `<!-- inferred: ... Confirm or cut. -->`. The third is the one it reaches for most, because a page that explains the mechanism beats a page that flags its absence, and the marker means nothing lands under your name that you did not say.

## When to reach for it

Type `/unslop`, or the agent reaches for it automatically when a task fits.

| Situation | Reach for |
| --- | --- |
| You are about to publish prose a person reads: README, docs page, PR description, release notes, blog post, email | `/unslop`, before publishing rather than after |
| Something you or an agent wrote reads generic, corporate, or wordy and you cannot say why | `/unslop`, whose ranked tell list usually names it in the first three sections |
| The document is written for an *agent*: a `SKILL.md`, `AGENTS.md`, `CLAUDE.md`, a reference reached by a pointer | [writing-for-agents](https://aihero.dev/skills-writing-for-agents) first for the structure, then `unslop` on the prose inside it. They are layered, not alternatives |
| You have raw notes and no draft yet | [writing-fragments](https://github.com/hugues-vnsgn/skills/blob/main/skills/in-progress/writing-fragments/SKILL.md) and its two successors. `unslop` is the last pass, not the first |
| You are writing a chat reply, a one-line commit subject, or a code comment in passing | Nothing. The skill's description tells the agent to skip these, so it stops firing on every turn that contains a sentence |

## Register, and why it comes first

The skill sets the register before it edits anything, because half its own advice is wrong in the wrong place.

| Register | Covers | Voice |
| --- | --- | --- |
| Reference | README, API and config docs, changelog, spec | None. The reader wants the fact and wants to leave. |
| Argument | Blog post, essay, design doc, ADR, PR description, release notes, commit body | Opinions expected, with the reason attached. |
| Conversation | Chat reply, email, review comment, issue comment | Opinions, contractions, short sentences. |
| Instruction | A skill, `AGENTS.md`, `CLAUDE.md`, a reference an agent reads | None. Imperative throughout. |

A commit body sits in Argument rather than Reference because it argues that this was the right fix, which is an opinion the reader needs. A changelog entry only reports what moved. Argument does not mean the skill starts writing `I moved the retry policy` into your commits: what the change does stays in the imperative, because the diff already narrates the actions, and the first person is reserved for the reasoning. Inference markers are barred from a commit message for the same practical reason, since a commit body ships the moment you save it and a marker you have to remember to delete is worse than a line in the report.

Every tell applies to all four. The voice advice applies to Argument and Conversation only. Dropping `I find this approach elegant` into an API reference is its own kind of slop: the writer performing personality where the reader wanted a signature. Where the register is ambiguous the skill asks, and where it cannot ask it picks Reference, because over-neutral prose is a smaller failure than a config doc with a personality.

## The two tiers

The skill ships `scripts/check-tells.py`, which finds every tell that is pattern matching rather than judgment. Roughly a third of them are: em dashes, curly quotes, decorative emoji, a fixed vocabulary, a handful of fixed constructions. An agent hunting those by eye is slow and misses some, and every miss looks like the skill did nothing.

What comes back is split in two, and the split is the point:

- **strict** has near-zero false positives. Fix every hit.
- **candidate** is a word or shape that is usually a tell and sometimes is the project's real vocabulary. The agent decides each one.

That second tier exists because the alternative is worse. A checker that reports `harness`, `surface`, and `primitive` as strict errors will rename the things your codebase actually calls that, and cost every future reader the ability to search for them. Where a project genuinely calls the thing a harness, that *is* the concrete word.

Code is never prose to the checker: fenced blocks, inline spans, link targets, and indented blocks are masked before matching, so line and column numbers stay true while the content stays invisible. The skill applies the same rule by eye, which is why quoted material, transcripts, and changelog entries reporting someone else's words come back untouched, dashes and all. Slop inside a quotation is evidence. The quote *marks* are your document's typography rather than the source's, so those do get straightened.

The split is also why the tell list is in two files. Everything the checker matches lives in `references/tells.md` and is reprinted with its fix in the checker's own output, so `SKILL.md` carries only the tells that need a person's judgment. That keeps the part loaded on every turn down to the part a regex cannot do for you.

## Ranked, not exhaustive

The tells are ordered by how much slop each accounts for, so a pass that runs out of room has still done the valuable part. The first section is the one no regex reaches and the hardest to fix: **nothing said**. Ask what a sentence tells the reader to do or know, and cut it if the answer is neither an instruction, a fact, nor a number.

`the database stays close at hand`, `SQL you can read`, and `types that follow your schema` each name a feeling. The fixes name a mechanism: `.toSQL()` returns the exact string sent to the database; a column rename fails the build. Then the brutal version of the same test, worth applying to any paragraph you are proud of: if the sentence could appear unchanged in another project's docs, it says nothing about this one.

## Common questions

**Does it rewrite my whole document?**

No, and the report is how you check. It lists the tells it fixed, and separately anything it flagged instead of changing. The second list is where it used judgment on your behalf, which is where it is most likely to have been wrong, so read that one first. An unslopped draft is also nearly always shorter; if the word count went up, explanation got added where decoration should have been cut.

**It keeps flagging a word my project actually uses. Is the list wrong?**

Probably not, but the fix is on your side. A written style guide outranks the skill's list, and the skill is told to read one if it exists. Without a style guide, the abstract-noun tells stay candidates and get judged case by case, which means the same word can be flagged on Monday and left alone on Tuesday. Writing it down once is cheaper than arguing with a linter forever.

**Why is it model-invoked when it applies to almost everything?**

Because triggering happens per turn, not per sentence. A description claiming a skill always applies buys nothing: the agent still decides at the start of a turn whether to consult it, so the useful thing to put in a description is the list of situations that should make it look, and the list that should make it not. Both are in there. If you want the guarantee rather than the tendency, that lever is a rule in your own `CLAUDE.md` or a hook, not the skill's frontmatter.

**It wrote an explanation I never gave it. Is that not the thing it is supposed to refuse?**

It is allowed to, on one condition: the sentence has to be marked as its inference, in the document, where you will see it. The alternative was worse in practice. Told only to refuse, it produced pages that flagged a missing mechanism instead of explaining one, which is honest and thin. Told to write and mark, it produces the page you wanted with a comment you can delete in one keystroke. What stays banned is the silent version.

## It's working if

- The draft got shorter, and nothing you claimed went missing.
- The report names something it refused to change, and the refusal is a claim you could not source either.
- Your project's own vocabulary survived, including the abstract-sounding words that are the real names of things.
- A reference doc came back with no opinions in it, and an essay came back with more.
- Any explanation it supplied is marked as an inference, so you can confirm or delete it without hunting.
- Rerunning the checker on the edited file returns few strict hits, and the candidates that remain are ones you can defend.

## Where it fits

A reach-for-it-anytime standalone, and the last pass before anything is published. Its closest neighbour is [writing-for-agents](https://aihero.dev/skills-writing-for-agents), and the two are layered rather than alternatives: that one owns the structure of a document an agent reads, this one owns the prose inside it. Run the structural pass first, because it decides what text exists. For the analyst's writing chain it sits after [writing-shape](https://github.com/hugues-vnsgn/skills/blob/main/skills/in-progress/writing-shape/SKILL.md), which produces the finished draft that `unslop` then edits. For the whole map, ask [ask-matt](https://aihero.dev/skills-ask-matt).
