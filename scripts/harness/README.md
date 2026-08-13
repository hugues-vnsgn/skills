# Skill validation harness

Structural validation for this repo's skills. Enforces the invariants
`CLAUDE.md` states in prose: bucket-README membership and grouping, docs-page
sections, invocation-mode consistency across `SKILL.md` and
`agents/openai.yaml`, link resolution, `ask-matt` routing freshness, the
verbatim install block, and the absence of `.claude-plugin/`.

Run everything the way CI does:

```bash
python3 scripts/harness/forkcheck.py           # fork boundary: 4 assertions
python3 scripts/harness/skillcheck.py          # 476+ assertions, exits 1 on any failure
bash scripts/harness/test_guardrail.sh         # 39 cases for block-dangerous-git.sh
bash scripts/harness/test_forkcheck.sh         # 18 fail-closed cases for forkcheck.py
python3 scripts/check-confusable-skills.py     # description-collision tripwire
```

`forkcheck.py` needs the upstream commit recorded in `.fork/upstream.lock`:
`git fetch upstream main` first, or pass `--upstream-ref` to compare against
something else (`upstream/main` during a sync).

`skillcheck.py` needs `pyyaml`. Without it, `hand_validator.py` provides a
dependency-free structural read of every `agents/openai.yaml`, and
`yamlcheck.cjs` (needs the `yaml` npm package) is a third opinion —
`diff_parsers.py` diffs the two so a parser disagreement is itself a finding.

| File | Role |
|---|---|
| `forkcheck.py` | The fork boundary guard: frozen upstream territory, unique skill names, catalog completeness, no plugin directory. |
| `test_forkcheck.sh` | Seeds a violation of each `forkcheck.py` assertion and proves it fails. |
| `skillcheck.py` | The assertion suite. `--json` prints raw rows. |
| `hand_validator.py` | Dependency-free `openai.yaml` parse. |
| `yamlcheck.cjs` | Independent Node parse, for cross-checking. |
| `diff_parsers.py` | Diffs `yamlcheck.cjs` against `hand_validator.py`. |
| `test_guardrail.sh` | Functional cases for the git guardrail hook script. |
| `render_report.py` | Markdown tables from `skillcheck.py --json` output. |

Every script takes the repo root as its first argument, defaulting to `.`.
