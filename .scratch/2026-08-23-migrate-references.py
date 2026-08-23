#!/usr/bin/env python3
"""One-off reference sweep for the osxsystem -> hugues-vnsgn account migration.

Recorded rather than run as a shell one-liner, because a blanket
`sed s/osxsystem/hugues-vnsgn/g` corrupts 120 strings that must not change:
the package name, the name of the published `setup-osxsystem-skills` skill,
the fork's prose description of itself, and a changelog that is a dated record.

Three path-scoped patterns. Run with --check to report without writing.

    python3 .scratch/2026-08-23-migrate-references.py [--check]
"""
import os
import re
import sys

OLD, NEW = "osxsystem", "hugues-vnsgn"
UPSTREAM = "mattpocock"

# Pattern A applies repo-wide except here. CHANGELOG.md is handled separately by
# Pattern C. The rest fall into four groups, and the dry run is what surfaced
# the last three:
#   - a dated record we do not rewrite (.scratch/, .out-of-scope/)
#   - a SECOND WORKING TREE (.claude/worktrees/) whose files are not ours to edit
#   - Dolt database internals (.beads/dolt/), where a blind text rewrite can
#     corrupt the issue store. `.beads/config.yaml` is untracked and is handled
#     as an explicit machine-local step instead, not by this sweep.
#   - gitignored local scratch (isolated_test_workspace/, prompts/) and the
#     user's private CLAUDE.local.md, none of which ship.
EXCLUDE_PREFIXES = (
    ".git/", "node_modules/", ".scratch/", ".out-of-scope/", "CHANGELOG.md",
    ".claude/", ".beads/", "isolated_test_workspace/", "prompts/",
    "CLAUDE.local.md",
)

# Pattern B: the ownership handle. Deliberately NOT CHANGELOG.md, whose
# `Thanks [@osxsystem]` lines are accurate historical attribution and whose
# target (the user profile) keeps resolving. Deliberately NOT CATALOG.md, which
# is generated from catalog.yaml and is regenerated after this runs.
HANDLE_FILES = (".github/CODEOWNERS", ".fork/catalog.yaml", ".fork/sync-playbook.md")

CHANGELOG = "CHANGELOG.md"


def walk():
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs if d not in (".git", "node_modules")]
        for f in files:
            full = os.path.join(root, f)
            p = os.path.relpath(full, ".")
            if p.startswith(EXCLUDE_PREFIXES) or p.endswith((".png", ".jpg", ".ico")):
                continue
            # AGENTS.md is a symlink to CLAUDE.md; writing through it would
            # rewrite the same file twice and double-count the report.
            if os.path.islink(full):
                continue
            yield p


def read(p):
    try:
        with open(p, encoding="utf-8") as fh:
            return fh.read()
    except (UnicodeDecodeError, IsADirectoryError):
        return None


def main():
    check = "--check" in sys.argv
    report = []

    # --- Pattern A: repo coordinates ---------------------------------------
    # `osxsystem/skills` only. Cannot match `osxsystem-skills` (the package
    # name) or `setup-osxsystem-skills` (a published skill), which is what
    # keeps the identity class intact by construction.
    for p in sorted(walk()):
        s = read(p)
        if s is None or f"{OLD}/skills" not in s:
            continue
        n = s.count(f"{OLD}/skills")
        out = s.replace(f"{OLD}/skills", f"{NEW}/skills")
        if not check:
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(out)
        report.append(("A", p, n))

    # --- Pattern B: ownership handle ---------------------------------------
    for p in HANDLE_FILES:
        s = read(p)
        if s is None or f"@{OLD}" not in s:
            continue
        n = s.count(f"@{OLD}")
        out = s.replace(f"@{OLD}", f"@{NEW}")
        if not check:
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(out)
        report.append(("B", p, n))

    # --- Pattern C: CHANGELOG.md, three sub-cases --------------------------
    # The changelog is a record, so it is not swept by Pattern A. But deleting
    # the old repository kills every link in it, and the three link classes do
    # not have the same correct answer.
    s = read(CHANGELOG)
    if s is not None:
        # C2 first: de-link pull references. The PRs do not exist at the new
        # address (we pushed rather than transferred), so rewriting the owner
        # would produce a link that 404s. Changesets emits each `[#N](pull/N)`
        # adjacent to a `[sha](commit/sha)` that DOES resolve, so dropping the
        # URL and keeping `#N` as plain text loses nothing navigable.
        s, c2 = re.subn(
            r"\[#(\d+)\]\(https://github\.com/" + OLD + r"/skills/pull/\d+\)",
            r"#\1",
            s,
        )
        # C1: commit links. All 558 commits were pushed, so these resolve at
        # the new address.
        c1 = s.count(f"{OLD}/skills/commit/")
        s = s.replace(f"{OLD}/skills/commit/", f"{NEW}/skills/commit/")
        # C3: issue links point at upstream issue numbers (453, 878, 905) that
        # never existed in this repo, so they are broken TODAY. The correct
        # target is upstream, not either of our addresses.
        c3 = s.count(f"{OLD}/skills/issues/")
        s = s.replace(f"{OLD}/skills/issues/", f"{UPSTREAM}/skills/issues/")
        if not check:
            with open(CHANGELOG, "w", encoding="utf-8") as fh:
                fh.write(s)
        report.append(("C1 commit-links", CHANGELOG, c1))
        report.append(("C2 pull-delinked", CHANGELOG, c2))
        report.append(("C3 issues->upstream", CHANGELOG, c3))

    width = max(len(p) for _, p, _ in report)
    for pat, p, n in report:
        print(f"  {pat:22} {p:<{width}}  {n}")
    print(f"\n{'would change' if check else 'changed'}: "
          f"{sum(n for _, _, n in report)} occurrences across "
          f"{len({p for _, p, _ in report})} files")


if __name__ == "__main__":
    main()
