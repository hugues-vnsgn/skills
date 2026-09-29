---
name: implement-delegate
description: "Delegate an Issue to a fresh implementer subagent in its own worktree, then review, merge and close it."
disable-model-invocation: true
metadata:
  internal: true
---

You orchestrate; implementers build. Each Issue goes to a fresh `implementer` subagent in its own worktree, a separate reviewer checks the result, and it lands on a feature branch as one `--no-ff` merge. Every code change, review fixes included, goes through an implementer.

Running this skill authorizes local commits and merges on `agent/` branches. Everything else that leaves the machine stays with the user: the final report hands them the push and PR commands. In beads, pass `--sandbox` on every `bd` write, so the tracker's remote is never synced either.

## Input

This version takes one Issue ID and delegates it end to end. Given a spec or epic ID (an Issue with children), say the spec-graph walk is not built yet, offer to delegate its unblocked child Issues one at a time, and stop. Given no argument, say the same and ask for an Issue ID.

Read the Issue in full, comments included, through the repo's issue-tracker doc (`bd show <id>` in beads). Its **spec** is its parent Issue; an Issue with no parent is its own spec. Carry on only when the Issue is open, every blocker is closed, and nobody else has claimed it; otherwise report which and stop.

## 1. Settle the context onto the spec

A fresh implementer sees the tracker, never this conversation. Write onto the spec Issue, as a note or comment, every decision, constraint or rejected option from this conversation that bears on the Issue. Check that the spec names the test seams this Issue builds through; if it names none, agree them with the user and write them onto the spec too.

Done when the spec carries every such decision and names this Issue's seams.

## 2. Pick the agent and the model

- **Variant:** `implementer-kmp` when the repo shows the Kotlin Multiplatform plugin, an Android app module, or an Xcode project; otherwise `implementer`. Decide from the markers, not the Issue's wording:

  ```bash
  git grep -lE 'kotlin\("multiplatform"\)|org\.jetbrains\.kotlin\.multiplatform|com\.android\.application' -- '*.gradle*' '*.toml'
  git ls-files | grep -E '\.(xcodeproj|xcworkspace)/' | head -1
  ```

- **Model:** `opus` when the Issue carries the `model:opus` label; otherwise leave the model unset so the agent's default applies.

If the chosen agent type is not available in this session, tell the user to run `scripts/link-agents.sh` in the skills repo and restart Claude Code, then stop.

## 3. Create the worktrees

Two branches, named once here and used by these names below:

- **FEATURE**: `agent/<spec-id>`, branched from the local default branch so the user's unpushed commits are included.
- **ISSUE**: `agent/<spec-id>--<issue-id>`, branched from FEATURE.

Each gets a worktree at the location the target repo's `AGENTS.md` / `CLAUDE.md` conventions give, along with the list of ignored local files (`local.properties`, `.env`, signing config) a build needs copied in. With no convention, use `.worktrees/<branch>` at the repo root, ignored locally first:

```bash
git check-ignore -q .worktrees/ || echo '/.worktrees/' >> "$(git rev-parse --git-common-dir)/info/exclude"
```

From the main checkout's root:

```bash
# FEATURE: create it, or check out the existing branch, or reuse a worktree already on it.
git worktree add <feature-worktree> -b agent/<spec-id> <default-branch>
git worktree add <feature-worktree> agent/<spec-id>
# ISSUE, off FEATURE.
git worktree add <issue-worktree> -b agent/<spec-id>--<issue-id> agent/<spec-id>
```

Copy the needed ignored files into each new worktree.

Done when both worktrees exist, the build's local files are in place, and you hold both absolute paths.

## 4. Brief and dispatch

The brief is at most ten lines of pointers; the spec and the Issue carry the substance:

```
ISSUE: <issue-id>
SPEC: <spec-id>
WORKTREE: <absolute path of the ISSUE worktree>
BRANCH: agent/<spec-id>--<issue-id>
BASE: agent/<spec-id>
SEAMS: <the seams the spec names for this Issue>
ESCALATION: <only on an Opus retry: why the previous attempt stopped>
HANDOFF: <only when needed: absolute path of the handoff document>
```

When the context the implementer needs genuinely will not fit in pointers, write a handoff document yourself to `$TMPDIR/implement-delegate-<issue-id>.md` (`/tmp` when `$TMPDIR` is unset) and pass its path. `/handoff` is user-invoked, so no skill can reach it.

Dispatch with the Agent tool in the background: the variant from step 2 as `subagent_type`, `model: "opus"` when step 2 chose it, the brief as the prompt. Keep the returned agent ID for resuming. Leave the ISSUE worktree to the implementer until it reports.

## 5. Act on the report

The report arrives in the implementer's fixed contract. Before acting on it, check its claims: `git log agent/<spec-id>..agent/<spec-id>--<issue-id> --oneline` lists the COMMITS, and each GATES log exists.

- **DONE:** go to step 6.
- **BLOCKED:** put the QUESTION and its recommended answer to the user. Write their answer onto the spec (a question means the spec had a gap), then resume the same implementer with SendMessage to its agent ID, the answer as the message (load SendMessage through ToolSearch if it is deferred). Act on its next report.
- **FAILED**, or no report because it hit its turn cap: dispatch a fresh implementer on Opus into the same worktree and branch, with an ESCALATION line saying what stopped the last attempt. If the Opus attempt also fails, report to the user and stop.

## 6. Review

Call the Skill tool with "code-review", giving it the Issue as the spec and the diff as explicit refs, `git diff agent/<spec-id>...agent/<spec-id>--<issue-id>`, so it reviews ISSUE from whichever directory its sub-agents start in. Its sub-agents are the separate reviewer.

Send every finding that needs a change (a hard standards violation, a missing or wrong requirement, a judgement call you agree with) back to the same implementer with SendMessage, as one numbered list. It fixes, commits, reruns the gates and reports again; review again. The same implementer gets at most two fix rounds. When the review after its second round still has findings, dispatch a fresh implementer on Opus with the open findings as its ESCALATION, and give it the same two rounds. When its reviews still have findings after that, report to the user and stop.

Done when a review returns nothing you would send back.

## 7. Merge, close, clean up

```bash
git -C <feature-worktree> merge --no-ff agent/<spec-id>--<issue-id> -m "Merge <issue-id>: <issue title>"
```

On a textual conflict, call the Skill tool with "resolving-merge-conflicts". A conflict of meaning, where both sides are right and cannot both hold, goes to the user.

Run the repo's gates in the feature worktree, each logged under `$TMPDIR`. A gate that fails here goes back to an implementer as a finding, dispatched into the feature worktree.

Once the merge commit exists and the gates pass, close the Issue with the reason `Merged into agent/<spec-id> at <short sha>` (`bd --sandbox close <issue-id> --reason "..."` in beads). Then, from the main checkout, run `git worktree remove <issue-worktree>`. Keep both branches and the feature worktree.

Done when the Issue is closed, FEATURE holds the merge commit, and `git worktree list` no longer shows the ISSUE worktree.

## 8. Report

- The Issue, now closed, and its merge commit on `agent/<spec-id>`.
- The feature worktree's absolute path.
- Changed files: `git diff --stat <default-branch>...agent/<spec-id>`.
- Gate evidence from the feature worktree: each command, its result and its log path.
- Review rounds and what each changed, any Opus retry, the implementer's DEVIATIONS, and its DISCOVERED Issues.
- The commands for the user to run, marked as not run:

  ```bash
  git push -u origin agent/<spec-id>
  gh pr create --base <default-branch> --head agent/<spec-id>
  bd dolt push   # only in a beads repo that syncs its tracker remote
  ```
