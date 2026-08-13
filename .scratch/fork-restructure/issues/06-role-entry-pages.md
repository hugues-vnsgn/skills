# 06 — Per-role entry pages under `docs/roles/`

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** A designer, BA, QA engineer, staff engineer, or software engineer opens one page and sees their skills in a curated reading order, each linking to the skill's docs page (or SKILL.md where no docs page exists) — spanning both trees, without needing to understand provenance or folder taxonomy.

**Blocked by:** 04, 05.

**Status:** done

- [x] Five pages: engineer, designer, analyst, qa, staff — each a short curated, *ordered* list with a one-line "why you'd reach for it" per entry
- [x] Audience assignments come from `catalog.yaml` (single source of truth), not invented per page; shared skills appear on every role page whose audience list names them
- [x] Links point at final post-move homes; all links valid
- [x] No docs page is invented for non-promoted skills — role pages link those straight to SKILL.md
- [x] Role pages are reachable: linked from the top-level README's reference section
- [x] Full harness + forkcheck green
