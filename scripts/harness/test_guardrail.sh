#!/usr/bin/env bash
# Functional test for block-dangerous-git.sh and the implementer guard that
# wraps it (agents/hooks/implementer-guard.sh).
# Contract: each reads a Claude Code hook JSON payload on stdin, exits 2 to
# block a command, 0 to allow. No gh or bd command is ever executed. The guard
# runs one read-only git query (the checked-out branch) against two throwaway
# repositories this script creates, a main checkout and an agent/ worktree,
# removed on exit along with the temp directory for the unreachable-guardrail
# case.
set -uo pipefail

REPO="${1:-.}"
RESULTS_DIR="${2:-$(mktemp -d)}"
SCRIPT="$REPO/skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh"
RESULTS="$RESULTS_DIR/guardrail-tests.tsv"
mkdir -p "$RESULTS_DIR"
: > "$RESULTS"

GUARD="$REPO/agents/hooks/implementer-guard.sh"
for f in "$SCRIPT" "$GUARD"; do
  if [ ! -f "$f" ]; then
    echo "error: guard script not found at $f" >&2
    exit 1
  fi
done
# The script under test; the implementer-guard section below switches it.
TARGET="$SCRIPT"

pass=0
fail=0

# run <name> <expected_exit> <payload>
run() {
  local name="$1" expected="$2" payload="$3"
  local out status
  out=$(printf '%s' "$payload" | bash "$TARGET" 2>&1)
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
# jsonc <command> <cwd>: the same payload, run from <cwd>.
jsonc() { printf '{"tool_input":{"command":"%s"},"cwd":"%s"}' "$1" "$2"; }

# A main checkout on `main` and an agent worktree off it, for the guard's
# branch check. Neither is ever pushed or changed by the guard.
SANDBOX="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$SANDBOX"' EXIT
MAIN="$SANDBOX/main"
WT="$SANDBOX/wt"
git init -q -b main "$MAIN"
git -C "$MAIN" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
git -C "$MAIN" worktree add -q "$WT" -b agent/spec--issue

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
echo "=== IMPLEMENTER GUARD: publishing commands must block (exit 2) ==="
# In these payloads \" is a real quote in the command and \n a real newline.
TARGET="$GUARD"
run "guard: git push"                  2 "$(json 'git push')"
run "guard: git -C path push"          2 "$(json 'git -C /tmp/wt push origin agent/x')"
run "guard: env-prefixed git push"     2 "$(json 'GIT_TRACE=1 git push')"
run "guard: git push after &&"         2 "$(json 'git commit -m wip && git push')"
run "guard: gh pr create"              2 "$(json 'gh pr create --fill')"
run "guard: gh pr merge"               2 "$(json 'gh pr merge 12 --squash')"
run "guard: gh pr create after ;"      2 "$(json 'git status; gh pr create --draft')"
run "guard: bd dolt push"              2 "$(json 'bd --sandbox dolt push')"
run "guard: bd dolt pull"              2 "$(json 'bd --sandbox dolt pull')"
run "guard: bd --actor x dolt push"    2 "$(json 'bd --actor implementer-x --sandbox dolt push')"
run "guard: env-prefixed bd dolt pull" 2 "$(json 'BEADS_ACTOR=x bd --sandbox dolt pull')"
run "guard: still blocks reset --hard" 2 "$(json 'git reset --hard HEAD~1')"

echo
echo "=== IMPLEMENTER GUARD: shell forms around a publishing command (exit 2) ==="
run "guard: after |&"                  2 "$(json 'ls |& bd --sandbox dolt push')"
run "guard: after background &"        2 "$(json 'ls & gh pr create')"
run "guard: after newline"             2 "$(json 'git status\ngit push')"
run "guard: in subshell"               2 "$(json '(git push)')"
run "guard: in brace group"            2 "$(json '{ gh pr create; }')"
run "guard: in command substitution"   2 "$(json 'echo $(git push)')"
run "guard: in backticks"              2 "$(json 'echo `gh pr merge 3`')"
run "guard: bash -c"                   2 "$(json 'bash -c \"git push\"')"
run "guard: sh -lc"                    2 "$(json 'sh -lc \"cd x && gh pr create\"')"
run "guard: eval"                      2 "$(json 'eval \"git push\"')"
run "guard: command prefix"            2 "$(json 'command git push')"
run "guard: env prefix"                2 "$(json 'env GIT_TRACE=1 git push')"
run "guard: nohup prefix"              2 "$(json 'nohup git push')"
run "guard: timeout prefix"            2 "$(json 'timeout 60 gh pr create')"
run "guard: xargs prefix"              2 "$(json 'echo main | xargs git push origin')"
run "guard: absolute path to git"      2 "$(json '/usr/bin/git push')"
run "guard: git -c key=value push"     2 "$(json 'git -c core.x=1 push')"
run "guard: git --no-pager push"       2 "$(json 'git --no-pager push')"
run "guard: git --git-dir=x push"      2 "$(json 'git --git-dir=.git push')"
run "guard: git -C quoted path push"   2 "$(json 'git -C \"/tmp/a b\" push')"
run "guard: gh quoted flag value"      2 "$(json 'gh -R \"a/b\" pr create')"
run "guard: gh pr --repo x create"     2 "$(json 'gh pr --repo a/b create --fill')"
run "guard: bd quoted flag value"      2 "$(json 'bd --actor \"x\" --sandbox dolt push')"
run "guard: gh api POST"               2 "$(json 'gh api -X POST repos/a/b/pulls')"
run "guard: gh api --method=PUT"       2 "$(json 'gh api --method=PUT repos/a/b/pulls/3/merge')"
run "guard: gh api with fields"        2 "$(json 'gh api repos/a/b/pulls -f title=t -f head=x')"
run "guard: gh api graphql mutation"   2 "$(json 'gh api graphql -F query=@m.graphql')"

echo
echo "=== IMPLEMENTER GUARD: bd must carry --sandbox, which disables Dolt auto-push (exit 2) ==="
run "guard: bd update, no --sandbox"   2 "$(json 'bd update skills-1 --claim')"
run "guard: bd create, no --sandbox"   2 "$(json 'bd create \"t\" -d \"d\"')"
run "guard: bd show, no --sandbox"     2 "$(json 'bd show skills-1')"
run "guard: bd --sandbox=false"        2 "$(json 'bd --sandbox=false update skills-1')"

echo
echo "=== IMPLEMENTER GUARD: ordinary work must allow (exit 0) ==="
run "guard: git commit"                0 "$(json "git -C $WT commit -m \\\"feat: add thing\\\"")"
run "guard: git merge"                 0 "$(json "git -C $WT merge --no-ff agent/spec")"
run "guard: git -C path status"        0 "$(json 'git -C /tmp/wt status')"
run "guard: git -c key=value log"      0 "$(json 'git -c core.pager=cat log --oneline')"
run "guard: bd update --claim"         0 "$(json 'bd --sandbox update skills-1 --claim --actor implementer-skills-1')"
run "guard: bd --sandbox after args"   0 "$(json 'bd update skills-1 --claim --sandbox')"
run "guard: bd comments add"           0 "$(json 'bd --sandbox comments add skills-1 \"chose X\"')"
run "guard: bd create discovered"      0 "$(json 'bd --sandbox create \"t\" -d \"d\" --deps discovered-from:skills-1')"
run "guard: bd dolt commit"            0 "$(json 'bd --sandbox dolt commit')"
run "guard: gh pr view"                0 "$(json 'gh pr view 12')"
run "guard: gh pr list"                0 "$(json 'gh pr list')"
run "guard: gh api GET"                0 "$(json 'gh api repos/a/b/pulls/3')"
run "guard: mention in bd create"      0 "$(json 'bd --sandbox create \"never run bd dolt push\"')"
run "guard: mention in commit msg"     0 "$(json "git -C $WT commit -m \\\"docs: no gh pr create here\\\"")"
run "guard: grep for git push"         0 "$(json 'grep -rn \"git push\" docs/')"
run "guard: word bd inside a path"     0 "$(json 'ls ./bd-notes/')"

run "guard: gh api -X GET"             0 "$(json 'gh api -XGET repos/a/b/pulls/3')"
run "guard: gh api jq filter"          0 "$(json 'gh api repos/a/b/pulls -q .[].title')"
run "guard: git -C worktree commit"    0 "$(jsonc "git -C $WT commit -m x" "$MAIN")"
run "guard: chained -C to worktree"    0 "$(json "git -C $SANDBOX -C wt commit -m x")"
run "guard: cd worktree && git -C"     0 "$(jsonc "cd $WT && git -C $WT commit -m x" "$MAIN")"
run "guard: git checkout -- file"      0 "$(json "git -C $WT checkout -- a.txt")"
run "guard: git log in main checkout"  0 "$(jsonc 'git log --oneline -3' "$MAIN")"
run "guard: git branch --show-current" 0 "$(jsonc 'git branch --show-current' "$MAIN")"
run "guard: git worktree list"         0 "$(jsonc 'git worktree list' "$MAIN")"
run "guard: bd update in_progress"     0 "$(json 'bd --sandbox update skills-1 --status in_progress')"
run "guard: bd comment says closed"    0 "$(json 'bd --sandbox comments add skills-1 \"closed the gap\"')"

echo
echo "=== IMPLEMENTER GUARD: attached options and quoted --sandbox (exit 2) ==="
run "guard: gh api -XPUT"              2 "$(json 'gh api repos/a/b/pulls/3/merge -XPUT')"
run "guard: gh api -Xput lowercase"    2 "$(json 'gh api repos/a/b/pulls/3/merge -Xput')"
run "guard: gh api -iXPOST"            2 "$(json 'gh api -iXPOST repos/a/b/pulls')"
run "guard: gh api -ftitle=x"          2 "$(json 'gh api repos/a/b/pulls -ftitle=x')"
run "guard: gh api -Fquery=@q"         2 "$(json 'gh api graphql -Fquery=@m.graphql')"
run "guard: --sandbox only in quotes"  2 "$(json 'bd comments add skills-1 \"use --sandbox next time\"')"
run "guard: --sandbox only in quotes 2" 2 "$(json 'bd create \"x\" -d \"see --sandbox\"')"

echo
echo "=== IMPLEMENTER GUARD: no Issue close, git changes only on agent/ branches (exit 2) ==="
run "guard: bd close"                  2 "$(json 'bd --sandbox close skills-1')"
run "guard: bd close with reason"      2 "$(json 'bd --sandbox close skills-1 --reason \"done\"')"
run "guard: bd update --status closed" 2 "$(json 'bd --sandbox update skills-1 --status closed')"
run "guard: bd update -s=closed"       2 "$(json 'bd --sandbox update skills-1 -s=closed')"
run "guard: git -C main merge"         2 "$(jsonc "git -C $MAIN merge agent/x" "$WT")"
run "guard: git commit in main"        2 "$(jsonc 'git commit -m x' "$MAIN")"
run "guard: cd main && git merge"      2 "$(jsonc "cd $MAIN && git merge agent/x" "$WT")"
run "guard: checkout in main"          2 "$(json "git -C $MAIN checkout -b feature")"
run "guard: git add in main"           2 "$(json "git -C $MAIN add -A")"
run "guard: git stash in main"         2 "$(json "git -C $MAIN stash")"
run "guard: commit, no repo resolved"  2 "$(json "git -C $SANDBOX/missing commit -m x")"

echo
echo "=== IMPLEMENTER GUARD: a git write must name its worktree with an absolute -C (exit 2) ==="
# Codex gives each shell call its own directory and reports only the session's
# as cwd, so neither cwd nor cd can place a write, even when both are right.
run "guard: commit, cwd is worktree"   2 "$(jsonc 'git commit -m x' "$WT")"
run "guard: cd worktree && commit"     2 "$(jsonc "cd $WT && git commit -m x" "$WT")"
run "guard: relative -C"               2 "$(jsonc 'git -C wt commit -m x' "$SANDBOX")"
run "guard: -C through ~"              2 "$(json 'git -C ~ commit -m x')"
run "guard: -C through a variable"     2 "$(json 'git -C $W commit -m x')"
run "guard: -C through substitution"   2 "$(json 'git -C $(pwd) commit -m x')"
run "guard: -C through backticks"      2 "$(json 'git -C `pwd` commit -m x')"
run "guard: subcommand substituted"    2 "$(json "git -C $WT \$(echo commit) -m x")"
run "guard: read through a variable"   0 "$(json 'git -C $W log --oneline -5')"
run "guard: substitution inside a read" 0 "$(json "echo \$(git -C $WT log --oneline -1)")"
# A variable is the agent shortening a path it knows, so the message says what
# to write instead of reporting an unknown branch.
dynamic=$(printf '%s' "$(json 'git -C $W commit -m x')" | bash "$GUARD" 2>&1 >/dev/null)
case "$dynamic" in
  *"shell variable or substitution"*) pass=$((pass + 1)); printf '%-46s %s\n' "guard: variable -C message names the cause" PASS ;;
  *) fail=$((fail + 1)); printf '%-46s %s\n' "guard: variable -C message names the cause" FAIL ;;
esac
run "guard: GIT_DIR redirect"          2 "$(jsonc "GIT_DIR=$MAIN/.git git commit -m x" "$WT")"
run "guard: --work-tree redirect"      2 "$(jsonc "git --work-tree=$MAIN checkout -- ." "$WT")"
run "guard: git branch -f main"        2 "$(jsonc 'git branch -f main HEAD' "$WT")"
run "guard: git update-ref"            2 "$(jsonc 'git update-ref refs/heads/main HEAD' "$WT")"
run "guard: git worktree add"          2 "$(jsonc 'git worktree add ../x' "$WT")"
run "guard: fetch into local main"     2 "$(jsonc 'git fetch . agent/spec--issue:main' "$WT")"

echo
echo "=== IMPLEMENTER GUARD: the canary is always blocked, and only it (exit 2 / 0) ==="
run "guard: canary"                    2 "$(json 'implementer-guard-check')"
run "guard: canary, padded"            2 "$(json '  implementer-guard-check\n')"
run "guard: canary word in a grep"     0 "$(json 'grep -rn implementer-guard-check agents/')"
# The canary proves the guard is live only if its message is fixed: the
# implementing-an-issue skill compares against this exact line.
canary=$(printf '%s' "$(json 'implementer-guard-check')" | bash "$GUARD" 2>&1 >/dev/null)
if [ "$canary" = 'BLOCKED: implementer guard is live.' ]; then
  pass=$((pass + 1)); printf '%-46s %s\n' "guard: canary message is exact" PASS
else
  fail=$((fail + 1)); printf '%-46s %s\n' "guard: canary message is exact" FAIL
fi

echo
echo "=== IMPLEMENTER GUARD: fail closed (exit 2) ==="
run "guard: malformed JSON"            2 "not json at all"
run "guard: empty stdin"               2 ""
# A guard copied away from the skills repo cannot reach the guardrail it
# wraps, and must block rather than run half its checks.
ORPHAN="$(mktemp -d)"
mkdir -p "$ORPHAN/agents/hooks" && cp "$GUARD" "$ORPHAN/agents/hooks/"
TARGET="$ORPHAN/agents/hooks/implementer-guard.sh"
run "guard: guardrail unreachable"     2 "$(json 'ls')"
rm -rf "$ORPHAN"

echo
echo "pass=$pass fail=$fail"
printf '%s\t%s\n' "$pass" "$fail" > "$RESULTS_DIR/guardrail-counts.tsv"
[ "$fail" -eq 0 ]
