---
"osxsystem-skills": patch
---

Teach `forkcheck` and `skillcheck` to skip nested worktrees, found by smoke testing `use-git-worktree` against this repo.

Creating `.worktrees/feat/<slug>` put a full checkout of `main` inside the repo, and three repo-wide assertions walk the tree with `os.walk` rather than asking git what is tracked. They found every file twice and reported the copy against the original: `plugin-dir-marketplace-only` flagged the worktree's own root `.claude-plugin/` as a forbidden second plugin directory, while `no-stale-repo-coordinates` and `no-stale-tree-name` flagged the `.scratch/` records and `CHANGELOG.md` entries that legitimately exist at that commit. Four checks failed across the two scripts, `test_forkcheck.sh` dropped to 23/26, and none of it was real drift.

`skillcheck.py` gains a `WALK_SKIP_DIRS` constant shared by both of its walks, and `.worktrees/` joins `COORDINATE_SKIP`. `forkcheck.py`'s plugin walk gains the same two entries. Both now also skip `.claude/`, which is where a harness puts a worktree when it picks the location itself: `skillcheck`'s comment already claimed "a second working tree" was never scanned, and that was true only of the coordinate walk, not the plugin walk beside it.

The wider skip list does not soften the guards. A stray `.claude-plugin/` planted at `docs/.claude-plugin/` and a pre-rename tree reference planted at `docs/stray-probe.md` are both still caught, and both scripts return to PASS once removed. Writing that second probe out longhand here would trip `no-stale-tree-name` on this very file, which is its own small proof the guard reaches changeset prose.
