# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

This repo is **single-context**: one root glossary, one ADR directory, no per-context split.

## Before exploring, read these

- **[`CONTEXT.md`](../../CONTEXT.md)** at the repo root: the glossary.
- **[`.agents/adr/`](../../.agents/adr/)**: read ADRs that touch the area you are about to work in.

Note the ADR path. This repo keeps decision records in **`.agents/adr/`**, not the `docs/adr/` the skills assume by default, because `docs/` here is the published per-skill documentation tree and `.agents/` is the agent-facing control plane. There is no `CONTEXT-MAP.md` and no `src/<context>/docs/adr/`; do not look for either.

If any of these files do not exist, **proceed silently**. Do not flag their absence and do not suggest creating them upfront. The `/domain-modeling` skill (reached via `/grill-with-docs` and `/improve-codebase-architecture`) creates them lazily when terms or decisions actually get resolved.

## File structure

```
/
├── CONTEXT.md                 ← the glossary
├── .agents/
│   ├── adr/
│   │   ├── 0001-explicit-setup-pointer-only-for-hard-dependencies.md
│   │   └── 0002-ship-as-a-claude-code-plugin.md
│   ├── install-block.md       ← the canonical install commands
│   └── writing-docs.md        ← the docs page template
├── .fork/                     ← fork control plane: catalog, divergence, sync playbook
├── docs/                      ← published docs, one page per promoted skill
└── skills/                    ← the skills themselves, split by provenance
```

## Two more sources of truth specific to this repo

Neither is a glossary, but both bind the same way, and a proposal that contradicts either is wrong rather than merely unconventional:

- **[`CLAUDE.md`](../../CLAUDE.md)** carries the repo's structural conventions: the provenance split under `skills/`, which buckets are promoted, where docs pages live, and the no-em-dashes rule for all prose.
- **[`.fork/divergence.md`](../../.fork/divergence.md)** and **[`.fork/sanctioned-edits.txt`](../../.fork/sanctioned-edits.txt)** define the fork boundary. `scripts/harness/forkcheck.py` enforces it, so an undeclared new path or an unsanctioned edit to upstream territory fails CI regardless of how good the change is.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`. Do not drift to synonyms the glossary explicitly avoids.

If the concept you need is not in the glossary yet, that is a signal: either you are inventing language the project does not use (reconsider) or there is a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0002 (ship as a Claude Code plugin), but worth reopening because…_
