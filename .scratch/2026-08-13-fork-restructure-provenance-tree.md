# Restructure the fork into a provenance-split tree (`skills/team/`)

**Date:** 2026-08-13
**Status:** Done — all 8 tickets complete (verified 2026-08-13: full harness + forkcheck green, zero live pre-move path references, linker resolves 42 unique names, router re-synced, changeset written)
**Labels:** ready-for-agent
**Tracker:** local `.scratch/` markdown (GitHub Issues disabled on this repo)

## Problem Statement

The repo's folder structure is engineer-centric and conflates two unrelated concerns: *who owns the bytes* (upstream `mattpocock/skills` vs. this fork) and *who the skill is for* (engineers, designers, BAs, QAs). Concretely:

- Fork-authored skills are scattered through upstream territory (`port-from-repo` inside the engineering bucket, `when-stuck` inside the in-progress bucket), so nothing in the tree tells a maintainer — or a merge — which files upstream may rewrite.
- Fork content lives *inside* upstream files (the KMP section appended to the upstream TDD skill; the renamed setup skill), guaranteeing a merge conflict every upstream sync, forever.
- A designer, BA, or QA engineer cloning the repo has no entry point: bucket names describe upstream's technical layering, not the team's domains, and no view answers "which skills are for me?".
- The sync checklist is prose in MAINTENANCE.md with no machine enforcement — nothing fails CI if a sync silently drifts an upstream file or resurrects the deleted plugin directory.
- As the collection grows toward cross-functional domains (design, discovery, quality), there is nowhere conflict-free to put new skills or assign ownership for PR approval.

## Solution

Split the tree by **provenance**, group the fork's half by **domain**, and serve **roles** through docs and metadata:

- Upstream buckets (engineering, productivity, misc, in-progress, deprecated) become byte-frozen vendor territory — never moved, renamed, or edited, with the short list of deliberate divergences enumerated in a machine-readable sanctioned-edits list.
- All fork-authored skills move under a single fork-owned tree, `skills/team/`, grouped by capability domain (`mobile/`, `platform/` now; `design/`, `discovery/`, `quality/` as skills arrive). Upstream never writes there, so it is structurally conflict-free and safe to reorganize at will.
- A fork control plane (`.fork/`) holds the sidecar taxonomy (`catalog.yaml`: origin, domain, audience, owner per skill), the last-synced upstream SHA (`upstream.lock`), the divergence record, and the sanctioned-edits list. A generated `CATALOG.md` renders the single-table view.
- Per-role entry pages under `docs/roles/` give each discipline a curated reading order linking into both trees — the folder layout stays a maintainer concern.
- A new `forkcheck` guard joins the existing CI validate job and enforces the boundary: upstream paths identical to `upstream/main` modulo sanctioned edits, no duplicate skill names across the flat install namespace, catalog completeness, plugin directory absent.
- The two in-file divergences are retired: the TDD KMP append is extracted into a fork-owned mobile skill, and the setup-skill rename divergence is converted to a sanctioned deletion of upstream's copy (the approved fork name and content are unchanged, only re-homed).

## User Stories

1. As a fork maintainer, I want upstream buckets to be byte-identical to `upstream/main` except for an enumerated sanctioned list, so that an upstream sync is a merge plus assertions instead of an act of curation.
2. As a fork maintainer, I want every fork-authored skill to live under a tree upstream never writes to, so that no future upstream commit can collide with team work.
3. As a fork maintainer, I want new upstream skills to land in their upstream bucket and stay there, so that I never re-home vendor files after a sync.
4. As a fork maintainer, I want the KMP TDD guidance out of the upstream TDD skill and into a fork-owned skill, so that upstream edits to TDD merge cleanly.
5. As a fork maintainer, I want the setup-skill rename recorded as a sanctioned deletion of upstream's copy, so that the approved `/setup-osxsystem-skills` name survives while the recurring rename conflict is retired.
6. As a fork maintainer, I want CI to fail when an upstream path drifts outside the sanctioned list, so that boundary violations are caught at PR time, not at the next sync.
7. As a fork maintainer, I want CI to fail when two skills anywhere in the tree share a directory basename, so that the flat install namespace can never silently shadow one skill with another.
8. As a fork maintainer, I want CI to fail if the deleted plugin directory reappears, so that the ADR-recorded decision to ship via skills.sh only is enforced, not just documented.
9. As a fork maintainer, I want the last-synced upstream SHA recorded in the control plane, so that "what changed since last sync" is a single git log command.
10. As a fork maintainer, I want every intentional divergence recorded with its resolution recipe, so that a future maintainer resolves the same conflict the same way without re-deriving the reasoning.
11. As a fork maintainer, I want sync PRs to contain only reconciliation, so that reviewers can tell conflict resolutions from feature changes.
12. As a UI/UX designer, I want a role page listing the skills relevant to design work in reading order, so that I can find my tools without learning the repo's folder taxonomy.
13. As a business analyst, I want a role page for discovery/analysis skills, so that I know which skills to invoke without asking an engineer.
14. As a QA engineer, I want a role page for quality skills, so that I can adopt the workflow without reading the whole catalog.
15. As a staff engineer, I want a domain folder with a clear owner for each discipline, so that I can route a new skill idea to the right home and approver.
16. As a designer contributing a skill, I want an obvious contribution target (`skills/team/design/`), so that filing a PR doesn't require understanding upstream provenance.
17. As a domain owner, I want CODEOWNERS to map one line per team domain folder, so that PR approval authority is unambiguous.
18. As a repo maintainer, I want upstream buckets covered by a maintainers-only CODEOWNERS line, so that edits to vendor territory always get a sync-aware review.
19. As any team member, I want a generated catalog table of every skill with origin, domain, and audience, so that one page answers "what exists and who is it for".
20. As any team member, I want a skill to carry multiple audiences in metadata, so that shared skills (code review, ticket writing) are discoverable by every role they serve, not just one folder's.
21. As an agent following the router, I want the router skill re-synced after the moves, so that its map of user-reachable skills doesn't point at stale homes.
22. As a skill user on any machine, I want the linker re-run after the migration to relink identical skill names from their new paths, so that installed skills keep working with no rename.
23. As a future maintainer, I want dated historical documents (changelog, past specs, out-of-scope records) left untouched by the path migration, so that the historical record stays true.
24. As a future maintainer, I want the promoted-bucket conventions in the project instructions updated to name the team tree, so that registration rules (READMEs, docs pages, router) stay accurate after the move.
25. As a fork maintainer, I want the mobile docs tree to move with the mobile skills into a fork-docs tree, so that docs organization mirrors skill provenance the same way.
26. As a fork maintainer, I want conflict resolutions for the recurring prose files remembered by git (rerere), so that repeat syncs self-resolve what was resolved once.
27. As a release maintainer, I want the restructure captured in a changeset, so that the version record explains the tree change to consumers.

## Implementation Decisions

- **Two-territory layout.** Upstream buckets (`engineering`, `productivity`, `misc`, `in-progress`, `deprecated`) are frozen vendor territory. All fork skills live under `skills/team/`, grouped by capability domain. Domain folders are created when their first skill lands — no empty growth slots.
- **Initial domains:** `team/mobile/` (the four KMP/CMP skills plus the new TDD-for-KMP skill) and `team/platform/` (`setup-osxsystem-skills`, `port-from-repo`, `when-stuck`). `design/`, `discovery/`, `quality/` are named in the catalog schema but not created yet.
- **TDD append extraction.** The KMP section currently appended to upstream's TDD skill becomes a standalone fork skill in `team/mobile/`; upstream's TDD skill is restored verbatim. The new skill cross-references upstream's by name.
- **Setup skill.** The fork's `setup-osxsystem-skills` (name and content per the approved 2026-08-06 rename spec) moves to `team/platform/` unchanged. Upstream's `setup-matt-pocock-skills` remains deleted, recorded as a sanctioned deletion with the same modify/delete resolution recipe as the plugin directory. Rationale: restoring it would double-link two setup skills, since the linker links every non-deprecated skill and may not be modified.
- **Fork control plane** (`.fork/`): `catalog.yaml` (per-skill sidecar: origin upstream|fork, domain, audience list, owner team); `upstream.lock` (SHA + date, advanced every sync); `divergence.md` (two sections — additions, which are sync-inert, and modifications/deletions, which are sync-active with resolution recipes); `sanctioned-edits.txt` (the only upstream paths allowed to differ, consumed by CI). Upstream frontmatter is never edited to carry taxonomy — sidecar only.
- **Generated catalog.** `CATALOG.md` at the repo root is generated from `catalog.yaml`; it is the one-table view and must never be hand-edited.
- **Docs.** Upstream docs buckets stay as-is. Mobile docs pages move under a fork docs tree mirroring `skills/team/`. New `docs/roles/` pages (engineer, designer, analyst, qa, staff) each carry a curated, ordered list of links into docs pages across both trees. Published-URL convention (`aihero.dev/skills-<name>`) is unaffected: docs paths remain repo organization only, and fork-local pages are never hosted there.
- **Ownership.** CODEOWNERS gains one line per `team/<domain>/` mapped to that discipline's GitHub team, plus a maintainers line covering the upstream buckets and the control plane.
- **Sync workflow codified:** merge-only (never rebase), sync-only PRs, `rerere` enabled for the recurring prose conflicts (top-level README, project instructions), lock file advanced per sync. MAINTENANCE.md slims to narrative and points at the control plane for the mechanical checklist.
- **Reference migration.** All live references to moved paths (~214 occurrences) are updated mechanically. Following the rename-spec precedent, dated historical documents — changelog, past specs/plans, out-of-scope records — are excluded: a dated document describes the tree as it was.
- **Conventions update.** Project instructions (CLAUDE.md) are updated so the promoted-bucket rule names the team tree, and registration requirements (bucket README, top-level README section, docs page, router re-sync) apply per team domain exactly as they did for the mobile bucket.
- **Router re-sync.** The router skill's map is updated for the new homes and the new TDD-for-KMP skill, per the existing convention that any add/rename/move re-syncs it.
- **Unchanged:** the linker script (header forbids modification; it is path-agnostic and needs none), skill names (no installed skill is renamed, so user-facing invocations are stable), the release workflow, and all skill content except the TDD append extraction.
- **Changeset:** one changeset documents the restructure.

## Testing Decisions

- **What makes a good test here:** assertions over externally observable repo state — the tree's layout, its diff against `upstream/main`, and generated artifacts — never over script internals. A check should fail closed: if it cannot fetch upstream or parse the catalog, it fails rather than passes vacuously (precedent: the harness's existing guardrail test, which tests that the checks themselves fail when they should).
- **Single seam:** the existing CI validate job. One new guard script (`forkcheck`, living beside the existing harness scripts) is invoked from that job; no new workflow. The job gains one step to fetch the upstream remote, which a default CI checkout lacks.
- **Assertions forkcheck owns:** (1) upstream buckets byte-identical to `upstream/main` modulo `sanctioned-edits.txt`; (2) no duplicate skill directory basenames anywhere in the tree; (3) catalog completeness both ways — every skill has a catalog entry, every entry has a skill; (4) the plugin directory is absent.
- **Modules tested:** the guard script itself gets a fail-closed test in the style of the existing guardrail test (assert it *fails* on a seeded violation of each invariant).
- **Prior art:** the existing skill-validation harness (skillcheck, yamlcheck), the confusable-descriptions check, and the guardrail shell test — forkcheck follows their conventions (python3, no third-party deps, runs anywhere).
- **Migration verification:** after the moves, the existing full-harness run plus a repo-wide grep proving no live file references a pre-move path (excluding the dated historical documents), and a linker dry-run confirming the same set of skill names resolves as before the migration.

## Out of Scope

- Authoring any design, discovery, or quality skills — this spec creates the *capacity* (schema, ownership, docs slots), not the content. Their domain folders are created when the first skill lands.
- Changing the behavior, prompts, or content of any existing skill (sole exception: extracting the TDD KMP append into its own skill).
- Contributing anything upstream, or changing how upstream organizes its half.
- Modifying the linker script.
- A registry/search UI over the catalog — `CATALOG.md` generation is the ceiling here.
- Rewriting dated historical documents to use post-move paths.
- Migrating to `git subtree` vendoring. Revisit trigger: the sanctioned-edits list growing rather than shrinking across two consecutive syncs.
- Enabling GitHub Issues or standing up an external issue tracker.

## Further Notes

- **Migration shape:** the moves, reference fixups, control-plane seed, and CI wiring should land as one PR (moves via `git mv` to preserve history), followed immediately by a linker re-run on each machine. No installed skill name changes, so the migration is invisible at the invocation layer.
- **Residual conflict surface after this spec:** top-level README and CLAUDE.md (appended fork sections — rerere absorbs them), plus the two sanctioned deletions. That is the entire expected conflict set for future syncs; anything else appearing in a merge is a signal to stop and investigate.
- **Name-collision hazard is permanent:** folders don't fix the flat install namespace. If upstream ever ships a skill named like a fork skill (e.g. a future upstream `when-stuck`), the duplicate-basename check turns a silent nondeterministic shadowing into a CI failure with a rename decision.
- **Scorecard context:** the provenance-first pattern was selected over role-based folders, whole-tree domain folders, and a flat namespace; the deciding criterion was recurring upstream-sync cost, which only this pattern avoids. The evaluation lives in the conversation that produced this spec; the durable rationale is captured in the Problem/Solution sections above.
