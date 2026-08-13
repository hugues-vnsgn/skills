# 02 — `forkcheck` guard in CI, fail-closed

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** A PR that drifts an upstream path outside the sanctioned list, duplicates a skill name, breaks catalog completeness, or resurrects the deleted plugin directory fails CI with a message naming the violation — enforced from the existing validate job, not a new workflow.

**Blocked by:** 01 — Seed the fork control plane.

**Status:** ready-for-agent

- [ ] A `forkcheck` script lives beside the existing harness scripts (python3, no third-party deps, follows their conventions)
- [ ] Assertion 1: upstream buckets byte-identical to `upstream/main` modulo `.fork/sanctioned-edits.txt`
- [ ] Assertion 2: no two skill directories anywhere share a basename (the flat install namespace)
- [ ] Assertion 3: catalog completeness both ways — every skill has a catalog entry, every entry has a skill
- [ ] Assertion 4: the plugin directory is absent
- [ ] The existing CI validate job gains a fetch-upstream step and runs forkcheck; no new workflow file
- [ ] A fail-closed test (in the style of the existing guardrail shell test) seeds a violation of each assertion and proves forkcheck fails; forkcheck also fails (not passes) when it cannot reach upstream or parse the catalog
- [ ] CI is green on the unmodified tree
