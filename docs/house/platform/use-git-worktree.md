## What it does

Puts the change you are about to make in its own [worktree](https://git-scm.com/docs/git-worktree): a second working directory under `.worktrees/`, on a `feat/` or `fix/` branch, created before the first edit lands.

The main checkout is never touched. It keeps its branch, its index, and whatever you had half-finished in it, because a worktree owns only its own `HEAD`, index, and files while sharing one object store and one set of refs with everything else. That is the whole reason this is cheap enough to do by default: it is not a clone, nothing is copied, and a branch created here is visible from every other worktree at once.

## When to reach for it

Type `/use-git-worktree`, or the agent reaches for it automatically when a task fits. Fitting is the interesting part, because the trigger is deliberately wider than the word:

| Situation | What happens |
|---|---|
| A feature, a fix, a refactor, a dependency upgrade, a plan touching several files | A worktree gets made, even if nobody said "worktree" |
| A one-line or single-file edit | Skipped; the setup costs more than the change |
| You said to work on the current branch | Skipped; an explicit instruction wins |
| You are already inside a linked worktree | It stops and reports where you are, rather than nesting a second one |

## Prerequisites

A repository with at least one commit. There is no `HEAD` to branch from before that, `git worktree add` fails, and the skill says so and works in place instead.

Nothing else. It writes `/.worktrees/` into `.gitignore` if the directory is not already ignored, which is the one file it touches outside the worktree it creates.

## Isolation, not a clone

The leading idea. A clone duplicates the repository; a worktree adds a working directory to the one you have. Object store, refs, and config stay shared, so the cost is the checked-out files and nothing more, and there is no second remote to keep in sync.

That sharing has one consequence worth holding on to: git will not check out the same branch in two worktrees. If a worktree already exists on the branch you want, that is a hard stop rather than a warning, and the answer is to enter the existing one.

## The three things that go wrong

Each has a fixed answer, and the skill takes it rather than improvising:

| Failure | What it does |
|---|---|
| The branch already exists | Checks it out instead of creating it; enters the existing worktree if one already holds it |
| The sandbox refuses to create the directory | Says so plainly, then works in the main checkout |
| The repo has no commits | Says so, works in place; isolation needs a first commit |

The one it will not do is proceed quietly in place. That is the failure worth naming, because you carry on believing your branch is protected when it is not.

## Common questions

**Why `.worktrees/` and not the harness's own worktree directory?**
Because the [harness](https://www.aihero.dev/ai-coding-dictionary/harness) directory is not a convention you control and not one your teammates share. The skill creates the worktree with plain `git worktree add .worktrees/<branch>` first, then asks the harness to move the [session](https://www.aihero.dev/ai-coding-dictionary/session) into that path. An earlier version ordered it the other way, which read sensibly and meant the documented `.worktrees/` layout was dead code: in Claude Code the native tool always won and always landed somewhere else.

**My linter, CI, or file watcher started failing on paths under `.worktrees/`.**
Expected, and the fix does not belong in this skill. A worktree is a full second checkout, so anything that walks files rather than asking git sees every file twice and reports the copy against the original. Add `.worktrees/` to that tool's skip list, next to wherever it already skips `node_modules`. `.dockerignore` needs the rule separately, because it does not read `.gitignore`. This repo's own validation harness had to learn the same lesson.

**It made a worktree and I only wanted a small change.**
Say so and it stays put; an explicit instruction to work on the current branch is part of the trigger. The default leans toward isolating because the cost is asymmetric: an unwanted worktree is a directory you delete, an unwanted commit on the wrong branch is a history you rewrite.

**Why only `feat/` and `fix/`?**
So the decision is a coin flip rather than a taxonomy. Anything that is not a bug fix takes `feat/`, refactors and upgrades included, and the worktree path mirrors the branch, so the branch name is the only thing to pick.

**Does it work inside a submodule?**
Yes, and it treats a submodule as a plain checkout, which is what you want. Submodules do not use the worktree mechanism at all, so the detection that distinguishes a worktree from a normal checkout reads a submodule as normal, and a worktree *of* a submodule as a worktree. Both correct, with no special case.

## It's working if

- `git status` in your original terminal still shows the branch and the uncommitted work you left there.
- The new branch was cut from the default branch tip, not from whatever the main checkout happened to be on.
- Running it twice in the same repo does not add a second `.worktrees/` line to `.gitignore`.
- It hands back after reporting the path and branch, without installing dependencies or running the suite you did not ask for.
- Asked to start work while you are already in a worktree, it tells you where you are instead of making another.

## Where it fits

A **precondition that runs per change**, at the head of any flow that writes code. It is not a numbered step: `/implement`, `/tdd`, and a fix arriving through [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) all begin inside whatever workspace this made, and it fires once per change rather than once per step.

Its neighbours are [implement](https://aihero.dev/skills-implement), because that is what runs in the worktree once it exists, and [resolving-merge-conflicts](https://aihero.dev/skills-resolving-merge-conflicts), the other skill that works git state directly, reached for at the far end when the branch comes home.

For the whole map, see [ask-matt](https://aihero.dev/skills-ask-matt).
