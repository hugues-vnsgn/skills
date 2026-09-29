## Problem Statement

After a planning session (grilling, then `to-spec` and `to-tickets`), the user runs `/implement` to build the result.
`/implement` works inline, so the same agent that spent its context grilling and writing the spec now also writes the code.
Its context carries all the planning noise, nothing runs in parallel, there is no review checkpoint between Issues, and a long spec can exhaust the window partway through.
The fork already describes an orchestrated alternative in `implement-spec`, but no implementer subagent definition exists for it to dispatch, and it opens a draft PR, which pushes without the user asking.
The user wants implementation handed to fresh agent instances that know enough of the current context to build each Issue well, without the main agent's whole conversation.

## Solution

Two implementer subagent definitions and a new user-invoked orchestrator skill, `/implement-delegate`.

The implementer is a subagent defined in Markdown with YAML frontmatter.
It builds exactly one Issue, test-first, in a worktree it is given, commits there, and returns a fixed-format report.
One variant preloads the generic `tdd` skill; a KMP variant also preloads `tdd-kmp` and `kmp-test-seams`.

`/implement-delegate` is a clone of `/implement` that orchestrates instead of implementing.
It walks the spec's graph of blocking edges, dispatches one implementer per unblocked Issue into its own worktree, reviews each result, merges passing work into a feature branch, and finishes with a whole-branch review.
Context passes as pointers into the Issue tracker, not as a copy of the conversation: whatever the implementer needs and the spec lacks is written into the spec first.

`/implement` stays unchanged as the inline option.

## User Stories

1. As a developer who has just run `to-spec` and `to-tickets`, I want to hand the whole spec to `/implement-delegate`, so that implementation happens outside my planning context.
2. As a developer, I want to pass a spec's bead ID to `/implement-delegate`, so that it works through every child Issue in blocking order.
3. As a developer, I want to pass a single Issue's bead ID, so that I can delegate one slice without the whole spec.
4. As a developer who passes no argument, I want `/implement-delegate` to use the spec just created in this conversation and confirm its ID with me first, so that I do not have to copy IDs around.
5. As a developer, I want `/implement` to keep working inline, so that I can still build small single-Issue work without the cost of worktrees.
6. As a developer, I want only me to be able to start `/implement-delegate`, so that the model never launches a fleet of implementers on its own.
7. As a developer, I want each implementer to start with a fresh context, so that grilling noise does not leak into implementation.
8. As a developer, I want the implementer to receive a brief of at most ten lines made only of pointers, so that the spec and its Issues remain the single source of truth.
9. As a developer, I want decisions that exist only in the conversation written to the spec Issue before any dispatch, so that implementers, reviewers and later Issues can all see them.
10. As a developer, I want a handoff document written to the OS temporary directory and passed by path when the context genuinely will not fit in ten lines of pointers, so that there is a fallback that is still reviewable.
11. As a developer, I want each implementer to read the target repo's `AGENTS.md` or `CLAUDE.md` inside its worktree before touching code, so that repo gates and conventions apply even if the harness does not load them into a subagent.
12. As a developer working in a KMP or mobile repo, I want the implementer to arrive with `tdd`, `tdd-kmp` and `kmp-test-seams` already loaded, so that it applies the KMP testing discipline without having to discover it.
13. As a developer working in any other repo, I want the implementer to preload only `tdd`, so that KMP guidance does not pollute unrelated work.
14. As a developer, I want the orchestrator to choose the KMP variant mechanically from repo markers (the Kotlin Multiplatform plugin, an Android app module, an Xcode project), so that the choice never depends on my remembering it.
15. As a maintainer of the skills repo, I want the two implementer variants to carry byte-identical bodies enforced by the validation harness, so that they cannot drift apart.
16. As a developer, I want implementers to default to Sonnet, so that routine Issues are fast and cheap.
17. As a developer, I want Issues labelled `model:opus` to be dispatched on Opus, so that complex slices get the stronger model from the start.
18. As a developer, I want `to-tickets` to apply `model:opus` when a slice introduces or changes a state machine, a concurrency or coroutine contract, or an expect/actual or platform boundary, so that the escalation decision is made and visible when the Issue is written.
19. As a developer, I want `to-tickets` to also apply `model:opus` to a slice whose interface three or more other Issues depend on, to a wide refactor or its integration Issue, and to a slice that needs a new seam, so that the riskiest slices are covered.
20. As a developer, I want an Issue that returns FAILED, exhausts its turn budget, or fails review twice to be retried by a fresh implementer on Opus, so that underestimated Issues still land.
21. As a developer, I want the orchestrator to create a feature worktree on an `agent/<spec-id>` branch, so that no work ever happens on `main` or in the main checkout.
22. As a developer, I want each Issue built in its own worktree branched off the feature branch, so that parallel implementers never share a working tree.
23. As a developer, I want the orchestrator to follow the target repo's worktree conventions (location, copying ignored local config such as `local.properties`), so that builds work in the new worktree.
24. As a developer, I want the brief to carry the absolute worktree path, so that the implementer never edits the main checkout by accident.
25. As a developer, I want at most two implementers running at once, so that parallel Gradle and Kotlin/Native builds do not exhaust memory.
26. As a developer, I want Issues likely to touch the same files never dispatched together, so that implementers do not race each other's edits.
27. As a developer, I want implementers to run in the background, so that the orchestrator keeps working through the frontier while they build.
28. As a developer, I want the implementer to claim its Issue in the tracker with an actor name that identifies it, so that the audit trail shows which implementer did what.
29. As a developer, I want the implementer to test only at the seams the spec names, so that the `tdd` rule of pre-agreed seams holds without a live human in the loop.
30. As a developer, I want an implementer that needs a seam the spec does not name, or a change to an interface or to domain meaning, to stop and return BLOCKED with one question and a recommended answer, so that a gap in the spec is fixed in the spec, not guessed.
31. As a developer, I want local choices inside the Issue made by the implementer and recorded as a comment on the Issue, so that I am not interrupted for decisions that do not matter outside the slice.
32. As a developer, I want the orchestrator to put a BLOCKED question to me and then resume the same implementer with my answer, so that the implementer keeps the context it already built.
33. As a developer, I want the implementer to file discovered work as new Issues linked with `discovered-from`, so that nothing found mid-build is lost or silently widened into scope.
34. As a developer, I want the implementer to run the repo's gates (tests, compiles, lint) before reporting, so that the orchestrator only reviews work that builds.
35. As a developer, I want the implementer to commit on its own branch, so that the orchestrator has something to merge.
36. As a developer, I want the implementer structurally unable to push, open or merge a PR, or sync the tracker remote, so that nothing leaves my machine without my say-so.
37. As a developer, I want every implementer report in the same fixed shape (status, Issue, branch, worktree, commits, gate evidence, seams tested, deviations, discovered Issues, and a question when blocked), so that the orchestrator can act on it without interpretation.
38. As a developer, I want each finished Issue reviewed by a separate reviewer before merging, so that a defect does not propagate into the Issues that depend on it.
39. As a developer, I want review findings sent back to the same implementer for at most two rounds, so that fixes are made by the agent that already understands the code.
40. As a developer, I want each passing Issue merged into the feature branch with `--no-ff`, so that every Issue stays one visible unit in history.
41. As a developer, I want textual merge conflicts resolved by the orchestrator and conflicts of meaning brought to me, so that I only decide what needs judgement.
42. As a developer, I want the orchestrator to close an Issue only after its review passes and it is merged, so that dependent Issues unblock only on work that actually landed.
43. As a developer, I want finished Issue worktrees removed without deleting any branch, so that the machine stays clean and no history is lost.
44. As a developer, I want a whole-branch `code-review` once every Issue is merged, so that cross-Issue problems are caught.
45. As a developer, I want the whole-branch findings fixed by one fresh implementer on the feature branch, so that no single stale context has to cover the whole spec.
46. As a developer, I want the final report to list changed files, gate evidence, closed Issues, and the push and PR commands for me to run, so that I decide when anything is published.
47. As a maintainer of the skills repo, I want the agent definitions versioned in the fork and symlinked into the harness agents directory by a link script, so that a pull keeps them current the same way skills are.
48. As a maintainer of the skills repo, I want the new agents tree and link script declared as fork Additions, so that the fork boundary check stays green.
49. As a maintainer of the skills repo, I want the validation harness to reject an agent file with bad frontmatter or a preloaded skill that does not exist or is user-invoked, so that a broken agent never ships.
50. As a maintainer of the skills repo, I want the repo's `AGENTS.md` to say what an agent file is and how it gets linked, so that the next contributor does not have to reverse-engineer it.
51. As a developer in a repo whose policy says "commit only when asked", I want that policy to state that running `/implement-delegate` authorizes local commits on agent branches while pushing still needs me, so that the orchestrator and the repo rules do not contradict each other.
52. As a maintainer of the skills repo, I want `implement-spec` deprecated once `/implement-delegate` has completed one real spec, so that there is one orchestration skill, not two.

## Implementation Decisions

**Agent definitions**

- Two user-level subagent definitions, `implementer` and `implementer-kmp`, live in a new fork-owned top-level agents tree in the skills repo and are symlinked into the harness's user agents directory.
- They are linked by a new sibling link script rather than by changing the existing skill link script, which is upstream-authored and marked as not accepting modifications.
- Both definitions share one body verbatim and differ only in frontmatter: name, description, and the `skills` preload list.
- `implementer` preloads `tdd`; `implementer-kmp` preloads `tdd`, `tdd-kmp` and `kmp-test-seams`.
- Frontmatter sets `model: sonnet` and `maxTurns: 150`; tools are inherited. The per-call model override on dispatch selects Opus.
- The description states that the agent requires a brief with an absolute worktree path and is dispatched by `/implement-delegate`, so the main agent does not choose it for work that has no brief.
- A `PreToolUse` hook in the frontmatter runs an implementer guard that reuses the existing dangerous-git guardrail for `git push` and additionally blocks `gh pr create`, `gh pr merge`, `bd dolt push` and `bd dolt pull`.
- The body instructs the agent, in order: confirm it is inside the given worktree; read the worktree's `AGENTS.md`/`CLAUDE.md`; claim the Issue with an actor of the form `implementer-<issue-id>`; read the spec and Issue; red-green only at seams the spec names; commit on its branch; run the repo gates once at the end; report.
- The body also states the BLOCKED rule: a needed seam the spec does not name, an interface change, or a change to domain meaning returns BLOCKED; local choices are made and recorded as an Issue comment.
- The body also states the hard limits: no commits on `main`, no edits outside the worktree path, no push, no PR, no tracker remote sync.
- The body does not call `code-review` or any skill that spawns subagents, because subagents cannot nest.

**Report contract**

```
STATUS: DONE | BLOCKED | FAILED
TICKET: <issue-id>   BRANCH: <branch>   WORKTREE: <abs path>
COMMITS: <sha subject> ...
GATES: <command> -> PASS/FAIL, log: <path>
SEAMS TESTED: ...
DEVIATIONS: what differs from the Issue and why (also commented on the Issue)
DISCOVERED: new Issues filed with discovered-from:<id>
QUESTION: (only when BLOCKED) one question with a recommended answer
```

**Orchestrator skill**

- `/implement-delegate` is a new fork skill, cloned from `/implement`, staged in the in-development bucket with `metadata.internal: true` and `status: beta` in the catalog.
- It is user-invoked in both harnesses: `disable-model-invocation: true` in the skill, `policy.allow_implicit_invocation: false` in its Codex metadata.
- Input: a spec or epic ID walks the graph of child Issues; a single Issue ID runs that Issue; no argument uses the spec just created in the conversation after confirming its ID.
- Before any dispatch it writes conversation-only decisions onto the spec Issue, so each brief is pointers only: Issue ID, spec ID, absolute worktree path, branch, base branch, the seams named in the spec, and an escalation note when relevant.
- If a brief would still exceed ten lines, the orchestrator writes a handoff document to the OS temporary directory itself and passes its path. It does not invoke `/handoff`, because a user-invoked skill cannot reach another user-invoked skill.
- Worktrees: one feature worktree on `agent/<spec-id>`, one per-Issue worktree branched off it, created by the orchestrator following the target repo's worktree conventions.
- Variant selection: `implementer-kmp` when the repo shows the Kotlin Multiplatform plugin, an Android app module, or an Xcode project; otherwise `implementer`.
- Model selection: Opus when the Issue carries `model:opus`, otherwise the agent default.
- Concurrency: at most two background implementers at once; Issues likely to touch the same files, judged from their descriptions, run sequentially.
- BLOCKED: ask the user, then resume the same implementer via `SendMessage`.
- Per-Issue review uses a separate reviewer; findings go back to the same implementer for at most two rounds. Two failed rounds, FAILED, or the turn cap triggers a fresh implementer on Opus.
- On pass: `git merge --no-ff` into the feature branch, close the Issue, remove the Issue worktree from the main checkout without deleting branches. Textual conflicts are resolved by the orchestrator via `resolving-merge-conflicts`; conflicts of meaning go to the user.
- At the end: `code-review` on the whole feature branch against its base, one fresh implementer fixes all findings, the repo gates run in the feature worktree, and the orchestrator reports without pushing.

**Changes to existing skills and repo docs**

- `to-tickets` gains the `model:opus` labelling rule with the criteria in User Stories 18 and 19. It is already a sanctioned upstream edit, so its divergence record's resolution recipe is updated to cover the new rule.
- The fork's divergence record declares the agents tree and the new link script under Additions.
- The skills repo's `AGENTS.md` gains a short section defining an agent file, where it lives, and how it is linked.
- The in-development bucket README lists `/implement-delegate`, and the catalog gains its entry with generated artefacts regenerated.
- The BFSOne repo's git policy gains one line: running `/implement-delegate` authorizes local commits on agent branches; pushing still requires the user.

## Testing Decisions

A good test here checks what a user or the harness observes: that a malformed agent is rejected, that a forbidden command is blocked, that a spec actually gets built, merged and reported.
It does not assert on prose wording inside the agent body or the skill.

Seams, agreed with the user:

1. **Skill validation harness (existing).** New assertions: every agent file's frontmatter parses and has the required fields; every preloaded skill exists and is model-invoked; the two implementer bodies are byte-identical; `/implement-delegate`'s invocation mode is consistent across its skill frontmatter and its Codex metadata. Prior art: the existing invocation-consistency and bucket-membership assertions.
2. **Fork boundary check (existing).** No new assertions; it must pass with the agents tree and link script declared as Additions. Prior art: the fail-closed forkcheck tests.
3. **Git guardrail functional tests (existing, extended).** New cases prove the implementer guard blocks `git push` (including `git -C` and env-prefixed forms), `gh pr create`, `gh pr merge`, `bd dolt push` and `bd dolt pull`, and lets ordinary git and `bd` commands through. Prior art: the existing guardrail case table.
4. **End-to-end trial (new, agentic).** In an isolated worktree of the BFSOne repo on a scratch branch, run `/implement-delegate` against a throwaway two-Issue spec with one blocking edge, where one Issue deliberately needs a seam the spec does not name. Pass when: the unblocked Issue runs first; each Issue gets its own worktree; the BLOCKED question reaches the user and the same implementer resumes; per-Issue review runs; both Issues merge `--no-ff` into the feature branch; Issues close only after merge; the final report lists push commands and nothing is pushed. Then repeat on one real small spec from the BFSOne backlog, judging whether pointer-only briefs carried enough context.

The link script has no automated test, matching the existing skill link script.

## Out of Scope

- Any change to `/implement`; it stays the inline path.
- Deprecating `implement-spec`; that happens after the first successful real run, as a separate change.
- Pushing, opening PRs, or syncing the tracker remote from any agent.
- Project-level implementer overrides in individual repos.
- A Codex or other-harness equivalent of the subagent definitions; the agent files target Claude Code only.
- Parallelism above two, and automatic detection of file overlap beyond reading Issue descriptions.
- Promoting `/implement-delegate` out of the in-development bucket or writing its docs page.

## Further Notes

The design was settled in a grilling session on 2026-09-29 in the BFSOne repo.
Two findings from exploring this repo adjusted it: fork skills go in the in-development bucket rather than the upstream-owned in-progress bucket, and the orchestrator cannot invoke `/handoff` because both are user-invoked.
It is unverified whether Claude Code loads `CLAUDE.md` into custom subagents; the implementer reads it explicitly, so the design holds either way.
Build this spec with the inline `/implement`, since `/implement-delegate` is what is being built.
