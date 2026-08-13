# 07 — Ownership + sync playbook

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** PR approval authority is mechanical (CODEOWNERS routes each team domain to its discipline, upstream buckets and the control plane to maintainers), and an upstream sync is a documented, repeatable procedure — merge-only, sync-only PRs, rerere-assisted — whose entire expected conflict surface is enumerated and matches the divergence record.

**Blocked by:** 04, 05.

**Status:** done

- [x] CODEOWNERS: one line per existing team domain mapped to that discipline's team; one maintainers line covering the upstream buckets and the control plane
- [x] MAINTENANCE.md slimmed to narrative; the mechanical sync checklist moves to the control plane and MAINTENANCE.md points at it
- [x] The sync procedure is codified step-by-step: fetch, delta review against the lock, sync-only branch, merge (never rebase), boundary assertions, lock advance, catalog additions for new upstream skills
- [x] rerere enablement documented as one-time setup for the recurring prose conflicts
- [x] The residual conflict surface is enumerated and exactly matches divergence.md's sync-active section; anything outside it is documented as stop-and-investigate
- [x] Promotion of an upstream skill to the team is documented as a catalog/docs edit, never a file move
