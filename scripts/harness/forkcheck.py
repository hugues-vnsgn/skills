#!/usr/bin/env python3
"""Fork boundary guard. Five assertions over externally observable repo state.

    python3 scripts/harness/forkcheck.py                       # repo root defaults to .
    python3 scripts/harness/forkcheck.py <repo> --upstream-ref upstream/main

  1. frozen-upstream       upstream territory is byte-identical to the upstream
                           commit, modulo `.fork/sanctioned-edits.txt`
  2. unique-skill-names    no two skill directories share a basename
  3. catalog-completeness  every skill has a catalog entry and vice versa
  4. plugin-dir-marketplace-only
                           `.claude-plugin/` holds the generated
                           `marketplace.json` and nothing else (ADR 0002)
  5. changeset-package     every changeset addresses this fork's package, not
                           the one upstream's imported changesets name

Upstream territory, per the scope header of `.fork/sanctioned-edits.txt`: every
path upstream ships, plus every path under an upstream-owned folder — so a fork
file dropped into `skills/engineering/` is upstream territory too and must be
enumerated. Everything else is fork territory and must match a tree declared
under Additions in `.fork/divergence.md`.

Which upstream commit? `.fork/upstream.lock`'s `upstream_sha` — the last commit
this fork merged. Comparing against a live `upstream/main` would turn any
upstream push into a red build on an untouched fork. Pass
`--upstream-ref upstream/main` during a sync, when the two are meant to converge.

Fails closed: an unresolvable upstream ref, an unreadable lock, sanctioned-edits
list, divergence record, or catalog is an error, not a skipped check. Needs
`pyyaml`, like `skillcheck.py`.
"""
import fnmatch
import json
import os
import re
import subprocess
import sys

# Folders whose contents upstream owns, whatever the file's author. Anything
# here that differs from upstream must be listed in sanctioned-edits.txt.
UPSTREAM_FOLDERS = (
    "skills/engineering/",
    "skills/productivity/",
    "skills/misc/",
    "skills/in-progress/",
    "skills/deprecated/",
    "docs/engineering/",
    "docs/productivity/",
)

# Artifacts the release process writes, which upstream also ships. Their
# divergence is guaranteed, permanent and carries no review value, so
# frozen-upstream skips them rather than demanding a sanctioned-edits entry.
# See the release-artifacts row in divergence.md's Additions table.
RELEASE_ARTIFACTS = (
    ".changeset/*.md",
    "CHANGELOG.md",
)

PLUGIN_DIR = ".claude-plugin"

# The only file allowed inside PLUGIN_DIR. It is picker metadata for the
# skills.sh installer — see scripts/generate-marketplace.py. `plugin.json` is
# what makes the directory an install route, so it stays out.
PLUGIN_DIR_ALLOWED = ("marketplace.json",)


class Fatal(Exception):
    """Something the guard needs is missing or unreadable — fail closed."""


def git(repo, *args):
    proc = subprocess.run(
        ["git", "-C", repo, *args],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise Fatal(f"`git {' '.join(args)}` failed: {proc.stderr.strip()}")
    return proc.stdout


def read(repo, relpath):
    path = os.path.join(repo, relpath)
    try:
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    except OSError as exc:
        raise Fatal(f"cannot read {relpath}: {exc}")


# --- inputs -----------------------------------------------------------------


def load_sanctioned(repo):
    """The upstream paths allowed to differ. One path per line, `#` comments."""
    paths = set()
    for line in read(repo, ".fork/sanctioned-edits.txt").splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            paths.add(line)
    if not paths:
        raise Fatal(".fork/sanctioned-edits.txt lists no paths")
    return paths


def load_fork_trees(repo):
    """Fork-owned paths, from the Additions table in `.fork/divergence.md`.

    Every backticked token in the first column of that table. A trailing slash
    means a tree; `*` globs. Additions are sync-inert: upstream never writes
    them, so they need no sanctioned-edits entry.
    """
    text = read(repo, ".fork/divergence.md")
    patterns = set()
    in_additions = False
    for line in text.splitlines():
        if line.startswith("## "):
            in_additions = line.strip().startswith("## Additions")
            continue
        if not in_additions or not line.startswith("|"):
            continue
        cells = line.split("|")
        if len(cells) < 2:
            continue
        first = cells[1]
        for token in first.split("`")[1::2]:
            token = token.strip()
            if token and not token.startswith("-"):
                patterns.add(token)
    if not patterns:
        raise Fatal(
            ".fork/divergence.md declares no fork-owned paths — expected a "
            "`## Additions` table with backticked paths in its first column"
        )
    return patterns


def load_catalog(repo):
    try:
        import yaml
    except ImportError:
        raise Fatal("pyyaml is not installed (`pip install pyyaml`)")
    try:
        data = yaml.safe_load(read(repo, ".fork/catalog.yaml"))
    except yaml.YAMLError as exc:
        raise Fatal(f".fork/catalog.yaml is not valid YAML: {exc}")
    if not isinstance(data, dict) or not isinstance(data.get("skills"), list):
        raise Fatal(".fork/catalog.yaml must be a mapping with a `skills` list")
    entries = []
    for i, entry in enumerate(data["skills"]):
        if not isinstance(entry, dict) or not entry.get("name") or not entry.get("path"):
            raise Fatal(f".fork/catalog.yaml: skills[{i}] needs a `name` and a `path`")
        entries.append((entry["name"], entry["path"], entry.get("domain")))
    if not entries:
        raise Fatal(".fork/catalog.yaml lists no skills")
    return entries


def resolve_upstream(repo, ref):
    """The commit upstream territory is compared against."""
    if ref is None:
        for line in read(repo, ".fork/upstream.lock").splitlines():
            if line.startswith("upstream_sha:"):
                ref = line.split(":", 1)[1].strip()
                break
        if not ref:
            raise Fatal(".fork/upstream.lock declares no `upstream_sha`")
    try:
        return ref, git(repo, "rev-parse", "--verify", f"{ref}^{{commit}}").strip()
    except Fatal:
        raise Fatal(
            f"cannot resolve upstream ref `{ref}` — run "
            f"`git fetch upstream main` (CI: the fetch-upstream step)"
        )


def skill_dirs(repo):
    """Every skill directory under skills/ — a directory holding a SKILL.md.

    Scoped to skills/ so the gitignored isolated_test_workspace/ copy the
    harness makes is not mistaken for a second tree of skills.
    """
    root = os.path.join(repo, "skills")
    if not os.path.isdir(root):
        raise Fatal("no skills/ directory — run from the repo root")
    found = set()
    for dirpath, _dirnames, filenames in os.walk(root):
        if "SKILL.md" in filenames:
            found.add(os.path.relpath(dirpath, repo))
    if not found:
        raise Fatal("found no skills under skills/")
    return found


# --- assertions -------------------------------------------------------------


def fork_owned(path, patterns):
    for pattern in patterns:
        if pattern.endswith("/"):
            if path.startswith(pattern):
                return True
        elif "*" in pattern:
            if fnmatch.fnmatch(path, pattern):
                return True
        elif path == pattern:
            return True
    return False


def check_frozen_upstream(repo, ref, sanctioned, fork_trees):
    """Assertion 1 — upstream territory differs only where sanctioned."""
    ref_name, sha = resolve_upstream(repo, ref)
    upstream_files = set(git(repo, "ls-tree", "-r", "--name-only", sha).splitlines())

    changed = {}
    # --no-renames so a rename reads as delete + add, matching how
    # sanctioned-edits.txt enumerates both sides of the setup-skill rename.
    for line in git(repo, "diff", "--no-renames", "--name-status", sha).splitlines():
        if not line.strip():
            continue
        status, path = line.split("\t", 1)
        changed[path.strip()] = status.strip()
    for path in git(repo, "ls-files", "--others", "--exclude-standard").splitlines():
        if path.strip():
            changed.setdefault(path.strip(), "?")

    failures = []
    accounted = set()
    for path, status in sorted(changed.items()):
        # Release artifacts, declared fork-owned in divergence.md's Additions
        # table. Upstream ships them too, so upstream-presence would otherwise
        # override that declaration.
        #
        # Changesets are ephemeral release *inputs*: demanding a sanctioned
        # entry for each would be churn on files the next release deletes. The
        # `changeset-package` assertion covers what actually matters there.
        #
        # CHANGELOG.md is the release *output*, and it cannot be sanctioned at
        # all: `changeset version` diverges it — new H1, new version section —
        # only at the moment a release is cut, and until then it is identical
        # to upstream, which the stale-entry branch below rejects. A path that
        # fails one way before the release and the other way after has no
        # correct sanctioned-edits state; skipping is the only consistent one.
        if any(fnmatch.fnmatch(path, pat) for pat in RELEASE_ARTIFACTS):
            continue
        if path in upstream_files or path.startswith(UPSTREAM_FOLDERS):
            if path in sanctioned:
                accounted.add(path)
            else:
                failures.append(
                    f"{status} {path}: upstream territory differs from {ref_name} "
                    f"but is not in .fork/sanctioned-edits.txt"
                )
        elif not fork_owned(path, fork_trees):
            failures.append(
                f"{status} {path}: fork path not covered by any tree under "
                f"Additions in .fork/divergence.md"
            )

    for path in sorted(sanctioned - accounted):
        failures.append(
            f"  {path}: listed in .fork/sanctioned-edits.txt but identical to "
            f"{ref_name} — drop the entry"
        )
    return failures


def load_planned_trees(repo):
    """Additions paths marked `(planned)` — declared before the tree exists.

    The marker sits immediately after the backticked path in the first column,
    so it attaches to one path even when a row declares several.
    """
    text = read(repo, ".fork/divergence.md")
    planned = set()
    in_additions = False
    for line in text.splitlines():
        if line.startswith("## "):
            in_additions = line.strip().startswith("## Additions")
            continue
        if not in_additions or not line.startswith("|"):
            continue
        cells = line.split("|")
        if len(cells) < 2:
            continue
        parts = cells[1].split("`")
        # parts alternates: text, token, text, token, ... — the text *after*
        # token i sits at parts[2 * i + 2].
        for i, token in enumerate(parts[1::2]):
            following = parts[2 * i + 2] if 2 * i + 2 < len(parts) else ""
            if following.lstrip().startswith("(planned)"):
                planned.add(token.strip())
    return planned


def check_declared_trees_exist(repo, fork_trees):
    """Assertion — every tree declared in Additions is actually on disk.

    `frozen-upstream` reads the same table in one direction only: it asks
    whether an existing fork path is declared. Nothing asks the reverse, so a
    row outliving the tree it describes rots silently — `research/` and
    `docs/superpowers/` both survived the commit that deleted them.

    Globs are skipped: `.changeset/*.md` legitimately matches nothing between
    releases, so its absence is not drift. A path followed by `(planned)` in
    the table is skipped too — the fork forward-declares a tree it intends to
    fill later, and that intent is deliberate rather than rot.
    """
    planned = load_planned_trees(repo)
    failures = []
    for pattern in sorted(fork_trees):
        if "*" in pattern or pattern in planned:
            continue
        if not os.path.exists(os.path.join(repo, pattern.rstrip("/"))):
            failures.append(
                f"{pattern}: declared under Additions in .fork/divergence.md "
                f"but not on disk — drop the row, or restore the tree"
            )
    return failures


def check_unique_skill_names(repo, skills):
    """Assertion 2 — the flat install namespace admits one skill per name."""
    by_name = {}
    for path in skills:
        by_name.setdefault(os.path.basename(path), []).append(path)
    return [
        f"{name}: {len(paths)} skills share this install name — {', '.join(sorted(paths))}"
        for name, paths in sorted(by_name.items())
        if len(paths) > 1
    ]


def check_catalog_completeness(repo, skills, entries):
    """Assertion 3 — the catalog and the tree describe the same set of skills."""
    failures = []
    catalogued = set()
    for name, path, _domain in entries:
        if os.path.basename(path) != name:
            failures.append(f"{path}: catalog name `{name}` is not the directory basename")
        if path in catalogued:
            failures.append(f"{path}: duplicate catalog entry")
        catalogued.add(path)
    for path in sorted(catalogued - skills):
        failures.append(f"{path}: in .fork/catalog.yaml but no SKILL.md on disk")
    for path in sorted(skills - catalogued):
        failures.append(f"{path}: on disk but missing from .fork/catalog.yaml")
    return failures


def check_plugin_dir_marketplace_only(repo):
    """Assertion 4 — the plugin route stays removed (ADR 0002).

    `.claude-plugin/marketplace.json` came back in the fork's 1.4 line, but only
    as grouping metadata for the skills.sh picker — see
    scripts/generate-marketplace.py. Everything else upstream keeps in that
    directory (`plugin.json` above all) is what makes it installable as a
    plugin, so a sync that drags those files back must still fail here.
    """
    failures = []
    root_plugin_dir = os.path.join(repo, PLUGIN_DIR)
    for dirpath, dirnames, filenames in os.walk(repo):
        # `.worktrees/` and `.claude/` each hold a full checkout of another
        # branch, whose own root `.claude-plugin/` is legitimate there.
        for skip in (".git", "node_modules", ".claude", ".worktrees",
                     "isolated_test_workspace"):
            if skip in dirnames:
                dirnames.remove(skip)
        if PLUGIN_DIR not in dirnames:
            continue
        found = os.path.join(dirpath, PLUGIN_DIR)
        rel = os.path.relpath(found, repo)
        if os.path.abspath(found) != os.path.abspath(root_plugin_dir):
            failures.append(
                f"{rel}: the only permitted plugin directory is the repo root's "
                f"{PLUGIN_DIR}/ — see .agents/adr/"
                f"0002-ship-as-a-claude-code-plugin.md"
            )
            continue
        for name in sorted(os.listdir(found)):
            if name in PLUGIN_DIR_ALLOWED:
                continue
            failures.append(
                f"{rel}/{name}: this fork ships via skills.sh only — "
                f"{PLUGIN_DIR}/ may hold "
                f"{' and '.join(PLUGIN_DIR_ALLOWED)} and nothing else. See "
                f".agents/adr/0002-ship-as-a-claude-code-plugin.md and the "
                f"recipe in .fork/divergence.md"
            )
    return failures


def check_marketplace_groups(repo, entries):
    """Assertion 6 — every shipped skill sits in exactly one picker group.

    The manifest is generated, so this asserts what the generator promises from
    the other side: read the committed file and the catalog independently, and
    compare. The failure this catches is drift — a skill catalogued and never
    regenerated is not a stale file, it is a skill that silently falls into the
    installer's "Other" heading.
    """
    path = os.path.join(repo, PLUGIN_DIR, "marketplace.json")
    if not os.path.exists(path):
        return [
            f"{PLUGIN_DIR}/marketplace.json is missing — run "
            f"`python3 scripts/generate-marketplace.py`"
        ]
    try:
        manifest = json.loads(read(repo, f"{PLUGIN_DIR}/marketplace.json"))
    except ValueError as exc:
        raise Fatal(f"cannot parse {PLUGIN_DIR}/marketplace.json: {exc}")

    # Must stay in step with `UNSHIPPED` in scripts/generate-marketplace.py —
    # this check asserts that generator's output, so a domain unshipped there
    # and expected here would fail every build.
    UNSHIPPED = ("misc", "in-progress", "deprecated", "in-development")
    expected = {path for _name, path, domain in entries if domain not in UNSHIPPED}

    failures = []
    seen = {}
    for plugin in manifest.get("plugins") or []:
        for entry in plugin.get("skills") or []:
            # The installer ignores any path that does not start with "./".
            if not entry.startswith("./"):
                failures.append(
                    f"{PLUGIN_DIR}/marketplace.json: `{entry}` must start with "
                    f"`./` or the installer drops it"
                )
                continue
            skill = entry[2:]
            if skill in seen:
                failures.append(
                    f"{PLUGIN_DIR}/marketplace.json: {skill} is in both "
                    f"`{seen[skill]}` and `{plugin.get('name')}`"
                )
            seen[skill] = plugin.get("name")

    for skill in sorted(expected - set(seen)):
        failures.append(
            f"{skill}: shipped in .fork/catalog.yaml but in no marketplace.json "
            f"group — it would fall to the installer's \"Other\" heading"
        )
    for skill in sorted(set(seen) - expected):
        failures.append(
            f"{skill}: in marketplace.json but not a shipped catalog entry"
        )
    return failures


# --- entry point ------------------------------------------------------------


def check_changeset_package(repo):
    """Assertion 5 — every changeset addresses this fork's package.

    Upstream ships changesets too, and they name upstream's package. A sync
    imports them verbatim, and `changeset version` then aborts with "which is
    not in the workspace" — failing the Release workflow, not this one. Catch
    it here, where a maintainer is already looking.
    """
    csdir = os.path.join(repo, ".changeset")
    if not os.path.isdir(csdir):
        return []
    try:
        pkg = json.loads(read(repo, "package.json"))["name"]
    except (ValueError, KeyError) as exc:
        raise Fatal(f"cannot read `name` from package.json: {exc}")
    failures = []
    for entry in sorted(os.listdir(csdir)):
        if not entry.endswith(".md") or entry == "README.md":
            continue
        for line in read(repo, f".changeset/{entry}").splitlines():
            match = re.match(r'^"([^"]+)":\s*(patch|minor|major)\s*$', line.strip())
            if match and match.group(1) != pkg:
                failures.append(
                    f".changeset/{entry}: addresses `{match.group(1)}`, not this "
                    f"fork's `{pkg}` — rewrite the package name (see the changeset "
                    f"step in .fork/sync-playbook.md)"
                )
    return failures


def run(repo, ref):
    sanctioned = load_sanctioned(repo)
    fork_trees = load_fork_trees(repo)
    entries = load_catalog(repo)
    skills = skill_dirs(repo)
    return [
        ("frozen-upstream", check_frozen_upstream(repo, ref, sanctioned, fork_trees)),
        ("declared-trees-exist", check_declared_trees_exist(repo, fork_trees)),
        ("unique-skill-names", check_unique_skill_names(repo, skills)),
        ("catalog-completeness", check_catalog_completeness(repo, skills, entries)),
        ("plugin-dir-marketplace-only", check_plugin_dir_marketplace_only(repo)),
        ("marketplace-groups", check_marketplace_groups(repo, entries)),
        ("changeset-package", check_changeset_package(repo)),
    ]


def main():
    args = sys.argv[1:]
    ref = None
    positional = []
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--upstream-ref":
            i += 1
            if i >= len(args):
                print("forkcheck: --upstream-ref needs a value", file=sys.stderr)
                return 1
            ref = args[i]
        elif arg.startswith("--upstream-ref="):
            ref = arg.split("=", 1)[1]
        elif arg.startswith("-"):
            print(f"forkcheck: unknown option `{arg}`", file=sys.stderr)
            return 1
        else:
            positional.append(arg)
        i += 1
    repo = positional[0] if positional else "."

    try:
        results = run(repo, ref)
    except Fatal as exc:
        print(f"forkcheck: {exc}", file=sys.stderr)
        print("FAIL — the guard could not verify the fork boundary", file=sys.stderr)
        return 1

    total = sum(len(f) for _, f in results)
    print(f"{len(results)} checks over {repo}")
    for name, failures in results:
        print(f"  {'FAIL' if failures else 'PASS'}  {name}")
        for failure in failures:
            print(f"        {failure}")
    print("PASS" if not total else f"{total} VIOLATION(S)")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
