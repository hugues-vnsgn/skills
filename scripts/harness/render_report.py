#!/usr/bin/env python3
"""Render TEST_REPORT.md tables from the raw results JSON."""
import collections
import json

import sys

if len(sys.argv) < 2:
    sys.exit("usage: render_report.py <skillcheck-json> [out.md]")
rows = json.load(open(sys.argv[1]))
OUT = sys.argv[2] if len(sys.argv) > 2 else "report-tables.md"

CHECK_ORDER = [
    "frontmatter-parses", "frontmatter-has-name", "frontmatter-has-description",
    "name-matches-dir", "description-length", "openai-yaml-parses",
    "openai-yaml-shape", "invocation-mode-consistency", "links-resolve",
    "readme-membership", "bucket-readme-lists-skill", "docs-page-sections",
    "docs-page-exists", "ask-matt-mentions-skill",
]
BUCKET_ORDER = ["engineering", "productivity", "mobile", "misc", "in-progress"]

out = []

# ---- per-check summary ----
out.append("### Results by check\n")
out.append("| Check | Pass | Fail | Scope |\n|---|---|---|---|")
SCOPE = {
    "frontmatter-parses": "all 39",
    "frontmatter-has-name": "all 39",
    "frontmatter-has-description": "all 39",
    "name-matches-dir": "all 39",
    "description-length": "all 39",
    "openai-yaml-parses": "all 39",
    "openai-yaml-shape": "all 39",
    "invocation-mode-consistency": "20 user-invoked",
    "links-resolve": "all 39",
    "readme-membership": "all 39 (presence + absence)",
    "bucket-readme-lists-skill": "all 39",
    "bucket-readme-grouping": "5 buckets",
    "docs-page-sections": "29 promoted",
    "ask-matt-mentions-skill": "28 promoted (excl. self)",
    "ask-matt-no-stale-routes": "router",
    "install-block-in-readme": "repo",
    "install-block-not-duplicated-in-docs": "repo",
    "no-claude-plugin-dir": "repo",
}
agg = collections.defaultdict(collections.Counter)
for r in rows:
    agg[r["check"]][r["status"]] += 1
for check in list(CHECK_ORDER) + [c for c in sorted(agg) if c not in CHECK_ORDER]:
    if check not in agg:
        continue
    c = agg[check]
    out.append(f"| `{check}` | {c['PASS']} | {c['FAIL']} | {SCOPE.get(check, '')} |")

# ---- per-bucket detail ----
by_bucket = collections.defaultdict(list)
for r in rows:
    by_bucket[r["bucket"]].append(r)

for bucket in BUCKET_ORDER:
    brows = by_bucket.get(bucket, [])
    if not brows:
        continue
    skills = sorted({r["skill"] for r in brows if r["skill"] != "(bucket)"})
    fails = [r for r in brows if r["status"] == "FAIL"]
    out.append(f"\n<details>\n<summary><b>{bucket}/</b> — {len(skills)} skills, "
               f"{sum(1 for r in brows if r['status'] == 'PASS')} pass / {len(fails)} fail</summary>\n")
    out.append("| Skill | Check | Status | Notes |\n|---|---|---|---|")
    for r in sorted(brows, key=lambda r: (r["skill"], r["check"])):
        mark = "PASS" if r["status"] == "PASS" else "**FAIL**"
        notes = r["notes"].replace("|", "\\|")
        out.append(f"| `{r['skill']}` | `{r['check']}` | {mark} | {notes} |")
    out.append("\n</details>")

# ---- repo-level ----
repo_rows = [r for r in rows if r["bucket"] == "-"]
if repo_rows:
    out.append("\n### Repo-level invariants\n")
    out.append("| Check | Status | Notes |\n|---|---|---|")
    for r in repo_rows:
        mark = "PASS" if r["status"] == "PASS" else "**FAIL**"
        out.append(f"| `{r['check']}` | {mark} | {r['notes'].replace('|', chr(92) + '|')} |")

open(OUT, "w").write("\n".join(out) + "\n")

totals = collections.Counter(r["status"] for r in rows)
print("rows:", len(rows), dict(totals))
print(f"wrote {OUT}")
