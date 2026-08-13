# 04 — Move platform skills → `skills/team/platform/` + sanction the setup-skill deletion

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** After this ticket, no fork-authored skill lives in upstream territory — provable by forkcheck. The setup skill, port-from-repo, and when-stuck are re-homed under the team tree's platform domain with all live references fixed, and the setup-skill rename divergence is converted to a recorded, sanctioned deletion of upstream's copy.

**Blocked by:** 03.

**Status:** ready-for-agent

- [ ] `setup-osxsystem-skills` (name and content unchanged, per the approved 2026-08-06 rename spec), `port-from-repo`, and `when-stuck` moved via `git mv` to the platform domain
- [ ] Upstream's `setup-matt-pocock-skills` recorded in `divergence.md` as a sanctioned deletion, with the same modify/delete resolution recipe as the plugin directory; `sanctioned-edits.txt` updated to the deletion form
- [ ] All live references to the old paths updated (~60 occurrences); dated historical documents untouched, per the rename spec's precedent
- [ ] READMEs, router, catalog, and docs pages updated for the new homes (when-stuck stays beta: no docs page, flat-list README entry)
- [ ] Re-running the linker resolves the identical skill-name set as before; exactly one setup skill is linked
- [ ] Full harness + forkcheck green, including forkcheck proving upstream buckets contain no fork skills
