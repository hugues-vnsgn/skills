---
"osxsystem-skills": minor
---

Restructure the tree by provenance: every fork-authored skill now lives under
`skills/team/`, grouped by capability domain.

**No skill was renamed.** `/kmp-module-setup`, `/port-from-repo`,
`/setup-osxsystem-skills` and the rest answer to exactly the same names as
before — only their directories moved, so invocation is unchanged. Re-run
`scripts/link-skills.sh` to relink from the new paths.

- **`skills/team/mobile/`** — the four Kotlin Multiplatform / Compose
  Multiplatform skills, from `skills/mobile/`.
- **`skills/team/platform/`** — `setup-osxsystem-skills` (from
  `skills/engineering/`), `port-from-repo` (from `skills/engineering/`), and
  `when-stuck` (from `skills/in-progress/`, still beta).

Upstream's buckets (`engineering/`, `productivity/`, `misc/`, `in-progress/`,
`deprecated/`) are now byte-frozen vendor territory, so an upstream sync is a
merge plus assertions rather than an act of curation.

**New skill:** `kmp-test-seams` (model-invoked) — which source set a test
belongs in and which Gradle task proves a slice green. It was the KMP section
appended to upstream's `tdd` skill; extracting it restores `tdd` verbatim and
retires a guaranteed merge conflict. `ask-matt` routes to it under the
platform-knowledge layer.

**Fork control plane** — `.fork/` holds the per-skill sidecar taxonomy
(`catalog.yaml`: origin, domain, audience, owner), the last-synced upstream SHA
(`upstream.lock`), the divergence record with a resolution recipe per entry, the
sanctioned-edits list CI consumes, and the sync playbook. `CATALOG.md` at the
repo root is generated from the catalog and must never be hand-edited.

**CI guard** — `scripts/harness/forkcheck.py` joins the validate job and fails
the build on four invariants: upstream paths drifting from `upstream/main`
outside the sanctioned list, two skills sharing a directory basename anywhere in
the tree, a catalog that doesn't match the skills on disk, and the reappearance
of the `.claude-plugin/` directory this fork deleted.

**Ownership and discovery** — `CODEOWNERS` maps one line per team domain plus a
maintainers line over vendor territory and the control plane, and `docs/roles/`
adds an entry page per audience (engineer, designer, analyst, qa, staff) giving
each discipline a curated reading order instead of a folder taxonomy to learn.
