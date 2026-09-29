#!/usr/bin/env bash
# Fail-closed test for skillcheck.py's agent assertions.
# Contract: every `agent-*` check passes on the committed agents tree, and each
# one fails when its invariant is violated: malformed or incomplete
# frontmatter, a preloaded skill that is missing or user-invoked, and a variant
# whose body has drifted from its base agent's. Every case runs against a
# throwaway copy of the repo, so nothing here mutates the working tree.
#
# Only `agent-*` rows are graded. The rest of skillcheck has its own CI step,
# and grading it here would fail every case on a dev machine with unrelated
# work in progress.
set -uo pipefail

REPO="$(cd "${1:-.}" && pwd)"
RESULTS_DIR="${2:-$(mktemp -d)}"
RESULTS="$RESULTS_DIR/agents-tests.tsv"
mkdir -p "$RESULTS_DIR"
: > "$RESULTS"

CHECK="$REPO/scripts/harness/skillcheck.py"
if [ ! -f "$CHECK" ]; then
  echo "error: skillcheck not found at $CHECK" >&2
  exit 1
fi
if [ ! -d "$REPO/agents" ]; then
  echo "error: no agents/ tree at $REPO/agents" >&2
  exit 1
fi

SCRATCH="$(mktemp -d)"
TEMPLATE="$SCRATCH/template"
WORK="$SCRATCH/work"
trap 'rm -rf "$SCRATCH"' EXIT

# skillcheck reads these and nothing else.
mkdir -p "$TEMPLATE/.fork"
cp -R "$REPO/agents" "$REPO/skills" "$REPO/docs" "$REPO/README.md" "$TEMPLATE/"
cp "$REPO/.fork/catalog.yaml" "$TEMPLATE/.fork/"

pass=0
fail=0

# The agent rows of a skillcheck run, one per line: "<status> <check> <notes>".
agent_rows() {
  python3 "$CHECK" "$WORK" --json 2>&1 | python3 -c '
import json, sys
for r in json.load(sys.stdin):
    if r["check"].startswith("agent-"):
        print(r["status"], r["check"], r["skill"], r["notes"])
'
}

# run <name> <expected: PASS|FAIL> <check that must fail, or -> <needle> <seed_fn>
run() {
  local name="$1" expected="$2" check="$3" needle="$4" seed="$5"
  rm -rf "$WORK"
  cp -R "$TEMPLATE" "$WORK"
  ( cd "$WORK" && "$seed" ) || { echo "error: seed $seed failed" >&2; exit 1; }

  local out verdict
  out=$(agent_rows)
  if [ "$expected" = PASS ]; then
    # Vacuous success is failure: the clean tree must yield agent rows at all.
    if [ -n "$out" ] && ! printf '%s\n' "$out" | grep -qv '^PASS '; then
      verdict=PASS
    else
      verdict=FAIL
    fi
  elif printf '%s\n' "$out" | grep -E "^FAIL $check " | grep -qF -- "$needle"; then
    verdict=PASS
  else
    verdict=FAIL
  fi
  if [ "$verdict" = PASS ]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi
  printf '%s\t%s\t%s\t%s\n' "$name" "$expected" "$verdict" "${out//$'\n'/ | }" >> "$RESULTS"
  printf '%-40s expected=%s  %s\n' "$name" "$expected" "$verdict"
  if [ "$verdict" = FAIL ]; then
    printf '    wanted: %s on %s containing %s\n' "$expected" "$check" "$needle"
    printf '    got: %s\n' "${out//$'\n'/ | }"
  fi
}

# edit <file> <python expression over t>: rewrite a file in place, and fail the
# seed if the edit changed nothing, so a stale anchor cannot pass vacuously.
edit() {
  python3 - "$1" "$2" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1]); t = p.read_text()
new = eval(sys.argv[2])
assert new != t, f"seed changed nothing in {p}"
p.write_text(new)
PY
}

seed_none() { :; }

# --- agent-frontmatter-parses ---
seed_no_frontmatter() { edit agents/implementer.md 't.split("---\n", 2)[2]'; }
seed_malformed_yaml() { edit agents/implementer.md 't.replace("maxTurns: 150", "maxTurns: [150", 1)'; }

# --- agent-required-fields ---
seed_missing_model() { edit agents/implementer.md 't.replace("model: sonnet\n", "", 1)'; }
seed_missing_max_turns() { edit agents/implementer-kmp.md 't.replace("maxTurns: 150\n", "", 1)'; }
seed_name_mismatch() { edit agents/implementer-kmp.md 't.replace("name: implementer-kmp", "name: implementer-mobile", 1)'; }

# --- agent-preloads-resolve ---
seed_preload_missing() { edit agents/implementer-kmp.md 't.replace("  - tdd-kmp\n", "  - no-such-skill\n", 1)'; }
seed_preload_user_invoked() {
  edit skills/house/mobile/kmp-test-seams/SKILL.md \
    't.replace("name: kmp-test-seams\n", "name: kmp-test-seams\ndisable-model-invocation: true\n", 1)'
}

# --- agent-body-matches-base ---
seed_variant_body_drift() { edit agents/implementer-kmp.md 't + "\nOne extra line only the KMP variant has.\n"'; }
seed_base_body_drift() { edit agents/implementer.md 't.replace("STATUS:", "STATE:", 1)'; }

echo "=== BASELINE: committed agents tree passes ==="
run "clean tree"                         PASS -                     ""                 seed_none

echo
echo "=== agent-frontmatter-parses ==="
run "no frontmatter block"               FAIL agent-frontmatter-parses "no --- frontmatter" seed_no_frontmatter
run "unparseable YAML"                   FAIL agent-frontmatter-parses "YAML error"   seed_malformed_yaml

echo
echo "=== agent-required-fields ==="
run "model missing"                      FAIL agent-required-fields "model"           seed_missing_model
run "maxTurns missing"                   FAIL agent-required-fields "maxTurns"        seed_missing_max_turns
run "name does not match filename"       FAIL agent-required-fields "implementer-mobile" seed_name_mismatch

echo
echo "=== agent-preloads-resolve ==="
run "preloaded skill does not exist"     FAIL agent-preloads-resolve "no-such-skill"  seed_preload_missing
run "preloaded skill is user-invoked"    FAIL agent-preloads-resolve "kmp-test-seams" seed_preload_user_invoked

echo
echo "=== agent-body-matches-base ==="
run "variant body drifts"                FAIL agent-body-matches-base "implementer"   seed_variant_body_drift
run "base body drifts"                   FAIL agent-body-matches-base "implementer"   seed_base_body_drift

echo
echo "pass=$pass fail=$fail"
printf '%s\t%s\n' "$pass" "$fail" > "$RESULTS_DIR/agents-counts.tsv"
[ "$fail" -eq 0 ]
