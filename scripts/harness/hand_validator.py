#!/usr/bin/env python3
"""Third, dependency-free structural validator for agents/openai.yaml.

Runs without pyyaml or npm so the suite still yields results if either install
fails. Asserts the known 2-level shape by hand rather than via a YAML parser,
giving an independent opinion to diff against the two real parsers.
"""
import json
import os
import re
import sys

REPO = sys.argv[1] if len(sys.argv) > 1 else "repo-copy"
KEY_RE = re.compile(r"^(\s*)([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$")


def parse_shallow(path):
    """Return (tree, errors) for a strictly 2-level key: value document."""
    tree, errors, current = {}, [], None
    with open(path, encoding="utf-8") as fh:
        for lineno, raw in enumerate(fh, 1):
            line = raw.rstrip("\n")
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            if "\t" in line:
                errors.append(f"line {lineno}: tab character (YAML forbids tabs for indentation)")
                continue
            m = KEY_RE.match(line)
            if not m:
                errors.append(f"line {lineno}: not a key: value pair -> {line!r}")
                continue
            indent, key, value = len(m.group(1)), m.group(2), m.group(3).strip()
            if indent == 0:
                current = key
                tree[key] = {} if value == "" else value
            elif indent == 2:
                if current is None or not isinstance(tree.get(current), dict):
                    errors.append(f"line {lineno}: nested key {key!r} has no parent mapping")
                    continue
                v = value
                if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
                    v = v[1:-1]
                elif v in ("true", "false"):
                    v = v == "true"
                tree[current][key] = v
            else:
                errors.append(f"line {lineno}: unexpected indent {indent} (expected 0 or 2)")
    return tree, errors


def main():
    skills_root = os.path.join(REPO, "skills")
    out = []
    for bucket in sorted(os.listdir(skills_root)):
        bdir = os.path.join(skills_root, bucket)
        if not os.path.isdir(bdir):
            continue
        for name in sorted(os.listdir(bdir)):
            sdir = os.path.join(bdir, name)
            if not os.path.isfile(os.path.join(sdir, "SKILL.md")):
                continue
            ypath = os.path.join(sdir, "agents", "openai.yaml")
            rec = {"bucket": bucket, "skill": name,
                   "file": os.path.relpath(ypath, REPO)}
            if not os.path.isfile(ypath):
                out.append({**rec, "parsed": False, "errors": ["file missing"]})
                continue
            tree, errors = parse_shallow(ypath)
            iface = tree.get("interface") if isinstance(tree.get("interface"), dict) else {}
            policy = tree.get("policy") if isinstance(tree.get("policy"), dict) else {}
            out.append({
                **rec,
                "parsed": not errors,
                "errors": errors,
                "display_name": iface.get("display_name"),
                "short_description": iface.get("short_description"),
                "allow_implicit_invocation": policy.get("allow_implicit_invocation"),
                "topLevelKeys": sorted(tree.keys()),
            })
    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
