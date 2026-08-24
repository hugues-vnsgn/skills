#!/usr/bin/env bash
# Fail-closed test for skillcheck.py's repo-coordinate assertions.
#
# Contract: `no-stale-repo-coordinates` fails when a reference to the account
# this repo migrated away from reappears in a live file, still passes when the
# same string appears inside the recorded allowlist, and `coordinate-scan-
# readable` fails — rather than passing vacuously — when a file cannot be read.
#
# Every case runs against a throwaway copy of the repo, so nothing here mutates
# the working tree. Same shape as test_forkcheck.sh.
set -uo pipefail

REPO="$(cd "${1:-.}" && pwd)"
RESULTS_DIR="${2:-$(mktemp -d)}"
RESULTS="$RESULTS_DIR/coordinate-tests.tsv"
mkdir -p "$RESULTS_DIR"
: > "$RESULTS"

GUARD="$REPO/scripts/harness/skillcheck.py"
if [ ! -f "$GUARD" ]; then
  echo "error: skillcheck not found at $GUARD" >&2
  exit 1
fi

SCRATCH="$(mktemp -d)"
TEMPLATE="$SCRATCH/template"
WORK="$SCRATCH/work"
trap 'chmod -R u+rw "$SCRATCH" 2>/dev/null; rm -rf "$SCRATCH"' EXIT

cp -R "$REPO" "$TEMPLATE"
# Trees that are gitignored, machine-local, or merely slow to copy. A clean CI
# checkout has none of them, and `in-development/` skills that are not yet in
# the catalog would fail unrelated assertions.
rm -rf "$TEMPLATE/isolated_test_workspace" "$TEMPLATE/node_modules" \
       "$TEMPLATE/.claude" "$TEMPLATE/.beads" "$TEMPLATE/.git" \
       "$TEMPLATE/skills/house/in-development"

pass=0
fail=0

# run <name> <expected_exit> <expected_substring> <seed_fn>
run() {
  local name="$1" expected="$2" needle="$3" seed="$4"
  rm -rf "$WORK"
  cp -R "$TEMPLATE" "$WORK"
  ( cd "$WORK" && "$seed" ) || { echo "error: seed $seed failed" >&2; exit 1; }

  local out status verdict
  out=$(python3 "$WORK/scripts/harness/skillcheck.py" "$WORK" 2>&1)
  status=$?
  chmod -R u+rw "$WORK" 2>/dev/null

  if [ "$status" -eq "$expected" ] && printf '%s' "$out" | grep -qF -- "$needle"; then
    verdict=PASS; pass=$((pass + 1))
  else
    verdict=FAIL; fail=$((fail + 1))
  fi
  printf '%s\t%s\t%s\t%s\n' "$name" "$expected" "$status" "$verdict" >> "$RESULTS"
  printf '%-42s expected=%s actual=%s  %s\n' "$name" "$expected" "$status" "$verdict"
}

seed_clean() { :; }

seed_stale_coordinate_in_readme() {
  printf '\nInstall with `npx skills@latest add osxsystem/skills`.\n' >> README.md
}

seed_stale_handle_in_codeowners() {
  printf '\n/docs/                              @osxsystem\n' >> .github/CODEOWNERS
}

seed_stale_coordinate_in_skill() {
  printf '\nSee https://github.com/osxsystem/skills for details.\n' \
    >> skills/house/platform/sync-upstream/SKILL.md
}

# The allowlist is the point of the check: the changelog is a dated record we
# chose not to rewrite, so a stale string there must NOT fail the build.
seed_stale_coordinate_in_allowlist() {
  printf '\n- Historical note: osxsystem/skills and @osxsystem appear here.\n' >> CHANGELOG.md
}

# Fail closed: an unreadable file means the scan cannot certify the repo.
seed_unreadable_file() {
  printf 'placeholder\n' > MAINTENANCE.md
  chmod 000 MAINTENANCE.md
}

# --- stale tree name: the house tree used to be named team/ -----------------
# Same shape as the coordinate check: an upstream sync or an old habit can
# reintroduce the pre-rename paths, and only path-like forms are forbidden;
# the bare word "team" stays legal prose everywhere.
seed_stale_tree_path_in_readme() {
  printf '\nSee skills/team/mobile/ for the KMP skills.\n' >> README.md
}

seed_stale_docs_tree_in_role_page() {
  printf '\n- [kmp-module-setup](../../docs/team/mobile/kmp-module-setup.md)\n' \
    >> docs/roles/engineer.md
}

seed_stale_group_name_in_skill() {
  printf '\nExpand the team-platform group in the picker.\n' \
    >> skills/house/platform/sync-upstream/SKILL.md
}

seed_stale_tree_path_in_allowlist() {
  printf '\n- Historical note: this tree was skills/team/ before the rename.\n' \
    >> CHANGELOG.md
}

# The word itself is not the offence: prose about teams must keep passing.
seed_plain_word_team_in_prose() {
  printf '\nA team of reviewers can share this workflow.\n' >> README.md
}

echo "== skillcheck repo-coordinate assertions =="
run "baseline clean repo"                 0 "PASS"                          seed_clean
run "stale coordinate in README"          1 "no-stale-repo-coordinates"     seed_stale_coordinate_in_readme
run "stale handle in CODEOWNERS"          1 "no-stale-repo-coordinates"     seed_stale_handle_in_codeowners
run "stale coordinate in a SKILL.md"      1 "no-stale-repo-coordinates"     seed_stale_coordinate_in_skill
run "stale string inside allowlist"       0 "PASS"                          seed_stale_coordinate_in_allowlist
run "unreadable file fails closed"        1 "coordinate-scan-readable"      seed_unreadable_file

echo
echo "== skillcheck stale-tree-name assertions =="
run "stale skills/team path in README"    1 "no-stale-tree-name"            seed_stale_tree_path_in_readme
run "stale docs/team link in role page"   1 "no-stale-tree-name"            seed_stale_docs_tree_in_role_page
run "stale team- group name in a skill"   1 "no-stale-tree-name"            seed_stale_group_name_in_skill
run "stale tree path inside allowlist"    0 "PASS"                          seed_stale_tree_path_in_allowlist
run "plain word team stays legal prose"   0 "PASS"                          seed_plain_word_team_in_prose

echo
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
