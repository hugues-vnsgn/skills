---
name: sync-upstream
description: "Merge mattpocock/skills into this fork: read the delta, resolve conflicts by recipe, assert the boundary, advance the lock, and land the sync PR. Run when upstream has commits this fork does not."
disable-model-invocation: true
metadata:
  internal: true
---

# Sync upstream

[`.fork/sync-playbook.md`](../../../../.fork/sync-playbook.md) is the procedure: nine numbered steps and every command you will type. Read it and follow it. This skill does not repeat it.

What this skill adds is the part that does not fit in a numbered list. How to read the delta, how to classify a conflict before touching it, what to do when upstream rewrites prose the fork had also rewritten, and the handful of failures that look like breakage and are not.

Every conflict recipe lives in [`.fork/divergence.md`](../../../../.fork/divergence.md). Apply the recipe written there rather than re-deriving it. The point of the record is that the same conflict resolves the same way every time.

**Read [Gotchas](#gotchas) before you start, not when something fails.** One of them is an ordering trap in the playbook itself: step 6 runs a test that cannot pass until step 8 has run, so working the steps in order produces three failures that are not real.

## Read the delta before you branch

Playbook step 2 hands you `git log` and `git diff --stat` over `<lock>..upstream/main`. Four things to look for, and one the playbook does not name:

- **New skills.** Each one owes a `catalog.yaml` entry, and its `audience` roles owe an edit to their role page.
- **Renamed or removed skills.** Every cross-reference that cites them by name now points at nothing, including `ask-matt`.
- **Touches to paths in `sanctioned-edits.txt`.** That is your conflict list, known before you merge rather than discovered during it.
- **A new upstream skill whose basename collides with a fork skill.** Decide the rename now, not mid-conflict.
- **A repo-wide sweep.** A diffstat touching nearly every file on a small commit count is a style or convention change, not feature work. The 2026-08-20 sync was 14 commits across 104 files because upstream removed every em-dash in the repo and made it a house rule. Recognise it here and you decide it once, as policy. Miss it and you meet it 22 times, as a surprise.

A sweep that introduces a new house rule is also a decision the fork has to make: adopt it for fork-owned prose, or not. Put that to the user before resolving anything, because the answer changes every prose hunk you are about to touch.

## Classify every conflict before resolving any

```bash
git status --short | grep -E '^(UU|AA|DU|UD|DD|AU|UA)'
```

Sort each path into one of three buckets, and do not start resolving until every path is in one.

**In the residual conflict surface** (the table at the end of the playbook). Apply its `divergence.md` recipe. Two shapes cover most of them: modify/delete, where upstream edited a file this fork deleted, resolved by keeping the deletion; and both-modified prose, resolved by keeping both sides.

**Not in the table.** Stop. Do not resolve it yet. Either the fork acquired a divergence nobody recorded, or upstream started writing a path the fork thought was its own. `git log upstream/main -- <path>` settles which: commits there mean the path is upstream's and the fork drifted onto it, while silence means the fork placed something in upstream territory without recording it. Then land the record, a `divergence.md` row plus a `sanctioned-edits.txt` line plus the matching row in the playbook's table, as part of this sync. The next maintainer should meet a documented conflict instead of your surprise.

**A fork-owned path conflicted.** `skills/house/`, `docs/house/`, `docs/roles/`, `research/`, `scripts/harness/` and `.fork/` are paths upstream has never written, so a merge cannot conflict there on its own. If one does, git followed a rename: a file the fork re-homed out of upstream territory is still recognisably upstream's. That is a real merge and usually the outcome you want, but verify it (see Gotchas).

## Resolving a repo-wide sweep

"Keep both" is the recipe for the fork's appended sections. It is the wrong answer when upstream has rewritten the very sentence the fork rewrote for its own reasons. Decide per hunk:

- The fork had **not** rewritten this passage: take upstream's version, then re-apply the fork's substitutions (the setup skill's name, `osxsystem` links, fork-local paths).
- The fork **had** rewritten this passage, because the plugin route is gone or the house tree exists: keep the fork's. Upstream's edit was stylistic and applies to text this fork no longer carries.

Verify per file rather than trusting the resolution:

```bash
git show upstream/main:<path> > /tmp/u && diff /tmp/u <path>
```

Each sanctioned file should differ from upstream by exactly its documented divergence and nothing more. After the 2026-08-20 sync, `skills/engineering/README.md` differed by one omitted line and `triage/SKILL.md` by one skill name, which is what the record says they should be. A diff larger than its `divergence.md` row is drift you just introduced. A diff smaller than it means a fork change was lost.

**Do not adopt the new house style into fork-owned prose on this branch.** A sync branch carries reconciliation and nothing else, so a reviewer can read every non-upstream hunk as a conflict resolution. Adopt the rule where it lands (`CLAUDE.md`), keep upstream territory clean, and file the sweep of fork prose as a follow-up off `main`.

## Gotchas

Every one of these looked like breakage during the 2026-08-20 sync.

**`test_forkcheck.sh` fails right after the merge.** Its "clean tree" fixture runs `forkcheck` with the *default* upstream ref, which is the SHA in `upstream.lock`, and the merge just made that stale. Three failures, none real. Advance the lock (playbook step 8) and re-run: it returns to `pass=25 fail=0`. Do step 8 before this test, not after it.

**`gh pr create` fails with "must be a collaborator."** `git push` and `gh` authenticate separately. The push goes over SSH while `gh` may be active as an account with only READ here. Check with `gh auth status`, switch with `gh auth switch -u <account>`, and switch back once the PR is merged so the machine is left as you found it. Every `gh` command here also needs `--repo hugues-vnsgn/skills`, `create` and `merge` alike, or it addresses the wrong repository.

**The PR must land as a merge commit.** `gh pr merge --merge`, never `--squash` or `--rebase`. The lock's invariant is that `upstream_sha` is an ancestor of `main`. Squashing collapses the merge, breaks that, and makes the next sync replay everything already merged. Confirm after landing:

```bash
git merge-base --is-ancestor "$(awk '/^upstream_sha:/ {print $2}' .fork/upstream.lock)" main && echo ok
```

Say so in the PR body too, so nobody lands it from the web UI with the wrong button.

**Rename detection is doing you a favour.** Upstream's edits to a file this fork re-homed, such as `setup-matt-pocock-skills` into `skills/house/platform/setup-osxsystem-skills`, arrive merged into the fork's copy rather than as a modify/delete. Take them, then confirm the only differences left are the intended ones:

```bash
git show upstream/main:<upstream-path> | diff - <fork-path>
```

Expect the name and the home to differ and nothing else. In the 2026-08-20 sync this carried in a YAML frontmatter fix nobody would have ported by hand.

**A changeset the fork already released conflicts.** `changeset version` consumes changesets, so one this fork has shipped is deleted here while still live upstream, and a later upstream edit to it arrives as modify/delete. Keep the deletion. Its content is already in `CHANGELOG.md`, and restoring it re-releases shipped work.

## Done when

- Every conflict traces to a `divergence.md` recipe, or to a record landed in this sync.
- Every command in the playbook's step 6 block green, with `forkcheck` run twice: once as `--upstream-ref upstream/main`, and once with no argument, against the newly advanced lock.
- `upstream.lock` and the "Last verified" line in `sanctioned-edits.txt` both name the merged SHA and its date.
- Imported changesets renamed to `osxsystem-skills`.
- New upstream skills catalogued, `CATALOG.md` regenerated, and every role page their `audience` names updated by hand.
- The PR body carries the upstream range, the conflicts resolved and by which recipe, any change to `sanctioned-edits.txt`, and the skills catalogued.
- PR merged as a merge commit, and `scripts/link-skills.sh` re-run on each machine.

---

For the mechanics of an individual conflicted file, the `/resolving-merge-conflicts` skill applies. Where the two disagree, this repo's recipes win: they encode which side owns the bytes, which a general resolver cannot know.
