---
"osxsystem-skills": patch
---

Move the repo from the `osxsystem` GitHub account to `hugues-vnsgn`, and rewrite every reference that is a *coordinate* rather than an identity or a record.

**Install commands change.** The canonical whole-set and single-skill commands now read `npx skills@latest add hugues-vnsgn/skills`, and the skills.sh URL follows. Anyone who installed from the old address should re-add from the new one; the old repository is being retired, so no redirect covers it.

**What deliberately did not change.** The package is still named `osxsystem-skills`, its description still says "osxsystem team", and the published `setup-osxsystem-skills` skill keeps its name. An account move is not a rebrand, and renaming a published skill would cost every consumer a reinstall. Searching the repo for the old account name therefore still returns well over a hundred hits, and that is correct.

**Changelog links.** The three link classes in `CHANGELOG.md` did not have the same right answer. The 19 commit links were repointed to the new address, where they resolve, because every commit was carried over. The 14 pull-request links were de-linked to plain `#N` text, because those pull requests exist at neither address and each already sits beside a commit link that does resolve. The 4 issue links turned out to reference upstream issue numbers that never existed in this repo, so they were repointed at `mattpocock/skills`, fixing links that were broken before this change.

**New guard.** `skillcheck.py` gains `no-stale-repo-coordinates`, which asserts the old account appears only inside a recorded allowlist, and `coordinate-scan-readable`, which fails closed when a file cannot be read. `scripts/harness/test_coordinates.sh` proves both, including that a stale string inside the allowlist still passes. The distinction between a coordinate and an identity string is now executable rather than remembered.

**CI gap closed.** `scripts/generate-catalog.py --check` has always existed but was never called by the workflow, so a stale `CATALOG.md` drifted silently. It now runs alongside the installer-manifest check. This change is what surfaced it: rewriting 53 `owner:` fields in the catalog source left the generated catalog stale with nothing to catch it.
