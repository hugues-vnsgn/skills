---
name: unslop
description: Strip AI tells from human-facing prose and give it a voice. Use whenever you write or edit text a person will read, including a README, docs page, PR description, release notes, changelog entry, commit body, blog post, email, or issue comment. Also use when text is called slop, AI-sounding, generic, corporate, or wordy, or when someone asks to make writing sound human. Reach for it before publishing prose, not after.
---

# Unslop

Slop is writing that could have come from anywhere, about anything. The tells below are symptoms. The condition is prose carrying no information and no person, and a draft can be free of every tell on this list and still have it.

So this is two jobs, not one. Cut the tells, then check that something is left: a claim, a number, a mechanism, an opinion. A sterile paragraph reads as machine-made just as loudly as a florid one, which is why deleting adjectives until the text is beige is a failure and not a fix.

## Process

1. **Read the whole thing first.** Slop is often structural: a doc shaped like every other doc, three sections restating one idea at three lengths, a summary of a page the reader just read. A sentence-level pass never sees that.
2. **Set the register.** It decides which of the rules below apply. See [Register](#register).
3. **Run the checker.** From this skill's folder, `python3 scripts/check-tells.py PATH` reports every tell that is pattern matching rather than judgment, with line numbers and the fix. Let it find the em dashes and the curly quotes so your attention goes where a regex cannot follow.
4. **Fix the strict hits, judge the candidates.** Strict hits are tells with near-zero false positives. A candidate is a word or shape that is usually a tell, and sometimes is the project's real vocabulary, where swapping it makes the prose worse. Deciding that is your job, not the script's.
5. **Work the judgment tells** below, in order. They are ranked by how much slop they account for, so a pass that runs out of time has still done the valuable part.
6. **Add voice**, if the register allows it. See [Voice](#voice).
7. **Self-audit.** Ask "what here still reads as AI-generated?" and fix what the answer names. Then re-run the checker and compare word counts. An unslopped draft is nearly always shorter; if it grew, you probably added explanation where you should have cut decoration.
8. **Report what you did.** List the tells you fixed, and separately, anything you flagged instead of changing. The author needs to see where you used judgment on their behalf, because that is where you are most likely to have been wrong.

## Register

Three registers, and the difference matters because the voice advice below is actively wrong for the first one.

| Register | Covers | Voice |
|---|---|---|
| Reference | README, API and config docs, changelog, commit body, spec | No first person, no opinions. The reader wants the fact and wants to leave. |
| Argument | Blog post, essay, design doc, ADR, PR description, release notes | Opinions expected. Say what you think and why you think it. |
| Conversation | Chat reply, email, review comment, issue comment | Opinions expected, plus contractions and short sentences. |

Every tell applies to all three. Voice applies to the last two only. Dropping "I find this approach elegant" into an API reference is its own kind of slop: the writer performing personality where the reader wanted a signature.

When the register is ambiguous, ask. If you cannot ask, pick Reference, because over-neutral prose is a smaller failure than a config doc with a personality.

## Leave alone

Editing prose is safe. Editing claims is not, and the way this skill fails is a confident rewrite that reads better and says something the author never meant. Hold these back:

- **Code and code-shaped text.** Fenced blocks, inline spans, identifiers, config keys, CLI flags, paths, log output, error strings. The checker masks all of it before matching; do the same by eye.
- **Someone else's words.** Quotes, citations, transcript excerpts, a changelog entry reporting what upstream said. Slop inside a quotation is evidence, and smoothing it destroys the evidence.
- **Terms of art.** The abstract-noun tells are tells only when a plainer concrete word exists. Where a project genuinely calls the thing a harness, a surface, or a primitive, that *is* the concrete word, and replacing it costs the reader the ability to search for it.
- **Facts, numbers, names, versions, links.** If the only way to remove a tell is to change or drop a claim, leave the sentence and flag it. "No source given for this" is a useful line in your report. A quietly deleted claim is not.
- **A written style guide.** If the project has one, it outranks this list. Read it first.

## Judgment tells

Ranked by yield. The checker finds candidates for sections 2, 5, 6, 7, 8 and 9. It cannot see 1, 3 or 4 at all, which is exactly where your attention belongs.

### 1. Nothing said

The strongest tell, and ungreppable. Ask what a sentence tells the reader to do or know. If you cannot restate it as an instruction, a fact, or a number, cut it.

"the database stays close at hand", "SQL you can read", "types that follow your schema" each name a feeling. The fixes name a mechanism: "`.toSQL()` returns the exact string sent to the database", "a column rename fails the build".

Then apply the brutal version: if the sentence could appear unchanged in another project's docs, it says nothing about this one.

### 2. Puffery and promotion

`pivotal moment`, `testament to`, `evolving landscape`, `setting the stage for`, `indelible mark`, `deeply rooted`. Travel-brochure dialect: `nestled`, `vibrant`, `breathtaking`, `renowned`, `must-visit`. Software dialect: `seamless`, `robust`, `powerful`, `battle-tested`, `production-ready`, `best-in-class`, `out of the box`. Say what it does, or how fast, or what broke before it existed.

### 3. Unsourced authority

`Experts believe`, `Industry reports suggest`, `Studies show`, `Some critics argue`. Name the source or delete the claim. Do not paraphrase it vaguer, which is the same claim with the evidence filed off.

Its cousin is the **superficial -ing phrase** bolted onto a sentence's end: `highlighting the importance of`, `ensuring scalability`, `reflecting a broader shift`, `fostering collaboration`. Each attaches a conclusion to a fact without earning it. Delete, or replace with the actual reason.

Also here: **name-dropping**, listing outlets or companies without saying what any of them said. Pick one and quote it.

### 4. Manufactured emphasis

Four shapes, all performing significance instead of carrying it.

- **The negated pivot.** `not just X, but Y`, `it isn't only X, it's Y`. State the point directly.
- **The fragment triad.** `Not a library. A philosophy. A way of life.` Write one real sentence.
- **The rule of three.** Forcing ideas into groups of three. Use the number you actually have, even when it is two.
- **False ranges.** "from X to Y" where X and Y sit on no shared scale. List the things.

### 5. Formula and filler

- **Formulaic challenge.** `Despite challenges, the project continues to thrive.` Replace with what the challenge was and what happened.
- **Filler phrases.** `In order to` is `to`. `Due to the fact that` is `because`. `It is important to note that` is nothing. `When it comes to` is nothing.
- **Stacked hedging.** `could potentially possibly be argued that it might` is `may`. One hedge, or none.
- **Generic conclusion.** `The future looks bright`, `only time will tell`, `the possibilities are endless`. State a specific plan or fact, or end one sentence earlier.
- **Section restatement.** `In short`, `The takeaway`, `At its core`, `Key takeaways`. A section needing a summary is a section that is too long.
- **Stock opener.** `In today's fast-paced landscape`, `Let's dive in`, `Here's the thing`, `Think of it as`. Start at the first real sentence.

### 6. Weak verbs and hidden actors

- **Fancy ways to say "is".** `serves as`, `stands as`, `boasts`, `features`. Say `is` or `has`.
- **Passive with a missing actor.** Catch `is/are/was/were` plus a past participle and name who acts: `queries are validated` becomes `the compiler validates queries`. Passive is fine when the actor is unknown or genuinely does not matter.
- **Adverbs propping up weak verbs.** `runs quickly` is `is fast`, or the number. `significantly improves` is the measured delta. An adverb holding up a verb means the verb is wrong.

### 7. Word choice

- **AI vocabulary.** `additionally`, `crucial`, `delve`, `enhance`, `foster`, `garner`, `interplay`, `intricate`, `landscape` (abstract), `moreover`, `myriad`, `pivotal`, `realm`, `showcase`, `tapestry` (abstract), `testament`, `underscore`, `unlock`, `elevate`, `navigate` (abstract). Plain words instead.
- **The fancier synonym.** `utilize` is `use`. `leverage` is `use`. `facilitate` is `help`. `numerous` is `many`. `in the event that` is `if`. The longer word is rarely clearer.
- **Abstract metaphor nouns.** `substrate`, `wedge`, `vector`, `locus`, `vantage`, `nexus`, `primitive`, `bedrock`, `scaffolding`, `modality`, `paradigm`, `gold-plating`, `ratchet`, `flywheel`, `north star`, `endgame`. `Substrate` is `base`. `Wedge in` is `add`. `Gold-plating` is `more than the job needs`. `Ratchet` is the mechanism's real name, or `a limit that only tightens`. Read [Leave alone](#leave-alone) before swapping any of these: in the right project several are the correct term.
- **Synonym cycling.** `protagonist`, `main character`, `central figure`, `hero`, all in one paragraph. Pick one and repeat it. Repetition is clearer than variety here.

### 8. Sentence and paragraph shape

- **Dense sentences.** If the reader backtracks to parse it, split it or drop a clause. One idea per sentence.
- **Uniform rhythm.** Every sentence the same length reads mechanical. Vary it, which is a byproduct of splitting dense sentences rather than a separate exercise.
- **Mechanically parallel bullets.** Every item the same grammatical shape and the same length is a list generated rather than written. Let items differ, or make it prose.

### 9. Punctuation and layout

- **Em dashes.** Avoid them. Use a period or a comma. Not parentheses, not en dashes, not a hyphen or double hyphen standing in for one: reaching for a substitute trades one tell for another. Where a thought needs separation, end the sentence.
- **Colons as mid-sentence connectors.** Fine before a list or an example. "If you're coming from traditional automation: instead of registering handlers, you describe conditions" gains nothing from the colon. Rewrite so the point stands without the comparison: "Describing when the scheduler should fire works best as plain English."
- **Boldface.** Not on every proper noun and acronym. Bold is for the one word a skimming reader must not miss.
- **Inline-header lists.** The tell is a bold label plus colon that restates the line: "**Performance:** Performance improved". Convert to prose. A bold lead-in ending in a period, naming the item, followed by new detail ("**Schema in TypeScript.** Tables live in one file.") is a legitimate shape, and so is a glossary defining a named field.
- **Title case headings.** Sentence case, unless every capital is a proper noun.
- **Decorative emoji and check marks.** Remove from headings, bullets and tables.
- **Curly quotes.** Straight quotes.
- **Callout spam.** "Note:", "Important:", "Tip:" stacked down a page. If it matters, put it in the sentence that needs it.

### 10. Chat artifacts

- **Chatbot phrases.** `I hope this helps`, `Let me know if`, `Of course!`, `Certainly!`, `Found the smoking gun!`, `Ready to get started?`. Delete.
- **Sycophancy.** `Great question`, `You're absolutely right`, `Excellent point`. Answer instead.
- **Cutoff disclaimers.** `While specific details are limited`, `based on publicly available information`. Find the source or cut the sentence.

## Voice

Argument and Conversation registers only. This half is where a de-slopped draft stops reading like a form.

- **Have an opinion.** React to the facts instead of listing pros and cons at equal weight. A reader can tell when the writer has no stake.
- **Acknowledge the complication.** "Impressive, and slightly unsettling" beats "impressive". Anything with only good sides was not examined.
- **Use "I" where it fits.** First person is not unprofessional. It is how you take responsibility for a claim.
- **Be concretely specific.** Not "this is concerning" but "there is something unsettling about agents churning away at 3am".
- **Let some mess in.** A sentence that starts somewhere unexpected, a paragraph that runs short. Perfect symmetry is the machine's signature.

Voice is not the same as volume. None of this licenses exclamation marks, jokes the reader did not ask for, or an opinion about something you did not examine.

## Worked example

The point of the example is the judgment, not the word swaps. Notice that the unsourced claim is flagged rather than fixed, and that the result is 40% shorter.

Before:

```text
## Unlocking Seamless Data Sync

In today's fast-paced development landscape, keeping state consistent across
devices is crucial. Our new sync engine serves as a testament to what's
possible — it's not just a cache, but a robust, battle-tested foundation for
the future. Industry reports suggest that offline-first apps see significantly
better retention. The future looks bright.
```

After:

```text
## Offline sync

Sync writes to a local SQLite file first, then pushes to the server when the
connection returns. Conflicts resolve last-write-wins per row, keyed on
`updated_at`. Writes made offline survive an app kill.
```

Reported back to the author:

```text
Fixed: title-case heading, stock opener, "crucial", "serves as a testament",
em dash, not-just-X-but-Y, "robust"/"battle-tested", "significantly",
generic conclusion. Replaced the feeling-words with the mechanism and the
guarantee.

Flagged, not changed: "Industry reports suggest offline-first apps see better
retention." No source, and I cannot verify it. Name the report or cut the
sentence.
```

## Not this skill

For documents an *agent* reads (a skill, an `AGENTS.md` or `CLAUDE.md`, a reference reached by a pointer), call the Skill tool with "writing-for-agents". Different reader, different rules: an agent-facing doc is tuned for a predictable process across runs, not for a human's ear. Unslop still applies to its prose, and applies second.
