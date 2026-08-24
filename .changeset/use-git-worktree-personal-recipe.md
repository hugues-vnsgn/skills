---
"osxsystem-skills": minor
---

Rebuild `use-git-worktree` around the maintainer's actual habit, register it, and fix two bugs the old version shipped.

The skill had drifted from how the worktree gets made in practice. It ordered native harness tools ahead of plain git, which reads sensibly but meant the documented `.worktrees/` fallback was dead code in Claude Code: `EnterWorktree` always won and always landed in `.claude/worktrees/`. The recipe now runs the other way. `git worktree add .worktrees/<branch>` creates the worktree, then `EnterWorktree` is called with `path:` to move the session into it, which keeps the `.worktrees/` layout while still letting later tool calls read and write the worktree rather than the main checkout. Branch names are `feat/<slug>` and `fix/<slug>`, matching the fork's conventional-commit subjects, and the worktree path mirrors the branch.

Two guards were quietly broken, both found by running the commands rather than reading them:

- `git check-ignore -q .worktrees` reports "not ignored" whenever the directory does not exist yet, because a directory-only pattern cannot match a path git has not seen on disk. On a fresh repo the guard therefore appended `.worktrees/` to `.gitignore` on every single invocation. Querying `.worktrees/` with the trailing slash matches under every pattern style, present directory or not.
- Appending the rule with a bare `echo` corrupts a `.gitignore` that ends without a newline, fusing the two lines into `node_modules.worktrees/`. The `printf` now leads with a newline.

The submodule guard was wrong rather than merely redundant: it claimed the git dir and the common git dir differ inside a submodule, and they are identical, because submodules do not use the worktree mechanism at all. So a submodule never tripped the test the guard existed to disambiguate, and the guard was dead code justified by a false premise. Detection is now the one comparison that is actually true (`--git-dir` against `--git-common-dir`), which classifies a submodule as a plain checkout and a worktree *of* a submodule as a worktree, both correct, and folds four `rev-parse` calls into one.

That call carries `--path-format=absolute`, which is load-bearing rather than tidy. Git answers `--git-common-dir` relative to the cwd, so from a subdirectory an unnormalised comparison sees `/repo/.git` against `../../.git`: one directory, two spellings, which a string test calls a worktree. The skill would then announce "already isolated" from any subdirectory and create nothing. The previous version normalised with `cd "$(git rev-parse --git-dir)" && pwd -P`; dropping that as a token saving reintroduced the bug, and the flag is the cheap way to keep it fixed.

`git worktree add` now names its base ref explicitly. Without one git branches from the main checkout's current `HEAD`, and this skill's entire premise is that the checkout was left parked wherever the user had it, so a new feature branch silently forks from whatever stale work was checked out. Verified: with `HEAD` on an unrelated branch, the new worktree inherited that branch's files.

Scope shrank to match the recipe, which stops at a ready workspace. Dependency install and the baseline test suite are gone: they were the bulk of the skill's cost, they ran a full install and a full suite on every worktree however small the task, and a dirty baseline is the next step's problem to report. `SKILL.md` is 78 lines against 167, and the detection phase is one shell call against five.

The description gained a size floor and a stand-down clause. It fires on features, fixes, refactors, upgrades, and plans that span more than one file, and explicitly stands down for one-line edits and for a user who says to work on the current branch. Without those, "picks up a bug fix" claimed a worktree, a branch, and a permanent `.gitignore` edit for fixing a typo in a README. Refactors and upgrades now map to `feat/` by an explicit rule, so the agent stops improvising a third prefix.

Registration was missing entirely, which is why none of this was reachable: the skill had no `.fork/catalog.yaml` entry, no line in the `in-development` bucket README, no `agents/openai.yaml`, and no `metadata.internal: true`. All four are in place, `status: beta`, so it stays out of the installer picker, the top-level README, `docs/`, and `ask-matt` until it is promoted.
