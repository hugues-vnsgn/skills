# 08 — Integrate-and-verify + changeset

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** Proof the migration is complete and invisible at the invocation layer: the whole validation suite is green, no live file references a pre-move path, the linker resolves the identical skill-name set as before the migration (plus the one new TDD-for-KMP skill), and the restructure is recorded in the version history.

**Blocked by:** 06, 07.

**Status:** done

- [x] Full harness (skillcheck, yamlcheck, confusable-skills) + forkcheck green
- [x] Repo-wide grep proves zero live references to any pre-move path — excluding dated historical documents (CHANGELOG, past specs/plans, out-of-scope records) and this ticket tree
- [x] Linker re-run resolves exactly the pre-migration skill-name set plus the new TDD-for-KMP skill; no name resolves from two locations
- [x] The router names every user-reachable skill at its final home; spot-check by following each route link
- [x] One changeset documents the restructure (tree change, control plane, CI guard, no skill renamed)
- [x] Parent spec's Status updated to reflect completion; ticket files' checkboxes all ticked
