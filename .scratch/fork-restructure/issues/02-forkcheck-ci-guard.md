# 02 — `forkcheck` guard in CI, fail-closed

**Parent:** `.scratch/2026-08-13-fork-restructure-provenance-tree.md`

**What to build:** A PR that drifts an upstream path outside the sanctioned list, duplicates a skill name, breaks catalog completeness, or resurrects the deleted plugin directory fails CI with a message naming the violation — enforced from the existing validate job, not a new workflow.

**Blocked by:** 01 — Seed the fork control plane.

**Status:** done

- [x] A `forkcheck` script lives beside the existing harness scripts (python3, no third-party deps, follows their conventions)
- [x] Assertion 1: upstream buckets byte-identical to `upstream/main` modulo `.fork/sanctioned-edits.txt`
- [x] Assertion 2: no two skill directories anywhere share a basename (the flat install namespace)
- [x] Assertion 3: catalog completeness both ways — every skill has a catalog entry, every entry has a skill
- [x] Assertion 4: the plugin directory is absent
- [x] The existing CI validate job gains a fetch-upstream step and runs forkcheck; no new workflow file
- [x] A fail-closed test (in the style of the existing guardrail shell test) seeds a violation of each assertion and proves forkcheck fails; forkcheck also fails (not passes) when it cannot reach upstream or parse the catalog
- [x] CI is green on the unmodified tree

## Notes on how it landed

- **`pyyaml`, not zero deps.** `forkcheck.py` parses `.fork/catalog.yaml` with
  `pyyaml`, like `skillcheck.py` and `generate-catalog.py` — one parser and the
  strictest one. CI already installs it. Following the harness convention won
  over the letter of "no third-party deps"; the guard fails closed if it is
  absent.
- **Compared against the lock, not a live `upstream/main`.** The default ref is
  `.fork/upstream.lock`'s `upstream_sha`. Diffing a moving `upstream/main` would
  turn any upstream push into a red build on an untouched fork. Pass
  `--upstream-ref upstream/main` during a sync, when the two are meant to
  converge.
- **Scope of assertion 1** is the definition in the `sanctioned-edits.txt`
  header: upstream-shipped paths plus anything under an upstream-owned folder
  must be enumerated there; everything else must match a tree declared under
  Additions in `.fork/divergence.md`. That caught `.scratch/`, now declared.
- **Bonus assertion:** a sanctioned-edits entry that no longer differs from
  upstream fails as stale, so the list shrinks as divergences retire.
