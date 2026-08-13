# 03 — Move mobile bucket → `skills/team/mobile/` + establish team-tree conventions

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** The four KMP/CMP skills live in fork territory under a domain-grouped team tree, fully registered (project conventions, both READMEs, router, catalog, docs), and every installed skill still resolves under its unchanged name. This is the first slice through the full registration path — the template tickets 04–05 follow.

**Blocked by:** 01, 02.

**Status:** ready-for-agent

- [ ] The four mobile skills moved via `git mv` to the team tree's mobile domain; their docs pages moved under the mirrored fork docs tree
- [ ] CLAUDE.md's promoted-bucket rule names the team tree; registration requirements (bucket README, top-level README section, docs page, router re-sync) apply per team domain as they did for the mobile bucket
- [ ] Top-level README and the team bucket README list the moved skills, grouped User-/Model-invoked, names linked to each SKILL.md; all links valid
- [ ] The ask-matt router map reflects the new homes
- [ ] `catalog.yaml` updated; `CATALOG.md` regenerated
- [ ] Every live reference to the old paths is updated; dated historical documents (CHANGELOG, past specs/plans, out-of-scope records) untouched
- [ ] Re-running the linker resolves the identical skill-name set as before the move
- [ ] Full harness + forkcheck green
