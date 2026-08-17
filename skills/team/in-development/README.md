# In-Development Skills

Fork-authored skills still under development — not registered in the top-level README, no docs pages yet.

No skills here right now. The previous residents shipped as beta: `cook` and `project-organization` to [`team/delivery/`](../delivery/README.md), `do-test` to [`team/quality/`](../quality/README.md).

## Shipping checklist

1. Move the skill to its capability domain under `skills/team/<domain>/`. **If that domain is new**, add its row to the Additions table in `.fork/divergence.md` in the same change — `forkcheck` fails every build until a fork-owned tree is declared there, and it is the step most easily missed because nothing about writing the skill points at it.
2. Record the audience in `.fork/catalog.yaml` (add `status: beta` unless it's ready to promote), then regenerate `CATALOG.md` with `python3 scripts/generate-catalog.py`.
3. Add the skill to its bucket README and to the `docs/roles/` page of every audience it names.
4. Unless marked `status: beta`: add the docs page at `docs/team/<domain>/<skill-name>.md` per `.agents/writing-docs.md`, register the skill in the top-level README, and re-sync `ask-matt`'s routing map.
5. Test and verify the skill before shipping — always inside an isolated working folder, never outside it.
