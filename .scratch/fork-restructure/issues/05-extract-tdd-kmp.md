# 05 — Extract the TDD KMP append → team mobile skill; restore upstream TDD verbatim

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** The KMP-specific TDD guidance is its own fork-owned, registered skill in the team mobile domain, cross-referencing upstream's TDD skill by name — and upstream's TDD skill is byte-identical to `upstream/main` again, retiring that divergence from the sanctioned list (the contract step CI now enforces).

**Blocked by:** 03.

**Status:** done

- [x] A new team mobile skill carries the KMP TDD content currently appended to upstream's TDD skill, cross-referencing upstream's skill by name; content preserved, not rewritten
- [x] Upstream's TDD SKILL.md restored byte-identical to `upstream/main`
- [x] The TDD path removed from `sanctioned-edits.txt`; `divergence.md` updated (divergence retired, replaced by a fork addition)
- [x] New skill registered everywhere: team bucket README, top-level README, docs page (four sections per writing-docs.md), router, catalog + regenerated CATALOG.md
- [x] The confusable-skills check passes — the new skill's description does not compete with upstream TDD's trigger
- [x] Linker re-run picks up the new skill; full harness + forkcheck green

**Resolution:** the extracted skill is `kmp-test-seams` (`skills/team/mobile/kmp-test-seams/`). Its body carries the moved paragraph byte-for-byte; the framing around it defers the loop itself to `tdd` by name. `skills/engineering/tdd/SKILL.md` is back to blob `ead7781` — the upstream blob at the `upstream.lock` SHA — and its path is gone from `sanctioned-edits.txt`. `divergence.md` gains a `## Retired divergences` section recording the extraction so nobody re-appends. Two stale live references were corrected in passing: `CUSTOMIZING.md` (which cited the append as its worked example) and `docs/engineering/ask-matt.md` ("four" platform references → five). tdd ↔ kmp-test-seams description Jaccard is 0.023, against a 0.80 threshold.
