# Validation Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Promote the existing 476-assertion skill validator from an untracked throwaway workspace into `scripts/harness/`, add a confusable-description tripwire, and gate both in CI.

**Architecture:** Three deliverables, each independently reviewable. The validator already exists and passes 476/476 against the live tree — the work is making it runnable from the repo root (three of its six files hardcode workspace-relative paths), giving it a non-zero exit code so CI can gate on it (it currently always exits 0), then adding a new ~60-line Jaccard checker and a GitHub Actions workflow modelled on the existing `release.yml`.

**Tech Stack:** Python 3.9+ (`pyyaml`, with a dependency-free fallback validator), Node 22 (`yaml` npm package, cross-check only), bash, GitHub Actions.

Plan 1 of 4 from [the ClaudeKit adoption spec](../specs/2026-08-10-claudekit-adoption-design.md). Plans 2–4 (subagent return protocol; `ship` + `journal`; review & discipline) follow separately.

## Global Constraints

- **Nothing in `skills/` changes.** This plan touches `scripts/`, `.github/workflows/`, `.changeset/`, and deletes `isolated_test_workspace/`. A modified `SKILL.md` is a plan failure.
- **The harness must stay green.** `skillcheck.py` reports **476/476 PASS** across **18 checks** on the live tree today. Any task that reduces the pass count or drops a check is a failure.
- **Exit codes gate CI.** Every validator must exit non-zero on failure and zero on success. The promoted `skillcheck.py` currently exits 0 unconditionally; Task 1 fixes that.
- **Repo root comes from `argv`, defaulting to `.`** — the promoted scripts run from the repo root, not from a copied tree. Current defaults of `"repo-copy"` are workspace leftovers.
- **`pyyaml` is the primary parser; `hand_validator.py` is the dependency-free fallback.** Keep both. The Node cross-check (`yamlcheck.cjs`) is optional in CI.
- **Python target: 3.9+** (macOS system Python is 3.9.6 — verified). No `match` statements, no `X | Y` unions in annotations at runtime.
- **Commit messages** use conventional-commit prefixes. Per `CLAUDE.md`, do **not** use `chore`/`docs` prefixes for changes inside a `.claude` directory — not applicable here, but `.changeset/` entries ship with the work per repo convention.
- **A changeset ships with this plan** (`.changeset/<name>.md`, package `"osxsystem-skills"`, bump `patch`).

## File Structure

| Path | Responsibility | Status |
|---|---|---|
| `scripts/harness/skillcheck.py` | The 476 assertions across 18 checks. Repo-invariant validator. | Move + fix exit code |
| `scripts/harness/hand_validator.py` | Dependency-free `openai.yaml` structural parse; fallback when `pyyaml` is absent. | Move (already argv-driven) |
| `scripts/harness/yamlcheck.cjs` | Independent Node parse of every `openai.yaml`, for cross-checking. | Move (already argv-driven) |
| `scripts/harness/diff_parsers.py` | Diffs the parser outputs; disagreement is a finding. | Move + accept paths as argv |
| `scripts/harness/test_guardrail.sh` | 39 functional cases for `block-dangerous-git.sh`. | Move + argv repo root + exit code |
| `scripts/harness/render_report.py` | Renders human-readable tables from result JSON. | Move + accept paths as argv |
| `scripts/harness/README.md` | How to run the harness locally; what each file does. | Create |
| `scripts/check-confusable-skills.py` | Jaccard tripwire over model-invoked description pairs. | Create |
| `.github/workflows/skillcheck.yml` | Runs harness + confusable check on PRs and pushes to `main`. | Create |
| `isolated_test_workspace/` | Untracked throwaway (stale tree copy, venv, results). | Delete |

Task 1 moves and repairs the harness; Task 2 adds the tripwire; Task 3 wires CI and removes the workspace. Each task ends with a working, independently verifiable deliverable.

---

### Task 1: Promote the harness to `scripts/harness/` and make it gate

The six harness files currently live in `isolated_test_workspace/harness/` (untracked). Three of them hardcode workspace-relative paths, and `skillcheck.py` exits 0 even when assertions fail — which would make a CI job green on a red repo.

**Files:**
- Create: `scripts/harness/skillcheck.py` (moved from `isolated_test_workspace/harness/skillcheck.py`, 378 lines)
- Create: `scripts/harness/hand_validator.py` (moved, 84 lines, no changes needed)
- Create: `scripts/harness/yamlcheck.cjs` (moved, 40 lines, no changes needed)
- Create: `scripts/harness/diff_parsers.py` (moved, 36 lines, + argv paths)
- Create: `scripts/harness/test_guardrail.sh` (moved, 92 lines, + argv repo root, + exit code)
- Create: `scripts/harness/render_report.py` (moved, 84 lines, + argv paths)
- Create: `scripts/harness/README.md`

**Interfaces:**
- Consumes: nothing from earlier tasks (first task).
- Produces:
  - `python3 scripts/harness/skillcheck.py [REPO_ROOT] [--json]` — prints a summary to stdout, exits `0` when every row is `PASS`, `1` when any row is `FAIL`. With `--json`, prints the raw row array instead of the summary (preserves the current behaviour that `render_report.py` and ad-hoc analysis rely on). `REPO_ROOT` defaults to `.`.
  - `bash scripts/harness/test_guardrail.sh [REPO_ROOT] [RESULTS_DIR]` — exits `0` when all 39 cases pass, `1` otherwise. `REPO_ROOT` defaults to `.`, `RESULTS_DIR` defaults to a `mktemp -d` directory.
  - `node scripts/harness/yamlcheck.cjs [REPO_ROOT]` — prints a JSON array (unchanged).
  - `python3 scripts/harness/hand_validator.py [REPO_ROOT]` — prints a JSON array (unchanged).

- [ ] **Step 1: Copy the six files into place**

```bash
cd /Users/hugues_mini/Codes/skills
mkdir -p scripts/harness
cp isolated_test_workspace/harness/skillcheck.py \
   isolated_test_workspace/harness/hand_validator.py \
   isolated_test_workspace/harness/yamlcheck.cjs \
   isolated_test_workspace/harness/diff_parsers.py \
   isolated_test_workspace/harness/test_guardrail.sh \
   isolated_test_workspace/harness/render_report.py \
   scripts/harness/
chmod +x scripts/harness/*.py scripts/harness/*.sh scripts/harness/*.cjs
ls -1 scripts/harness/
```

Expected output: the six filenames, one per line.

- [ ] **Step 2: Verify the copied validator still passes from the repo root**

The Python default is currently `"repo-copy"`, so the repo root must be passed explicitly for now. `pyyaml` is not in the system Python — use the workspace venv, which still exists at this point.

Run:

```bash
./isolated_test_workspace/.venv/bin/python3 scripts/harness/skillcheck.py . \
  | python3 -c "import json,sys,collections; rows=json.load(sys.stdin); print(len(rows), dict(collections.Counter(r['status'] for r in rows)))"
```

Expected: `476 {'PASS': 476}`

- [ ] **Step 3: Change `skillcheck.py`'s repo-root default to `.`**

In `scripts/harness/skillcheck.py`, line 10:

```python
REPO = sys.argv[1] if len(sys.argv) > 1 else "repo-copy"
```

becomes:

```python
_args = [a for a in sys.argv[1:] if not a.startswith("-")]
REPO = _args[0] if _args else "."
JSON_OUT = "--json" in sys.argv[1:]
```

The flag is filtered out of the positional args so `skillcheck.py --json` and `skillcheck.py . --json` both work.

- [ ] **Step 4: Give `skillcheck.py` a summary and an exit code**

Replace `main()` at the end of `scripts/harness/skillcheck.py` (currently lines 364–373, ending with `print(json.dumps(rows, indent=2))`) with:

```python
def main():
    skills = find_skills(REPO)
    rows = []
    for s in skills:
        rows.extend(check_skill(REPO, s))
    rows.extend(check_readme_membership(REPO, skills))
    rows.extend(check_bucket_readmes(REPO, skills))
    rows.extend(check_ask_matt_routing(REPO, skills))
    rows.extend(check_install_block(REPO))

    if JSON_OUT:
        print(json.dumps(rows, indent=2))
    else:
        failures = [r for r in rows if r["status"] != "PASS"]
        checks = sorted({r["check"] for r in rows})
        print(f"{len(rows)} assertions across {len(checks)} checks "
              f"over {len(skills)} skills in {REPO}")
        for r in failures:
            print(f"  FAIL  {r['bucket']}/{r['skill']}  {r['check']}: {r['notes']}")
        print("PASS" if not failures else f"{len(failures)} FAILURE(S)")

    return 1 if any(r["status"] != "PASS" for r in rows) else 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 5: Run it and verify both the summary and the exit code**

Run:

```bash
./isolated_test_workspace/.venv/bin/python3 scripts/harness/skillcheck.py; echo "exit=$?"
```

Expected: `476 assertions across 18 checks over 39 skills in .`, then `PASS`, then `exit=0`. Note no repo-root argument is passed — the new default handles it.

- [ ] **Step 6: Verify the failure path actually fails**

A validator that cannot go red is not a gate. Prove it by breaking one invariant in a scratch copy, never the real tree:

```bash
TMP=$(mktemp -d)
rsync -a --exclude .git --exclude isolated_test_workspace --exclude node_modules . "$TMP/repo" >/dev/null
sed -i '' 's/^name: tdd$/name: tdd-WRONG/' "$TMP/repo/skills/engineering/tdd/SKILL.md"
./isolated_test_workspace/.venv/bin/python3 scripts/harness/skillcheck.py "$TMP/repo"; echo "exit=$?"
rm -rf "$TMP"
```

Expected: a `FAIL` line naming `engineering/tdd` and the `name-matches-dir` check, then `1 FAILURE(S)`, then `exit=1`.

- [ ] **Step 7: Make `test_guardrail.sh` take the repo root and exit non-zero on failure**

In `scripts/harness/test_guardrail.sh`, replace lines 8–10:

```bash
SCRIPT="repo-copy/skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh"
RESULTS="results/guardrail-tests.tsv"
: > "$RESULTS"
```

with:

```bash
REPO="${1:-.}"
RESULTS_DIR="${2:-$(mktemp -d)}"
SCRIPT="$REPO/skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh"
RESULTS="$RESULTS_DIR/guardrail-tests.tsv"
mkdir -p "$RESULTS_DIR"
: > "$RESULTS"

if [ ! -f "$SCRIPT" ]; then
  echo "error: guardrail script not found at $SCRIPT" >&2
  exit 1
fi
```

Then replace the last line (line 92):

```bash
printf '%s\t%s\n' "$pass" "$fail" > results/guardrail-counts.tsv
```

with:

```bash
printf '%s\t%s\n' "$pass" "$fail" > "$RESULTS_DIR/guardrail-counts.tsv"
[ "$fail" -eq 0 ]
```

The bare test is the last command, so its status becomes the script's exit status — zero only when nothing failed.

- [ ] **Step 8: Run the guardrail suite and check the exit code**

Run:

```bash
bash scripts/harness/test_guardrail.sh; echo "exit=$?"
```

Expected: the case list, then `pass=39 fail=0`, then `exit=0`.

- [ ] **Step 9: Make `diff_parsers.py` and `render_report.py` take their input paths as arguments**

Both hardcode `results/*.json`. In `scripts/harness/diff_parsers.py`, replace lines 7–12:

```python
import json

FIELDS = ["display_name", "short_description", "allow_implicit_invocation", "topLevelKeys"]

node = {(r["bucket"], r["skill"]): r for r in json.load(open("results/node-yaml-checks.json"))}
hand = {(r["bucket"], r["skill"]): r for r in json.load(open("results/hand-yaml-checks.json"))}
```

with:

```python
import json
import sys

FIELDS = ["display_name", "short_description", "allow_implicit_invocation", "topLevelKeys"]

if len(sys.argv) < 3:
    sys.exit("usage: diff_parsers.py <node-yaml-checks.json> <hand-yaml-checks.json>")

node = {(r["bucket"], r["skill"]): r for r in json.load(open(sys.argv[1]))}
hand = {(r["bucket"], r["skill"]): r for r in json.load(open(sys.argv[2]))}
```

In `scripts/harness/render_report.py`, replace line 6:

```python
rows = json.load(open("results/python-checks.json"))
```

with:

```python
import sys

if len(sys.argv) < 2:
    sys.exit("usage: render_report.py <skillcheck-json> [out.md]")
rows = json.load(open(sys.argv[1]))
OUT = sys.argv[2] if len(sys.argv) > 2 else "report-tables.md"
```

and line 80:

```python
open("results/report-tables.md", "w").write("\n".join(out) + "\n")
```

with:

```python
open(OUT, "w").write("\n".join(out) + "\n")
```

and line 84:

```python
print("wrote results/report-tables.md")
```

with:

```python
print(f"wrote {OUT}")
```

- [ ] **Step 10: Verify the cross-check chain runs end to end**

Run:

```bash
TMP=$(mktemp -d)
node scripts/harness/yamlcheck.cjs . > "$TMP/node.json"
./isolated_test_workspace/.venv/bin/python3 scripts/harness/hand_validator.py . > "$TMP/hand.json"
./isolated_test_workspace/.venv/bin/python3 scripts/harness/diff_parsers.py "$TMP/node.json" "$TMP/hand.json"
./isolated_test_workspace/.venv/bin/python3 scripts/harness/skillcheck.py . --json > "$TMP/rows.json"
./isolated_test_workspace/.venv/bin/python3 scripts/harness/render_report.py "$TMP/rows.json" "$TMP/report.md"
head -5 "$TMP/report.md"
rm -rf "$TMP"
```

Expected: `diff_parsers.py` prints `"skills_compared": 39` with `"disagreements": []`; `render_report.py` prints `rows: 476 {'PASS': 476}` and `wrote …/report.md`; the `head` shows the `### Results by check` table opening.

`node scripts/harness/yamlcheck.cjs` needs the `yaml` package. If it errors with `Cannot find module 'yaml'`, that is expected outside the workspace — the Node cross-check is optional (Task 3 leaves it out of CI). Note the result and continue.

- [ ] **Step 11: Write `scripts/harness/README.md`**

```markdown
# Skill validation harness

Structural validation for this repo's skills. Enforces the invariants
`CLAUDE.md` states in prose: bucket-README membership and grouping, docs-page
sections, invocation-mode consistency across `SKILL.md` and
`agents/openai.yaml`, link resolution, `ask-matt` routing freshness, the
verbatim install block, and the absence of `.claude-plugin/`.

Run everything the way CI does:

```bash
python3 scripts/harness/skillcheck.py          # 476+ assertions, exits 1 on any failure
bash scripts/harness/test_guardrail.sh         # 39 cases for block-dangerous-git.sh
python3 scripts/check-confusable-skills.py     # description-collision tripwire
```

`skillcheck.py` needs `pyyaml`. Without it, `hand_validator.py` provides a
dependency-free structural read of every `agents/openai.yaml`, and
`yamlcheck.cjs` (needs the `yaml` npm package) is a third opinion —
`diff_parsers.py` diffs the two so a parser disagreement is itself a finding.

| File | Role |
|---|---|
| `skillcheck.py` | The assertion suite. `--json` prints raw rows. |
| `hand_validator.py` | Dependency-free `openai.yaml` parse. |
| `yamlcheck.cjs` | Independent Node parse, for cross-checking. |
| `diff_parsers.py` | Diffs `yamlcheck.cjs` against `hand_validator.py`. |
| `test_guardrail.sh` | Functional cases for the git guardrail hook script. |
| `render_report.py` | Markdown tables from `skillcheck.py --json` output. |

Every script takes the repo root as its first argument, defaulting to `.`.
```

- [ ] **Step 12: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add scripts/harness/
git commit -m "feat(scripts): promote skill validation harness into the repo

Moves the six-file validator out of an untracked throwaway workspace.
Each script now takes the repo root as argv[1] defaulting to '.', and
skillcheck.py / test_guardrail.sh exit non-zero on failure so CI can
gate on them."
```

---

### Task 2: Add the confusable-description tripwire

A new standalone script. For every **model-invoked × model-invoked** pair of skills, compute the Jaccard index of their description word-sets and fail if any pair reaches 0.80.

Why model-invoked only: a user-invoked skill has no description in the model's reach (`disable-model-invocation: true`), so it cannot compete for a model trigger. Measured against the live repo, the highest model-invoked pair is `tdd` ↔ `migrate-to-shoehorn` at **0.185** — so 0.80 flags nothing today and exists to catch future drift.

**Files:**
- Create: `scripts/check-confusable-skills.py`

**Interfaces:**
- Consumes: nothing from Task 1 — deliberately standalone, with no `pyyaml` dependency, so CI can run it even if the harness's parser is unavailable.
- Produces: `python3 scripts/check-confusable-skills.py [REPO_ROOT] [--threshold N] [--all]` — exits `0` when no model-invoked pair reaches the threshold, `1` otherwise. `--all` prints the top pairs regardless of threshold (for calibration). `REPO_ROOT` defaults to `.`.

The spec estimated "roughly 40 lines"; the code below is ~140 with its docstring, frontmatter reader, and `argparse` surface. The extra bulk is the dependency-free frontmatter read (the spec's constraint) and the `--all` calibration mode that makes the threshold decision reproducible. Every line below has been executed against this repo — the expected outputs in the steps are real, not predicted.

- [ ] **Step 1: Write the script**

Create `scripts/check-confusable-skills.py`:

```python
#!/usr/bin/env python3
"""Fail when two model-invoked skill descriptions compete for the same trigger.

A skill's description is the pointer the agent reads every turn to decide
whether to load it. Two model-invoked skills whose descriptions overlap
heavily are a routing coin-flip. This computes the Jaccard index over
stop-word-filtered description tokens for every model-invoked pair and fails
above a threshold.

User-invoked skills (disable-model-invocation: true) are excluded by
construction: with no description in the model's reach, they cannot compete
for a model trigger.

No third-party dependencies — the frontmatter fields this needs are flat
scalars, so a line reader is enough and the check runs anywhere python3 does.
"""
import argparse
import os
import re
import sys

# Dropped before comparison so shared filler doesn't inflate overlap.
STOP_WORDS = frozenset({
    "a", "an", "and", "are", "as", "at", "be", "by", "do", "for", "from",
    "has", "have", "if", "in", "is", "it", "not", "of", "on", "or", "so",
    "the", "to", "up", "use", "via", "vs", "was", "we", "when", "with",
    "you", "your",
})

DEFAULT_THRESHOLD = 0.80
KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$")


def read_frontmatter(path):
    """Return the flat top-level key/value pairs of a SKILL.md's frontmatter."""
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    fields = {}
    for line in text[3:end].splitlines():
        if not line.strip() or line.startswith("#") or line.startswith(" "):
            continue
        m = KEY_RE.match(line)
        if not m:
            continue
        key, value = m.group(1), m.group(2).strip()
        if len(value) > 1 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        fields[key] = value
    return fields


def find_skills(repo):
    """Yield {bucket, name, description, model_invoked} for every skill."""
    root = os.path.join(repo, "skills")
    if not os.path.isdir(root):
        sys.exit(f"error: no skills/ directory under {repo!r}")
    out = []
    for bucket in sorted(os.listdir(root)):
        bdir = os.path.join(root, bucket)
        if not os.path.isdir(bdir):
            continue
        for name in sorted(os.listdir(bdir)):
            skill_md = os.path.join(bdir, name, "SKILL.md")
            if not os.path.isfile(skill_md):
                continue
            fm = read_frontmatter(skill_md)
            out.append({
                "bucket": bucket,
                "name": fm.get("name", name),
                "description": fm.get("description", ""),
                "model_invoked":
                    fm.get("disable-model-invocation", "").lower() != "true",
            })
    return out


def tokenize(text):
    return {w for w in re.findall(r"[a-z0-9]+", text.lower())
            if w not in STOP_WORDS and len(w) > 1}


def jaccard(a, b):
    if not a or not b:
        return 0.0
    return len(a & b) / len(a | b)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("repo", nargs="?", default=".")
    ap.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD)
    ap.add_argument("--all", action="store_true",
                    help="print the top pairs regardless of threshold")
    args = ap.parse_args()

    skills = find_skills(args.repo)
    model = [s for s in skills if s["model_invoked"]]
    print(f"{len(skills)} skills: {len(model)} model-invoked, "
          f"{len(skills) - len(model)} user-invoked (excluded)")

    pairs = []
    for i in range(len(model)):
        for j in range(i + 1, len(model)):
            a, b = model[i], model[j]
            sim = jaccard(tokenize(a["description"]), tokenize(b["description"]))
            pairs.append((sim, a, b))
    pairs.sort(key=lambda p: p[0], reverse=True)

    if args.all:
        for sim, a, b in pairs[:10]:
            print(f"  {sim:.3f}  {a['bucket']}/{a['name']} <-> "
                  f"{b['bucket']}/{b['name']}")

    flagged = [p for p in pairs if p[0] >= args.threshold]
    if not flagged:
        top = f"{pairs[0][0]:.3f}" if pairs else "n/a"
        print(f"PASS — no pair at or above {args.threshold:.2f} "
              f"(highest: {top})")
        return 0

    for sim, a, b in flagged:
        print(f"\nFAIL  {sim:.3f} >= {args.threshold:.2f}")
        print(f"  {a['bucket']}/{a['name']}: {a['description']}")
        print(f"  {b['bucket']}/{b['name']}: {b['description']}")
    print(f"\n{len(flagged)} confusable pair(s). Sharpen one description so "
          f"each names triggers the other does not.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 2: Run it against the live repo**

Run:

```bash
python3 scripts/check-confusable-skills.py; echo "exit=$?"
```

Expected: `39 skills: 19 model-invoked, 20 user-invoked (excluded)`, then `PASS — no pair at or above 0.80 (highest: 0.185)`, then `exit=0`.

Note this uses the *system* `python3` — no `pyyaml`, no venv. That is the point.

- [ ] **Step 3: Verify the calibration view reproduces the measured numbers**

Run:

```bash
python3 scripts/check-confusable-skills.py --all
```

Expected top three lines, in this order:

```
  0.185  engineering/tdd <-> misc/migrate-to-shoehorn
  0.125  misc/git-guardrails-claude-code <-> misc/setup-pre-commit
  0.125  mobile/compose-multiplatform-ui <-> mobile/kmp-module-setup
```

These are the values the spec's threshold decision rests on. A mismatch means the tokeniser or the invocation read drifted — fix before continuing.

- [ ] **Step 4: Verify the failure path**

Lower the threshold beneath the observed maximum; the top pair must be reported and the exit code must flip:

```bash
python3 scripts/check-confusable-skills.py --threshold 0.15; echo "exit=$?"
```

Expected: a `FAIL  0.185 >= 0.15` block printing both descriptions in full, then `1 confusable pair(s).`, then `exit=1`.

- [ ] **Step 5: Verify a genuinely confusable pair is caught**

The real test is a near-duplicate description, not a lowered threshold. Build one in a scratch copy:

```bash
TMP=$(mktemp -d)
rsync -a --exclude .git --exclude isolated_test_workspace --exclude node_modules . "$TMP/repo" >/dev/null
# Copy tdd's description onto research (both model-invoked).
python3 - "$TMP/repo" <<'PY'
import re, sys
repo = sys.argv[1]
tdd = open(f"{repo}/skills/engineering/tdd/SKILL.md").read()
desc = re.search(r"^description: (.*)$", tdd, re.M).group(1)
p = f"{repo}/skills/engineering/research/SKILL.md"
t = open(p).read()
open(p, "w").write(re.sub(r"^description: .*$", f"description: {desc}", t, count=1, flags=re.M))
PY
python3 scripts/check-confusable-skills.py "$TMP/repo"; echo "exit=$?"
rm -rf "$TMP"
```

Expected: `FAIL  1.000 >= 0.80` naming `engineering/research <-> engineering/tdd`, then `exit=1`. Identical descriptions score 1.000, so this proves the detector fires on the failure it exists for.

- [ ] **Step 6: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add scripts/check-confusable-skills.py
git commit -m "feat(scripts): add confusable skill description check

Jaccard tripwire over model-invoked description pairs, failing at 0.80.
User-invoked skills are excluded — with no description in the model's
reach they cannot compete for a model trigger. Highest pair in the repo
today is 0.185, so this guards against future drift rather than fixing
anything now."
```

---

### Task 3: Wire CI, delete the workspace, ship the changeset

**Files:**
- Create: `.github/workflows/skillcheck.yml`
- Create: `.changeset/skill-validation-harness.md`
- Delete: `isolated_test_workspace/` (untracked — confirmed via `git status`, so this is a filesystem removal with no git history implications)

**Interfaces:**
- Consumes: `scripts/harness/skillcheck.py`, `scripts/harness/test_guardrail.sh` (Task 1), `scripts/check-confusable-skills.py` (Task 2) — all three exit non-zero on failure, which is what makes the job gate.
- Produces: a required-status-check-eligible workflow named `Skill checks`.

- [ ] **Step 1: Write the workflow**

Create `.github/workflows/skillcheck.yml`. Modelled on `release.yml` (same checkout action, same runner), but triggered on pull requests as well as pushes to `main`:

```yaml
name: Skill checks

on:
  push:
    branches:
      - main
  pull_request:

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  validate:
    name: Validate skills
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install pyyaml
        run: pip install pyyaml==6.0.3

      - name: Structural validation
        run: python3 scripts/harness/skillcheck.py

      - name: Confusable descriptions
        run: python3 scripts/check-confusable-skills.py

      - name: Git guardrail functional tests
        run: bash scripts/harness/test_guardrail.sh
```

Notes on what is deliberately absent:

- **No `yamlcheck.cjs` step.** It needs the `yaml` npm package, and the repo's own `package.json` doesn't depend on it. Its job — a second opinion on the same YAML — is served in CI by `pyyaml` plus the fact that `skillcheck.py` itself reads every `openai.yaml`. It stays available for local cross-checking.
- **No `npm ci`.** No JavaScript runs in this job.
- **`pyyaml` pinned** (`6.0.3`, the version the harness was verified against) rather than floating, matching the repo's posture on pinning dependencies.

- [ ] **Step 2: Verify the workflow is valid YAML and its steps match reality**

There is no local GitHub Actions runner here, so check the two things that actually break: the YAML parses, and each `run:` command exists and passes.

```bash
python3 -c "
import sys
try:
    import yaml
except ImportError:
    sys.exit('skip: pyyaml unavailable to system python — run with the venv instead')
d = yaml.safe_load(open('.github/workflows/skillcheck.yml'))
steps = d['jobs']['validate']['steps']
print('job:', d['jobs']['validate']['name'])
for s in steps:
    print('  -', s.get('name'), '|', s.get('run') or s.get('uses'))
"
```

Expected: the job name `Validate skills` and six steps, the last three being the three `python3`/`bash` commands.

If the system Python lacks `pyyaml`, use `./isolated_test_workspace/.venv/bin/python3` for this step — it still exists until Step 4.

- [ ] **Step 3: Run the three CI commands exactly as the workflow will**

The workflow's Python has `pyyaml`, so locally use the venv for the harness step and system Python for the dependency-free check:

```bash
./isolated_test_workspace/.venv/bin/python3 scripts/harness/skillcheck.py; echo "skillcheck exit=$?"
python3 scripts/check-confusable-skills.py; echo "confusable exit=$?"
bash scripts/harness/test_guardrail.sh; echo "guardrail exit=$?"
```

Expected: `PASS` and `exit=0` from all three (`476 assertions across 18 checks`, `no pair at or above 0.80`, `pass=39 fail=0`). All three must be zero — a non-zero here means CI lands red, which the spec forbids.

- [ ] **Step 4: Delete the throwaway workspace**

Confirm it is untracked, then remove it:

```bash
cd /Users/hugues_mini/Codes/skills
git status --short isolated_test_workspace/
```

Expected: `?? isolated_test_workspace/` — untracked, so nothing is being removed from git history.

```bash
rm -rf isolated_test_workspace/
git status --short
```

Expected: `isolated_test_workspace/` no longer listed.

- [ ] **Step 5: Re-verify the harness with no venv present**

The venv died with the workspace. Prove the promoted harness still runs against the system interpreter — and if `pyyaml` is missing there, prove the fallback path is what the README claims:

```bash
python3 scripts/check-confusable-skills.py; echo "exit=$?"
bash scripts/harness/test_guardrail.sh; echo "exit=$?"
python3 -c "import yaml" 2>/dev/null \
  && (python3 scripts/harness/skillcheck.py; echo "skillcheck exit=$?") \
  || echo "system python has no pyyaml — skillcheck.py is a CI-and-venv tool, as documented in scripts/harness/README.md; hand_validator.py covers the no-pyyaml case"
```

Expected: the confusable check and guardrail suite both pass with `exit=0` on system Python. `skillcheck.py` needs `pyyaml`; on this machine it is absent, so the fallback message is the expected output — CI installs `pyyaml` explicitly, which is why the workflow does not depend on the local situation.

- [ ] **Step 6: Confirm no skill file was touched**

The plan's global constraint is that `skills/` does not change. Verify:

```bash
git status --short skills/ && echo "(empty above means skills/ untouched)"
git diff --stat HEAD -- skills/
```

Expected: no output from either — nothing staged, nothing modified under `skills/`.

- [ ] **Step 7: Write the changeset**

Create `.changeset/skill-validation-harness.md`:

```markdown
---
"osxsystem-skills": patch
---

Skill validation now runs in CI.

The structural validator that checks this repo's own invariants — bucket-README
membership and grouping, docs-page sections, invocation-mode consistency across
`SKILL.md` and `agents/openai.yaml`, link resolution, `ask-matt` routing
freshness, the verbatim install block — has moved into `scripts/harness/` and
runs on every pull request. A new `scripts/check-confusable-skills.py` fails
when two model-invoked skill descriptions overlap enough to compete for the
same trigger.

No skill behaviour changes. The rules were already written down in `CLAUDE.md`;
now something checks them.
```

- [ ] **Step 8: Commit**

```bash
cd /Users/hugues_mini/Codes/skills
git add .github/workflows/skillcheck.yml .changeset/skill-validation-harness.md
git commit -m "ci: run skill validation on pull requests

Runs skillcheck.py, check-confusable-skills.py, and the guardrail
functional suite on every PR and push to main. Each exits non-zero on
failure, so the job gates. Deletes the untracked throwaway workspace the
harness used to live in."
```

- [ ] **Step 9: Verify the commit contents**

```bash
git show --stat HEAD | cat
git log --oneline -3 | cat
```

Expected: the commit contains exactly the two new files; the three commits from this plan appear in order (harness promotion, confusable check, CI).

## Verification Summary

After Task 3, the repo has:

- `scripts/harness/` — six files, promoted, path-parameterised, exit-code-gated
- `scripts/check-confusable-skills.py` — new, dependency-free, verified against the live repo (highest pair 0.185) and against an injected near-duplicate (1.000, caught)
- `.github/workflows/skillcheck.yml` — runs both plus the guardrail suite on every PR
- `isolated_test_workspace/` — gone
- Three commits (harness promotion, confusable check, CI + changeset) plus one changeset covering the plan

None of `skills/` changed. This closes plan 1 of 4 from [the spec](../specs/2026-08-10-claudekit-adoption-design.md); plan 2 (subagent return protocol) can now rely on CI catching a confusable description in the skills it touches.
