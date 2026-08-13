# 05 — Extract the TDD KMP append → team mobile skill; restore upstream TDD verbatim

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** The KMP-specific TDD guidance is its own fork-owned, registered skill in the team mobile domain, cross-referencing upstream's TDD skill by name — and upstream's TDD skill is byte-identical to `upstream/main` again, retiring that divergence from the sanctioned list (the contract step CI now enforces).

**Blocked by:** 03.

**Status:** ready-for-agent

- [ ] A new team mobile skill carries the KMP TDD content currently appended to upstream's TDD skill, cross-referencing upstream's skill by name; content preserved, not rewritten
- [ ] Upstream's TDD SKILL.md restored byte-identical to `upstream/main`
- [ ] The TDD path removed from `sanctioned-edits.txt`; `divergence.md` updated (divergence retired, replaced by a fork addition)
- [ ] New skill registered everywhere: team bucket README, top-level README, docs page (four sections per writing-docs.md), router, catalog + regenerated CATALOG.md
- [ ] The confusable-skills check passes — the new skill's description does not compete with upstream TDD's trigger
- [ ] Linker re-run picks up the new skill; full harness + forkcheck green
