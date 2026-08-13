## What it does

Takes a capability you have seen working in another codebase and brings it into this one: read the source, argue about whether you want it, place it behind a seam that fits here, then build it test-first.

It never pastes. The code is rewritten in this codebase's idiom, because the version you are reading was shaped by constraints that are not yours — its dependency graph, its error convention, its platform assumptions. What crosses over is the approach, not the expression.

## When to reach for it

You invoke this by typing `/port-from-repo` — the agent won't reach for it on its own.

| Situation | Reach for |
|---|---|
| Another repo solves a problem you have, and you want that capability here | `/port-from-repo` |
| You want to understand how another project works, with no intention of building | [research](https://aihero.dev/skills-research) |
| You know what to build already and no other codebase is involved | [implement](https://aihero.dev/skills-implement) |
| You want the whole project, not a capability from it | Neither — clone it |

## Prerequisites

The source repository must be readable — a public GitHub URL, an `owner/repo` you have access to, or a local path. It is fetched outside this repository and never modified: you are reading it as a [primary source](https://www.aihero.dev/ai-coding-dictionary/primary-source), not acquiring a dependency.

## Adapt, don't transplant

The leading idea, and the one the whole skill turns on. A transplant moves the code; an adaptation moves the insight and rewrites the rest.

The tell that you are transplanting rather than adapting: the diff reads as imported. Foreign naming, an error convention that appears nowhere else, a dependency added because the source had it. That code works and still makes the codebase worse, because the next person to read it has to hold two idioms in their head.

Most of what you are looking at is plumbing. The skill's understand phase exists to make you name the part that is not, before you decide anything.

## The challenge phase

Between reading the source and writing any code, the skill runs [grilling](https://aihero.dev/skills-grilling) on a single question: should we bring this over at all?

It is the step people skip, and the reason ports go wrong. The four questions it pushes on — what is the smallest thing that solves our problem, what do we already have that overlaps, which of the source's constraints are we inheriting, what happens if we do nothing — routinely cut the scope to a fraction of what the source built.

## Common questions

**Does it copy the source's code?**
No. It retypes in this codebase's idiom, deliberately. Retyping is what surfaces the assumptions that don't hold here — a paste hides them until something breaks.

**What if the source has an incompatible licence?**
Check before you start. The skill ports an approach rather than an expression, which is the safer footing, but a licence that restricts derivative work is a reason not to proceed — raise it rather than working around it.

**How does this differ from just asking the agent to copy a file?**
The challenge phase. A copy answers "can we have this?"; the skill answers "do we want this, and in what shape?" — and the answer is often a smaller thing than the source built.

## It's working if

- You can state what the ported capability does without referring to the source's code.
- The scope shrank during the challenge phase — you are building less than the source did.
- Reading the diff cold, nothing marks it as imported.
- The commit message names the source repository and the commit it came from.

## Where it fits

An **on-ramp**: a starting situation that generates work and then merges onto the main flow. It ends where [implement](https://aihero.dev/skills-implement) and [code-review](https://aihero.dev/skills-code-review) do, having driven [tdd](https://aihero.dev/skills-tdd) to build each slice.

Its neighbours are [research](https://aihero.dev/skills-research), because reading another codebase to answer a question is research and stops there, and [codebase-design](https://aihero.dev/skills-codebase-design), because deciding where the ported capability sits is a seam decision in this codebase rather than a copy of the source's. On a Kotlin Multiplatform codebase it hands the `expect`/`actual` versus interface-plus-DI call to [kmp-module-setup](../../skills/team/mobile/kmp-module-setup/SKILL.md).

For the whole map, see [ask-matt](https://aihero.dev/skills-ask-matt).
