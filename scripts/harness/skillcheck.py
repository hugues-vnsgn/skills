#!/usr/bin/env python3
"""Per-skill validation harness. Runs inside isolated_test_workspace."""
import json
import os
import re
import sys

import yaml

_args = [a for a in sys.argv[1:] if not a.startswith("-")]
REPO = _args[0] if _args else "."
JSON_OUT = "--json" in sys.argv[1:]
# Upstream's two promoted buckets, plus every domain under the fork's team
# tree — `team/mobile`, `team/platform`, and their future siblings are promoted
# by construction, skill by skill unless the catalog marks one beta.
PROMOTED = {"engineering", "productivity"}
TEAM_TREE = "team"
DOC_SECTIONS = [
    "What it does",
    "When to reach for it",
    "Common questions",
    "It's working if",
]
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)\s]+)")


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def split_frontmatter(text):
    """Return (frontmatter_text, body) or (None, text) if absent."""
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return None, text
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return "\n".join(lines[1:i]), "\n".join(lines[i + 1:])
    return None, text


CODE_SPAN_RE = re.compile(r"`[^`\n]*`")
FENCE_RE = re.compile(r"^```.*?^```", re.MULTILINE | re.DOTALL)


def strip_code(text):
    """Remove fenced blocks and inline code spans.

    Links inside code are illustrative copy-me text aimed at a *target* repo,
    not references into this one, so they must not be resolved.
    """
    text = FENCE_RE.sub("", text)
    return CODE_SPAN_RE.sub("", text)


def rel_links(text):
    out = []
    for m in LINK_RE.finditer(strip_code(text)):
        t = m.group(1).strip()
        if t.startswith(("http://", "https://", "mailto:", "#")):
            continue
        # <placeholder> targets and bare template words are examples, not paths
        if t.startswith("<") or "." not in os.path.basename(t.split("#")[0]):
            continue
        out.append(t)
    return out


def resolve(base_dir, target):
    t = target.split("#")[0].strip()
    if not t:
        return True
    return os.path.exists(os.path.normpath(os.path.join(base_dir, t)))


def load_beta(repo):
    """Skill names the fork catalog marks `status: beta`.

    A team domain groups by capability, not maturity, so a beta team skill is
    marked in the catalog rather than parked in a beta folder. Reads fail
    closed: an unreadable catalog raises rather than yielding an empty set,
    which would silently demand promotion of every beta skill.
    """
    data = yaml.safe_load(read(os.path.join(repo, ".fork", "catalog.yaml"))) or {}
    return {e.get("name") for e in (data.get("skills") or [])
            if e.get("status") == "beta"}


def is_promoted(bucket, name, beta):
    """Promoted skills carry a docs page and a top-level README entry.

    A bucket is a *path* under skills/: upstream buckets are one segment
    (`engineering`), fork domains are two (`team/mobile`). Every team domain is
    promoted by construction — except the skills its catalog entry marks beta.
    """
    if name in beta:
        return False
    return bucket in PROMOTED or bucket.split("/")[0] == TEAM_TREE


def find_skills(repo):
    """Every skill dir under skills/, with its bucket as a path under skills/.

    Walked, not listed one level deep, because the fork's team tree groups
    skills by domain: `skills/team/mobile/<name>` has bucket `team/mobile`.
    Bucket doubles as the path segment for docs/<bucket>/<name>.md and
    skills/<bucket>/README.md, so both conventions follow the nesting.
    """
    skills = []
    skills_root = os.path.join(repo, "skills")
    for dirpath, _dirnames, filenames in os.walk(skills_root):
        if "SKILL.md" not in filenames:
            continue
        bucket = os.path.relpath(os.path.dirname(dirpath), skills_root)
        skills.append({
            "bucket": bucket.replace(os.sep, "/"),
            "name": os.path.basename(dirpath),
            "dir": dirpath,
        })
    return sorted(skills, key=lambda s: (s["bucket"], s["name"]))


def check_skill(repo, skill, beta):
    rows = []
    sdir = skill["dir"]
    bucket = skill["bucket"]
    name = skill["name"]
    skill_md_path = os.path.join(sdir, "SKILL.md")

    def row(check, status, notes=""):
        rows.append({
            "bucket": bucket, "skill": name, "check": check,
            "status": status, "notes": notes,
            "file": os.path.relpath(skill_md_path, repo),
        })

    text = read(skill_md_path)
    fm_text, body = split_frontmatter(text)

    # --- frontmatter parse ---
    fm = None
    if fm_text is None:
        row("frontmatter-parses", "FAIL", "no --- frontmatter block found")
    else:
        try:
            fm = yaml.safe_load(fm_text) or {}
            row("frontmatter-parses", "PASS")
        except yaml.YAMLError as e:
            row("frontmatter-parses", "FAIL", f"YAML error: {e}")

    fm = fm or {}

    # --- required keys ---
    if fm.get("name"):
        row("frontmatter-has-name", "PASS")
    else:
        row("frontmatter-has-name", "FAIL", "missing name:")
    if fm.get("description"):
        row("frontmatter-has-description", "PASS")
    else:
        row("frontmatter-has-description", "FAIL", "missing description:")

    # --- name matches directory ---
    fm_name = fm.get("name")
    if fm_name == name:
        row("name-matches-dir", "PASS")
    else:
        row("name-matches-dir", "FAIL", f"frontmatter name={fm_name!r} dir={name!r}")

    # --- description length ---
    desc = fm.get("description") or ""
    if len(desc) <= 1024:
        row("description-length", "PASS", f"{len(desc)} chars")
    else:
        row("description-length", "FAIL", f"{len(desc)} chars (>1024)")

    # --- disable-model-invocation / openai.yaml consistency ---
    dmi = fm.get("disable-model-invocation", False)
    yaml_path = os.path.join(sdir, "agents", "openai.yaml")
    allow_implicit = None
    yaml_parse_ok = None
    if os.path.isfile(yaml_path):
        raw = read(yaml_path)
        try:
            data = yaml.safe_load(raw) or {}
            yaml_parse_ok = True
            allow_implicit = ((data.get("policy") or {}).get("allow_implicit_invocation"))
        except yaml.YAMLError as e:
            yaml_parse_ok = False
            row("openai-yaml-parses", "FAIL", f"YAML error: {e}")
        if yaml_parse_ok:
            row("openai-yaml-parses", "PASS")
            # CLAUDE.md requires policy.allow_implicit_invocation: false only for
            # user-invoked skills (disable-model-invocation: true). Model-invoked
            # skills legitimately omit the policy block entirely.
            if not (data.get("interface") or {}).get("display_name"):
                row("openai-yaml-shape", "FAIL", "missing interface.display_name")
            elif dmi and allow_implicit is None:
                row("openai-yaml-shape", "FAIL",
                    "user-invoked skill missing policy.allow_implicit_invocation")
            else:
                row("openai-yaml-shape", "PASS",
                    "policy block present" if allow_implicit is not None
                    else "model-invoked: no policy block required")
    else:
        row("openai-yaml-parses", "FAIL", "agents/openai.yaml missing")

    if allow_implicit is not None:
        expected_allow = not dmi
        if allow_implicit == expected_allow:
            row("invocation-mode-consistency", "PASS",
                f"disable-model-invocation={dmi}, allow_implicit_invocation={allow_implicit}")
        else:
            row("invocation-mode-consistency", "FAIL",
                f"disable-model-invocation={dmi} but allow_implicit_invocation={allow_implicit} (expected {expected_allow})")

    # --- relative links resolve ---
    links = rel_links(text)
    broken = [l for l in links if not resolve(sdir, l)]
    if not links:
        row("links-resolve", "PASS", "no relative links")
    elif not broken:
        row("links-resolve", "PASS", f"{len(links)} link(s) checked")
    else:
        row("links-resolve", "FAIL", f"broken: {', '.join(broken)}")

    # --- docs page (promoted skills only) ---
    if is_promoted(bucket, name, beta):
        docs_path = os.path.join(repo, "docs", *bucket.split("/"), f"{name}.md")
        if os.path.isfile(docs_path):
            dtext = read(docs_path)
            missing_sections = [s for s in DOC_SECTIONS if f"## {s}" not in dtext]
            if not missing_sections:
                row("docs-page-sections", "PASS", os.path.relpath(docs_path, repo))
            else:
                row("docs-page-sections", "FAIL", f"missing sections: {', '.join(missing_sections)}")
        else:
            row("docs-page-exists", "FAIL", f"expected {os.path.relpath(docs_path, repo)}")

    return rows


def check_readme_membership(repo, skills, beta):
    rows = []
    readme = read(os.path.join(repo, "README.md"))
    for s in skills:
        bucket, name = s["bucket"], s["name"]
        link_pattern = re.compile(
            r"\[" + re.escape(name) + r"\]\(\./skills/" + re.escape(bucket) + r"/" + re.escape(name) + r"/SKILL\.md\)"
        )
        present = bool(link_pattern.search(readme))
        if is_promoted(bucket, name, beta):
            status = "PASS" if present else "FAIL"
            notes = "" if present else "expected linked entry in top-level README.md, not found"
        else:
            status = "PASS" if not present else "FAIL"
            where = "beta" if name in beta else f"{bucket}/ is non-promoted"
            notes = "" if not present else f"{where} but appears in top-level README.md"
        rows.append({"bucket": bucket, "skill": name, "check": "readme-membership",
                     "status": status, "notes": notes, "file": "README.md"})
    return rows


def check_bucket_readmes(repo, skills, beta):
    rows = []
    by_bucket = {}
    for s in skills:
        by_bucket.setdefault(s["bucket"], []).append(s["name"])
    by_bucket_dir = {}
    for s in skills:
        by_bucket_dir.setdefault(s["bucket"], []).append(s)
    for bucket, names in by_bucket.items():
        fm_dmi = {}
        for s in by_bucket_dir[bucket]:
            fm_text, _ = split_frontmatter(read(os.path.join(s["dir"], "SKILL.md")))
            try:
                fm = yaml.safe_load(fm_text) or {} if fm_text else {}
            except yaml.YAMLError:
                fm = {}
            fm_dmi[s["name"]] = bool(fm.get("disable-model-invocation", False))
        readme_path = os.path.join(repo, "skills", *bucket.split("/"), "README.md")
        if not os.path.isfile(readme_path):
            for name in names:
                rows.append({"bucket": bucket, "skill": name, "check": "bucket-readme-lists-skill",
                             "status": "FAIL", "notes": f"skills/{bucket}/README.md missing",
                             "file": f"skills/{bucket}/README.md"})
            continue
        text = read(readme_path)
        for name in names:
            link_pattern = re.compile(r"\[" + re.escape(name) + r"\]\(\./" + re.escape(name) + r"/SKILL\.md\)")
            present = bool(link_pattern.search(text))
            rows.append({"bucket": bucket, "skill": name, "check": "bucket-readme-lists-skill",
                         "status": "PASS" if present else "FAIL",
                         "notes": "" if present else "not linked in bucket README",
                         "file": f"skills/{bucket}/README.md"})
        if any(is_promoted(bucket, n, beta) for n in names):
            # A grouping heading is only required if that group is non-empty.
            # team/mobile has zero user-invoked skills today, so no
            # ## User-invoked heading is expected there - CLAUDE.md requires
            # the *split*, not both headings unconditionally.
            has_user = "## User-invoked" in text
            has_model = "## Model-invoked" in text
            # Beta skills sit under a flat `## Beta` heading, so they neither
            # populate nor require the invocation-mode groups.
            grouped = [n for n in names if is_promoted(bucket, n, beta)]
            expect_user = any(fm_dmi.get(n) for n in grouped)
            expect_model = any(not fm_dmi.get(n) for n in grouped)
            missing = []
            if expect_user and not has_user:
                missing.append("User-invoked")
            if expect_model and not has_model:
                missing.append("Model-invoked")
            status = "PASS" if not missing else "FAIL"
            notes = "" if status == "PASS" else f"missing heading(s): {', '.join(missing)}"
        else:
            has_grouping = ("## User-invoked" in text) or ("## Model-invoked" in text)
            status = "PASS" if not has_grouping else "FAIL"
            notes = "" if status == "PASS" else "non-promoted bucket README should be a flat list"
        rows.append({"bucket": bucket, "skill": "(bucket)", "check": "bucket-readme-grouping",
                     "status": status, "notes": notes, "file": f"skills/{bucket}/README.md"})
    return rows


def check_ask_matt_routing(repo, skills, beta):
    rows = []
    am_path = os.path.join(repo, "skills", "engineering", "ask-matt", "SKILL.md")
    text = read(am_path)
    promoted_names = [s["name"] for s in skills if is_promoted(s["bucket"], s["name"], beta)]
    all_names = {s["name"] for s in skills}
    for name in promoted_names:
        if name == "ask-matt":
            # ask-matt is the router; it doesn't need to cite itself.
            continue
        pattern = re.compile(r"/" + re.escape(name) + r"\b|\]\([^)]*" + re.escape(name) + r"[^)]*\)")
        present = bool(pattern.search(text))
        # File the row under the skill's *own* bucket, not ask-matt's, so
        # per-bucket skill counts stay accurate.
        owning_bucket = next(s["bucket"] for s in skills if s["name"] == name)
        rows.append({"bucket": owning_bucket, "skill": name, "check": "ask-matt-mentions-skill",
                     "status": "PASS" if present else "FAIL",
                     "notes": "" if present else "not referenced in ask-matt/SKILL.md",
                     "file": "skills/engineering/ask-matt/SKILL.md"})
    # Stale routes: /token references to skill-like slugs that don't exist as a
    # skill dir. Claude Code built-ins (/clear, /compact) and prose links to
    # external docs (smart-zone, ai-coding-dictionary) are not routes and must
    # be excluded, or every ask-matt run would flag its own built-in mentions.
    BUILTIN_COMMANDS = {"clear", "compact"}
    # Only count /name in *command position* - preceded by start-of-line or
    # whitespace/backtick/bold markers. A bare "/name" regex also matches URL
    # path segments (aihero.dev/ai-coding-dictionary/smart-zone) and filesystem
    # paths (.scratch/<feature>/issues/), which are not routes.
    referenced = set(re.findall(r"(?:^|[\s`*(])/([a-z][a-z0-9-]{3,})\b", text, re.MULTILINE))
    stale = sorted(n for n in referenced
                   if n not in all_names and n not in BUILTIN_COMMANDS and n != "ask-matt")
    # Links like [smart zone](.../ai-coding-dictionary/smart-zone) aren't /token
    # routes, so the regex above already excludes them; nothing further needed.
    if stale:
        rows.append({"bucket": "engineering", "skill": "ask-matt", "check": "ask-matt-no-stale-routes",
                     "status": "REVIEW", "notes": f"referenced but not found as a skill dir: {', '.join(stale)}",
                     "file": "skills/engineering/ask-matt/SKILL.md"})
    else:
        rows.append({"bucket": "engineering", "skill": "ask-matt", "check": "ask-matt-no-stale-routes",
                     "status": "PASS", "notes": "", "file": "skills/engineering/ask-matt/SKILL.md"})
    return rows


def check_install_block(repo):
    rows = []
    readme = read(os.path.join(repo, "README.md"))
    canonical = "npx skills@latest add osxsystem/skills"
    present = canonical in readme
    rows.append({"bucket": "-", "skill": "(repo)", "check": "install-block-in-readme",
                 "status": "PASS" if present else "FAIL",
                 "notes": "" if present else "canonical install command not found verbatim in README.md",
                 "file": "README.md"})

    # install-block.md scopes the no-duplication rule to *published* skill docs
    # pages (ai-hero renders the install widget above the body). docs/superpowers/
    # holds internal plan/spec records that quote the command as their subject.
    docs_dir = os.path.join(repo, "docs")
    dup_files = []
    for root, _, files in os.walk(docs_dir):
        if os.path.relpath(root, docs_dir).split(os.sep)[0] == "superpowers":
            continue
        for f in files:
            if f.endswith(".md"):
                p = os.path.join(root, f)
                if "npx skills@latest" in read(p):
                    dup_files.append(os.path.relpath(p, repo))
    rows.append({"bucket": "-", "skill": "(repo)", "check": "install-block-not-duplicated-in-docs",
                 "status": "PASS" if not dup_files else "FAIL",
                 "notes": "" if not dup_files else f"duplicated in: {', '.join(dup_files)}",
                 "file": "docs/"})

    plugin_dirs = []
    for root, dirs, _ in os.walk(repo):
        if ".claude-plugin" in dirs:
            plugin_dirs.append(os.path.relpath(os.path.join(root, ".claude-plugin"), repo))
    rows.append({"bucket": "-", "skill": "(repo)", "check": "no-claude-plugin-dir",
                 "status": "PASS" if not plugin_dirs else "FAIL",
                 "notes": "" if not plugin_dirs else f"found: {', '.join(plugin_dirs)}",
                 "file": "."})
    return rows


def main():
    skills = find_skills(REPO)
    beta = load_beta(REPO)
    rows = []
    for s in skills:
        rows.extend(check_skill(REPO, s, beta))
    rows.extend(check_readme_membership(REPO, skills, beta))
    rows.extend(check_bucket_readmes(REPO, skills, beta))
    rows.extend(check_ask_matt_routing(REPO, skills, beta))
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

