# 01 — Seed the fork control plane + generated catalog

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** A maintainer can open one generated table (`CATALOG.md`) listing every skill with its origin (upstream/fork), domain, audience, and owner — and the fork's sync state (last-synced upstream SHA, every intentional divergence with its resolution recipe, the machine-readable sanctioned-edits list) lives in a `.fork/` control plane instead of prose.

**Blocked by:** None — can start immediately.

**Status:** done

- [x] `.fork/catalog.yaml` has an entry for every skill the list-skills script finds: origin (`upstream`|`fork`), domain, audience list, owner
- [x] `.fork/upstream.lock` records the current `upstream/main` SHA and ISO date
- [x] `.fork/divergence.md` has two sections — additions (sync-inert) and modifications/deletions (sync-active, each with a resolution recipe) — seeded from the MAINTENANCE.md fork table
- [x] `.fork/sanctioned-edits.txt` lists exactly the upstream paths that actually differ today (verify against `git diff upstream/main`), including the TDD append and the setup-skill rename divergence in their current form
- [x] A generator script produces `CATALOG.md` from `catalog.yaml`; running it twice is idempotent; `CATALOG.md` carries a do-not-hand-edit header
- [x] `CATALOG.md` is committed and its skill set matches the list-skills script's output
