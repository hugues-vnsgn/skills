---
"osxsystem-skills": minor
---

Ship `use-git-worktree`: promote it out of `in-development/` into `house/platform/`, and restate what that domain is for.

The skill itself is unchanged apart from two lines. It drops `metadata.internal: true`, which is what kept it out of the installer picker, so it now installs like any other promoted skill. And the paragraph explaining why an old submodule guard was wrong becomes a one-sentence prohibition, because its job was never to record history: it was to stop the next agent helpfully adding the guard back. The trigger is untouched, deliberately. It was rewritten once already against how the worktree actually gets made, and tightening it now on a hunch would trade a calibrated trigger for a guess.

**Platform's charter was lying before this landed.** It read "the toolchain itself: repo configuration for the engineering flow, bringing capabilities across from other codebases, and unsticking a design", which already failed to describe `herdr` (a terminal multiplexer) and `when-stuck` (re-framing a design problem). Adding a worktree skill made it undeniable. The domain is now **the workbench rather than the code**: the workspace a change is built in, the repo configured for the engineering flow, capabilities brought across from elsewhere, and unsticking a design. That is a boundary a future skill can be tested against, which "toolchain" had stopped being. Restated in all four places that carry it: the bucket `README.md`, the top-level `README.md`, `CLAUDE.md`, and the `.fork/divergence.md` Additions row.

Platform gains its first **Model-invoked** section, in both its own README and the top-level one; every resident until now was user-invoked or beta.

Registration for a promoted skill, in full: catalog entry moved to the `platform` domain with `status: beta` dropped, `CATALOG.md` and `marketplace.json` regenerated, a docs page at `docs/house/platform/use-git-worktree.md`, an entry in the engineer reading order, and a routing paragraph in `ask-matt` at the point in the main flow where code first gets written. The router paragraph says plainly that the skill fires per change rather than per step, since that is the thing a numbered list would otherwise imply and get wrong.

Two things found while writing it, both filed rather than fixed here:

- `use-git-worktree` allows exactly two branch prefixes and says not to invent a third, while `prototype` puts its work on a `prototype/<name>` branch. A prototype detour that reaches for the worktree skill therefore gets `feat/<slug>` and quietly breaks a convention that exists so the prototype stays findable. Filed as `skills-7e0`.
- `skills-dpk`, which reported both fork guards false-positiving on nested worktrees, was already fixed and shipped. Closed against the two code locations that prove it.
