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
    """Yield {bucket, name, description, model_invoked} for every skill.

    Walks rather than listing one level deep: upstream buckets sit directly
    under skills/, but fork skills are grouped by domain under skills/house/,
    so a skill's bucket is its directory's parent path (`engineering`,
    `house/mobile`). Every skill competes in the same flat trigger namespace
    however deep it is nested.
    """
    root = os.path.join(repo, "skills")
    if not os.path.isdir(root):
        sys.exit(f"error: no skills/ directory under {repo!r}")
    out = []
    for dirpath, _dirnames, filenames in os.walk(root):
        if "SKILL.md" not in filenames:
            continue
        skill_md = os.path.join(dirpath, "SKILL.md")
        name = os.path.basename(dirpath)
        fm = read_frontmatter(skill_md)
        out.append({
            "bucket": os.path.relpath(os.path.dirname(dirpath), root),
            "name": fm.get("name", name),
            "description": fm.get("description", ""),
            "model_invoked":
                fm.get("disable-model-invocation", "").lower() != "true",
        })
    return sorted(out, key=lambda s: (s["bucket"], s["name"]))


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
