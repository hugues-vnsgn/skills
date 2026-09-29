---
name: implement-delegate
description: "Delegate a spec's Issues, or a single Issue, to fresh implementer subagents in their own worktrees, then review, merge and close each."
disable-model-invocation: true
metadata:
  internal: true
---

You orchestrate; implementers build. Each Issue goes to a fresh `implementer` subagent in its own worktree, a separate reviewer checks the result, and it lands on a feature branch as one `--no-ff` merge. Every code change, review and gate fixes included, goes through an implementer and a review.

Running this skill authorizes local commits and merges on `agent/` branches. Everything else that leaves the machine stays with the user: the final report hands them the push and PR commands. In beads, pass `--sandbox` on every `bd` write, so the tracker's remote is never synced either.

## Input

Resolve the argument to a **spec** and the Issues to build, reading every Issue in full, comments included, through the repo's issue-tracker doc (`bd show <id>` in beads):

- **A spec or epic ID** (an Issue with children): the spec is that Issue, and its child Issues are the graph, joined by their blocking edges.
- **A single Issue ID** (no children): the spec is its parent Issue, or the Issue itself when it has none. The graph is that one Issue, and every one of its blockers must already be closed.
- **No argument:** take the spec created earlier in this conversation, confirm its ID with the user, and treat it as a spec ID. With no such spec, ask for an ID.

A closed Issue counts as done, so a rerun picks up whatever is left. An open Issue claimed by `implementer-<issue-id>` was left by an earlier run and is yours to redispatch. Any other claim belongs to someone else: report it and stop.

## 1. Settle the context onto the spec

A fresh implementer sees the tracker, never this conversation. Write onto the spec Issue, as a note or comment, every decision, constraint or rejected option from this conversation that bears on any Issue in the graph. Check that the spec names the test seams each Issue builds through; where it names none, agree them with the user and write them onto the spec too.

Done when the spec carries every such decision and names every Issue's seams.

## 2. Pick the agent

`implementer-kmp` when the repo shows the Kotlin Multiplatform plugin, an Android app module, or an Xcode project; otherwise `implementer`. Decide from the markers, not the Issues' wording:

```bash
git grep -lE 'kotlin\("multiplatform"\)|org\.jetbrains\.kotlin\.multiplatform|com\.android\.application' -- '*.gradle*' '*.toml'
git ls-files | grep -E '\.(xcodeproj|xcworkspace)/' | head -1
```

If the chosen agent type is not available in this session, tell the user to run `scripts/link-agents.sh` in the skills repo and restart Claude Code, then stop.

## 3. Create the feature worktree

Two kinds of branch, named once here and used by these names below:

- **FEATURE**: `agent/<spec-id>`, branched from the local default branch so the user's unpushed commits are included. One per run.
- **ISSUE**: `agent/<spec-id>--<issue-id>`, branched from FEATURE's tip when the Issue is dispatched. One per Issue.

Each gets a worktree at the location the target repo's `AGENTS.md` / `CLAUDE.md` conventions give, along with the list of ignored local files (`local.properties`, `.env`, signing config) a build needs copied in. With no convention, use `.worktrees/<branch>` at the repo root, ignored locally first:

```bash
git check-ignore -q .worktrees/ || echo '/.worktrees/' >> "$(git rev-parse --git-common-dir)/info/exclude"
```

From the main checkout's root, create FEATURE's worktree, or check out the existing branch, or reuse a worktree already on it:

```bash
git worktree add <feature-worktree> -b agent/<spec-id> <default-branch>
git worktree add <feature-worktree> agent/<spec-id>
```

Copy the needed ignored files in. Done when the feature worktree exists with the build's local files, and you hold its absolute path.

## 4. Walk the graph

The **frontier** is every open Issue in the graph whose blockers are all closed, less any Issue already in the ledger (`bd ready --parent <spec-id>` in beads, plus open Issues an earlier run's implementer left claimed; for a single Issue, just that Issue). Build it out Issue by Issue, running each through 4a to 4e.

- **At most two slots.** An Issue holds a slot from its dispatch until it is closed or marked failed, through its reviews, BLOCKED questions and merge gates. Two implementers building, or one building while FEATURE's gates run, is the most a machine carries: parallel builds exhaust memory past that, Gradle and Kotlin/Native worst of all.
- **Pair only Issues that stay apart.** Before dispatching an Issue beside one already holding a slot, compare their descriptions: the same file, module, screen, schema or public interface named or implied by both means it waits for the other to close. When unsure, wait.
- **Recompute the frontier** after every close, and fill each free slot from it.
- **Keep a ledger** in your working notes: per Issue, its agent ID, worktree, branch, start commit, state, review round and whether it is on Opus. The run spans many background notifications; the ledger is how you know who to resume.

The walk is done when every Issue in the graph is closed, or when the frontier is empty, no slot is held, and open Issues remain (blocked outside the graph, or behind an Issue that failed): list those for the report and go on to step 5.

### 4a. Worktree, brief, dispatch

Create the Issue's worktree off FEATURE's current tip, copy the ignored files in, and record that tip in the ledger as the Issue's **start** commit:

```bash
git worktree add <issue-worktree> -b agent/<spec-id>--<issue-id> agent/<spec-id>
```

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

Dispatch with the Agent tool in the background: the variant from step 2 as `subagent_type`, `model: "opus"` when the Issue carries the `model:opus` label (otherwise leave the model unset so the agent's default applies), the brief as the prompt. Done when the agent ID is in the ledger. Leave the worktree to the implementer until it reports.

### 4b. Act on the report

The report arrives in the implementer's fixed contract. Before acting on it, check its claims: `git log <start>..<brief's BRANCH> --oneline` lists the COMMITS, and each GATES log exists.

- **DONE:** go to 4c.
- **BLOCKED:** put the QUESTION and its recommended answer to the user. Write their answer onto the spec (a question means the spec had a gap), then resume the same implementer with SendMessage to its agent ID, the answer as the message (load SendMessage through ToolSearch if it is deferred). Act on its next report.
- **FAILED**, or no report because it hit its turn cap: dispatch a fresh implementer on Opus into the same worktree and branch, with an ESCALATION line saying what stopped the last attempt. When the Opus attempt also fails, the Issue has **failed on Opus**: mark it failed in the ledger, release its slot, tell the user, and carry on with the Issues that do not depend on it.

### 4c. Review

Call the Skill tool with "code-review", giving it the Issue as the spec and the diff as explicit refs, `git diff <start>...<brief's BRANCH>`, so it reviews the right commits from whichever directory its sub-agents start in. Its sub-agents are the separate reviewer.

Send every finding that needs a change (a hard standards violation, a missing or wrong requirement, a judgement call you agree with) back to the same implementer with SendMessage, as one numbered list. It fixes, commits, reruns the gates and reports again; review again. The same implementer gets at most two fix rounds. When the review after its second round still has findings, dispatch a fresh implementer on Opus with the open findings as its ESCALATION, and give it the same two rounds. When its reviews still have findings after that, the Issue has failed on Opus, as in 4b.

Done when a review returns nothing you would send back.

### 4d. Merge

Merge only while FEATURE's last gates passed and no FEATURE fix (4f) is running, since that implementer commits in the feature worktree:

```bash
git -C <feature-worktree> merge --no-ff agent/<spec-id>--<issue-id> -m "Merge <issue-id>: <issue title>"
```

On a textual conflict, call the Skill tool with "resolving-merge-conflicts". A conflict of meaning, where both sides are right and cannot both hold, goes to the user.

Run the repo's gates in the feature worktree, each logged under `$TMPDIR`: later Issues branch from this tip, so it has to build. When a gate fails, fix FEATURE through 4f, with the failing gate's command and log as the findings, before this Issue closes and before any new Issue branches from FEATURE.

Done when FEATURE holds the merge commit and its gates pass.

### 4e. Close and clean up

Close the Issue with the reason `Merged into agent/<spec-id> at <short sha>` (`bd --sandbox close <issue-id> --reason "..."` in beads). Then, from the main checkout, run `git worktree remove <issue-worktree>`. Keep both branches.

Done when the Issue is closed, its slot is free, and `git worktree list` no longer shows its worktree.

### 4f. Fix on FEATURE

Findings that belong to FEATURE as a whole (a gate broken by a merge, or the whole-branch review in step 5) get one fix, built on FEATURE itself:

1. File one Issue under the spec, titled for what it fixes (`Fix gates after merging <issue-id>`, `Fix whole-branch review findings`), with the findings as a numbered list in its description.
2. Take a slot: a gate fix inherits the slot of the Issue whose merge broke FEATURE, and the whole-branch fix finds every slot free. Record FEATURE's tip as its start commit, and dispatch a fresh implementer as in 4a, with WORKTREE the feature worktree, BRANCH FEATURE and BASE the default branch. Hold every merge and every new ISSUE branch until this Issue closes.
3. Run it through 4b and 4c. It commits on FEATURE directly, so there is no merge: run the repo's gates in the feature worktree, each logged under `$TMPDIR`, and close it once they pass.

When it fails on Opus, FEATURE cannot be trusted: stop dispatching, let in-flight Issues report without merging them, and go to step 6.

## 5. Review the whole branch

Skip this step when nothing merged, or when FEATURE is exactly one Issue's merge on top of the default branch: 4c already reviewed that diff.

Call the Skill tool with "code-review", giving it the spec as the spec and the diff as explicit refs, `git diff <default-branch>...agent/<spec-id>`. It catches what no per-Issue review could see: seams that disagree across Issues, duplication between them, a requirement that fell between two.

Send every finding that needs a change through 4f as one fix. This review runs once: the fix-up's own review in 4c covers only its diff.

Done when the fix-up Issue is closed, or the review found nothing to change.

## 6. Report

- The spec, left open for the user to close once the work lands, and every Issue in the graph with its state: closed with its merge commit, failed on Opus, or still open and why.
- The feature worktree's absolute path.
- Changed files: `git diff --stat <default-branch>...agent/<spec-id>`.
- Gate evidence from the feature worktree's last run: each command, its result and its log path.
- Per Issue: review rounds and what each changed, any Opus retry, DEVIATIONS, and DISCOVERED Issues. Then every FEATURE fix, the whole-branch findings, and what each fix changed.
- The commands for the user to run, marked as not run:

  ```bash
  git push -u origin agent/<spec-id>
  gh pr create --base <default-branch> --head agent/<spec-id>
  bd dolt push   # only in a beads repo that syncs its tracker remote
  ```
