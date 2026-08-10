#!/usr/bin/env bash
# Functional test for block-dangerous-git.sh.
# Contract: reads a Claude Code hook JSON payload on stdin, exits 2 to block a
# dangerous git command, 0 to allow. Runs entirely inside the workspace; the
# script only reads stdin and echoes, so no git command is ever executed.
set -uo pipefail

REPO="${1:-.}"
RESULTS_DIR="${2:-$(mktemp -d)}"
SCRIPT="$REPO/skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh"
RESULTS="$RESULTS_DIR/guardrail-tests.tsv"
mkdir -p "$RESULTS_DIR"
: > "$RESULTS"

if [ ! -f "$SCRIPT" ]; then
  echo "error: guardrail script not found at $SCRIPT" >&2
  exit 1
fi

pass=0
fail=0

# run <name> <expected_exit> <payload>
run() {
  local name="$1" expected="$2" payload="$3"
  local out status
  out=$(printf '%s' "$payload" | bash "$SCRIPT" 2>&1)
  status=$?
  local verdict
  if [ "$status" -eq "$expected" ]; then
    verdict=PASS; pass=$((pass + 1))
  else
    verdict=FAIL; fail=$((fail + 1))
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$name" "$expected" "$status" "$verdict" "${out//$'\n'/ }" >> "$RESULTS"
  printf '%-46s expected=%s actual=%s  %s\n' "$name" "$expected" "$status" "$verdict"
}

json() { printf '{"tool_input":{"command":"%s"}}' "$1"; }

echo "=== DANGEROUS: must block (exit 2) ==="
run "git push"                  2 "$(json 'git push')"
run "git push origin main"       2 "$(json 'git push origin main')"
run "git push --force"           2 "$(json 'git push --force')"
run "git reset --hard"           2 "$(json 'git reset --hard HEAD~1')"
run "git clean -fd"              2 "$(json 'git clean -fd')"
run "git clean -f"               2 "$(json 'git clean -f')"
run "git branch -D"              2 "$(json 'git branch -D feature')"
run "git checkout ."             2 "$(json 'git checkout .')"
run "git restore ."              2 "$(json 'git restore .')"

echo
echo "=== SAFE: must allow (exit 0) ==="
run "git status"                 0 "$(json 'git status')"
run "git log --oneline"          0 "$(json 'git log --oneline -5')"
run "git diff"                   0 "$(json 'git diff HEAD')"
run "git add -p"                 0 "$(json 'git add -p')"
run "git commit -m msg"          0 "$(json 'git commit -m \\\"fix thing\\\"')"
run "git branch -d (lowercase)"  0 "$(json 'git branch -d merged-branch')"
run "ls -la"                     0 "$(json 'ls -la')"

echo
echo "=== FAIL-CLOSED: unreadable payload must block (exit 2) ==="
run "empty stdin"                2 ""
run "malformed JSON"             2 "not json at all"
run "missing tool_input"         2 '{"other":"field"}'
run "null command"               2 '{"tool_input":{"command":null}}'

echo
echo "=== EDGE CASES: valid payload, nothing to block ==="
run "empty command string"       0 '{"tool_input":{"command":""}}'
run "whitespace-only command"    0 '{"tool_input":{"command":"   "}}'

echo
echo "=== OVER-BLOCK PROBES: mentions must NOT block (exit 0) ==="
run "git pushd (prefix collision)" 0 "$(json 'git pushd /tmp')"
run "commit msg says 'git push'"   0 "$(json 'git commit -m \\\"docs: explain git push safety\\\"')"
run "echo about reset --hard"       0 "$(json 'echo \\\"never run git reset --hard\\\"')"
run "grep for git push in file"     0 "$(json 'grep -r \\\"git push\\\" docs/')"
run "git log --grep=push"           0 "$(json 'git log --grep=push')"
run "git clean --dry-run (-n)"       0 "$(json 'git clean -n')"
run "git checkout branch (not .)"    0 "$(json 'git checkout main')"
run "git restore file (not .)"       0 "$(json 'git restore src/app.ts')"
run "git reset --soft"               0 "$(json 'git reset --soft HEAD~1')"

echo
echo "=== EVASION PROBES: dangerous in non-leading position must still block (exit 2) ==="
run "cd foo && git push"          2 "$(json 'cd foo && git push')"
run "git status; git push"        2 "$(json 'git status; git push')"
run "env var prefix"              2 "$(json 'GIT_DIR=.git git push origin main')"
run "git -C path push"            2 "$(json 'git -C /tmp/repo push')"
run "pipeline into push"          2 "$(json 'echo hi || git reset --hard HEAD')"
run "leading whitespace"          2 "$(json '   git push')"
run "git clean -xfd"              2 "$(json 'git clean -xfd')"
run "git branch -f -D name"       2 "$(json 'git branch -f -D old')"

echo
echo "pass=$pass fail=$fail"
printf '%s\t%s\n' "$pass" "$fail" > "$RESULTS_DIR/guardrail-counts.tsv"
[ "$fail" -eq 0 ]
