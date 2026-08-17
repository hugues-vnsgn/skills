#!/usr/bin/env bash
# Fail-closed test for forkcheck.py.
# Contract: each of the four assertions fails when its invariant is violated,
# and the guard fails — rather than passing vacuously — when an input it needs
# is missing or unreadable. Every case runs against a throwaway copy of the
# repo, so nothing here mutates the working tree.
set -uo pipefail

REPO="$(cd "${1:-.}" && pwd)"
RESULTS_DIR="${2:-$(mktemp -d)}"
RESULTS="$RESULTS_DIR/forkcheck-tests.tsv"
mkdir -p "$RESULTS_DIR"
: > "$RESULTS"

GUARD="$REPO/scripts/harness/forkcheck.py"
if [ ! -f "$GUARD" ]; then
  echo "error: forkcheck not found at $GUARD" >&2
  exit 1
fi

SCRATCH="$(mktemp -d)"
TEMPLATE="$SCRATCH/template"
WORK="$SCRATCH/work"
trap 'rm -rf "$SCRATCH"' EXIT

cp -R "$REPO" "$TEMPLATE"
rm -rf "$TEMPLATE/isolated_test_workspace" "$TEMPLATE/node_modules"

pass=0
fail=0

# run <name> <expected_exit> <expected_substring> <seed_fn> [forkcheck args...]
run() {
  local name="$1" expected="$2" needle="$3" seed="$4"
  shift 4
  rm -rf "$WORK"
  cp -R "$TEMPLATE" "$WORK"
  ( cd "$WORK" && "$seed" ) || { echo "error: seed $seed failed" >&2; exit 1; }

  local out status verdict
  out=$(python3 "$WORK/scripts/harness/forkcheck.py" "$WORK" "$@" 2>&1)
  status=$?

  if [ "$status" -eq "$expected" ] && printf '%s' "$out" | grep -qF -- "$needle"; then
    verdict=PASS; pass=$((pass + 1))
  else
    verdict=FAIL; fail=$((fail + 1))
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$name" "$expected" "$status" "$verdict" "${out//$'\n'/ }" >> "$RESULTS"
  printf '%-34s expected=%s actual=%s  %s\n' "$name" "$expected" "$status" "$verdict"
  if [ "$verdict" = FAIL ]; then
    printf '    wanted substring: %s\n' "$needle"
    printf '    got: %s\n' "${out//$'\n'/ | }"
  fi
}

lock_sha() { grep '^upstream_sha:' .fork/upstream.lock | awk '{print $2}'; }

seed_none() { :; }

# --- assertion 1: frozen upstream ---
seed_upstream_drift() { echo "fork edit" >> skills/engineering/implement/SKILL.md; }
seed_fork_file_in_upstream_folder() {
  mkdir -p skills/engineering/rogue-skill
  printf -- '---\nname: rogue-skill\ndescription: x\n---\n' \
    > skills/engineering/rogue-skill/SKILL.md
}
seed_undeclared_fork_tree() {
  mkdir -p undeclared-tree && echo "hello" > undeclared-tree/notes.md
}
seed_stale_sanctioned_entry() { git show "$(lock_sha):.gitignore" > .gitignore; }

# --- assertion 2: unique skill names ---
seed_duplicate_skill_name() { cp -R skills/engineering/tdd skills/team/mobile/tdd; }

# --- assertion 3: catalog completeness ---
seed_catalogued_not_on_disk() { rm -rf skills/team/mobile/kmp-module-setup; }
seed_on_disk_not_catalogued() {
  mkdir -p skills/team/mobile/uncatalogued
  printf -- '---\nname: uncatalogued\ndescription: x\n---\n' \
    > skills/team/mobile/uncatalogued/SKILL.md
}

# --- assertion 4: no plugin directory ---
# Restored byte-identical to upstream, so assertion 1 sees no drift: only the
# absence check can catch this one.
seed_plugin_dir_restored() {
  mkdir -p .claude-plugin && git show "$(lock_sha):.claude-plugin/plugin.json" \
    > .claude-plugin/plugin.json
}

# --- assertion 5: changesets address this fork's package ---
# The shape a sync imports: a changeset naming upstream's package. It conflicts
# with nothing and fails the Release workflow, not this one — hence the guard.
seed_changeset_upstream_package() {
  mkdir -p .changeset
  # `printf '---...'` would read the YAML fence as options; feed it as data.
  printf '%s\n' '---' '"mattpocock-skills": patch' '---' '' 'imported from upstream' \
    > .changeset/zz-imported-from-upstream.md
}

# --- fail-closed: unreadable inputs ---
seed_rm_catalog() { rm -f .fork/catalog.yaml; }
seed_corrupt_catalog() { printf 'skills:\n  - [unclosed\n' > .fork/catalog.yaml; }
seed_empty_catalog() { printf 'version: 1\nskills: []\n' > .fork/catalog.yaml; }
seed_rm_sanctioned() { rm -f .fork/sanctioned-edits.txt; }
seed_empty_sanctioned() { printf '# nothing sanctioned\n' > .fork/sanctioned-edits.txt; }
seed_rm_divergence() { rm -f .fork/divergence.md; }
seed_empty_divergence() { printf '# Divergence record\n' > .fork/divergence.md; }
seed_rm_lock() { rm -f .fork/upstream.lock; }

echo "=== BASELINE: unmodified tree must pass (exit 0) ==="
run "clean tree" 0 "PASS" seed_none

echo
echo "=== ASSERTION 1: frozen upstream (exit 1) ==="
run "upstream file drifts"        1 "sanctioned-edits.txt" seed_upstream_drift
run "fork file in upstream folder" 1 "sanctioned-edits.txt" seed_fork_file_in_upstream_folder
run "undeclared fork tree"        1 "divergence.md" seed_undeclared_fork_tree
run "stale sanctioned entry"      1 "drop the entry" seed_stale_sanctioned_entry

echo
echo "=== ASSERTION 2: unique skill names (exit 1) ==="
run "duplicate skill basename"    1 "FAIL  unique-skill-names" seed_duplicate_skill_name

echo
echo "=== ASSERTION 3: catalog completeness (exit 1) ==="
run "catalogued, not on disk"     1 "no SKILL.md on disk" seed_catalogued_not_on_disk
run "on disk, not catalogued"     1 "missing from .fork/catalog.yaml" seed_on_disk_not_catalogued

echo
echo "=== ASSERTION 4: plugin directory absent (exit 1) ==="
run "plugin dir restored"         1 "FAIL  no-plugin-dir" seed_plugin_dir_restored

echo
echo "=== ASSERTION 5: changesets address this fork's package (exit 1) ==="
run "changeset names upstream pkg" 1 "FAIL  changeset-package" seed_changeset_upstream_package

echo
echo "=== FAIL-CLOSED: unreachable upstream must not pass (exit 1) ==="
run "unresolvable upstream ref"   1 "cannot resolve upstream ref" seed_none \
  --upstream-ref refs/remotes/upstream/no-such-branch
run "missing upstream.lock"       1 "cannot read .fork/upstream.lock" seed_rm_lock

echo
echo "=== FAIL-CLOSED: unreadable control plane must not pass (exit 1) ==="
run "missing catalog"             1 "cannot read .fork/catalog.yaml" seed_rm_catalog
run "unparseable catalog"         1 "not valid YAML" seed_corrupt_catalog
run "empty catalog"               1 "lists no skills" seed_empty_catalog
run "missing sanctioned-edits"    1 "cannot read .fork/sanctioned-edits.txt" seed_rm_sanctioned
run "empty sanctioned-edits"      1 "lists no paths" seed_empty_sanctioned
run "missing divergence record"   1 "cannot read .fork/divergence.md" seed_rm_divergence
run "divergence without Additions" 1 "declares no fork-owned paths" seed_empty_divergence

echo
echo "pass=$pass fail=$fail"
printf '%s\t%s\n' "$pass" "$fail" > "$RESULTS_DIR/forkcheck-counts.tsv"
[ "$fail" -eq 0 ]
