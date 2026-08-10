#!/usr/bin/env python3
"""Diff the three YAML validators field-by-field.

Any skill the parsers disagree on gets flagged for hand-reading (the round-2
decision). Agreement is only evidence if the comparison actually runs.
"""
import json
import sys

FIELDS = ["display_name", "short_description", "allow_implicit_invocation", "topLevelKeys"]

if len(sys.argv) < 3:
    sys.exit("usage: diff_parsers.py <node-yaml-checks.json> <hand-yaml-checks.json>")

node = {(r["bucket"], r["skill"]): r for r in json.load(open(sys.argv[1]))}
hand = {(r["bucket"], r["skill"]): r for r in json.load(open(sys.argv[2]))}

keys = sorted(set(node) | set(hand))
disagreements = []
for k in keys:
    n, h = node.get(k), hand.get(k)
    if n is None or h is None:
        disagreements.append({"skill": "/".join(k), "field": "presence",
                              "node": n is not None, "hand": h is not None})
        continue
    if bool(n.get("parsed")) != bool(h.get("parsed")):
        disagreements.append({"skill": "/".join(k), "field": "parsed",
                              "node": n.get("parsed"), "hand": h.get("parsed")})
    for f in FIELDS:
        nv, hv = n.get(f), h.get(f)
        if nv != hv:
            disagreements.append({"skill": "/".join(k), "field": f, "node": nv, "hand": hv})

summary = {
    "skills_compared": len(keys),
    "node_parsed_ok": sum(1 for r in node.values() if r.get("parsed")),
    "hand_parsed_ok": sum(1 for r in hand.values() if r.get("parsed")),
    "disagreements": disagreements,
}
print(json.dumps(summary, indent=2))
