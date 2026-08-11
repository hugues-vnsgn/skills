# Beads (`bd`) — adoption research

**Date:** 2026-08-09
**Question:** Can Beads be adopted as an agent-facing tool in this repo, installed and configured alongside the skills we ship?
**Verified against:** `bd` 1.1.0 (Homebrew), `dolt` 2.2.2, `skills` npm 1.5.22, docs at <https://beads.gascity.com> (all 17 pages fetched, HTTP 200).

> **Method note.** The fan-out of three research subagents through the `claude` CLI failed on authentication (`401 Invalid bearer token`) for all three. Research was instead done directly: every doc page fetched over HTTP, plus a live probe of `bd` in throwaway directories under `/tmp`. Facts marked **verified** were observed from the local binary; the rest are cited to a doc URL. context7 was not reachable through the failed subagent route, so no context7 library IDs are recorded.

---

## 1. What Beads is

A dependency-aware issue tracker built for coding agents. Every unit of work is a **bead** (the CLI says "issue") in a version-controlled database; dependencies form a graph, and `bd ready` computes the claimable frontier — open beads with no open blockers. The pitch against a flat tracker: a flat list lets an agent pick work that is blocked and stall, while `bd ready` only ever returns workable items. ([core-concepts](https://beads.gascity.com/core-concepts), [quickstart](https://beads.gascity.com/getting-started/quickstart))

The problem it targets is agent memory loss across sessions — markdown plans rot, TODO comments scatter, a crashed agent takes its context with it.

## 2. Installation

`bd` is installed **system-wide, not cloned into the project**. The `.beads/` directory in a repo holds only the issue database. ([installation](https://beads.gascity.com/getting-started/installation))

| Route | Command | Prerequisites |
|---|---|---|
| Homebrew (recommended, macOS/Linux) | `brew install beads` | Homebrew |
| npm | `npm i -g @beads/bd` | Node.js |
| bun | `bun install -g --trust @beads/bd` | Bun |
| mise (all platforms) | `mise use -g github:gastownhall/beads` | mise |
| Install script (macOS/Linux/FreeBSD) | `curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh \| bash` | curl, bash |
| PowerShell (Windows) | `irm https://raw.githubusercontent.com/gastownhall/beads/main/install.ps1 \| iex` | — |
| `go install` (server-mode only) | `CGO_ENABLED=0 go install github.com/steveyegge/beads/cmd/bd@latest` | Go 1.24+ |
| `go install` (embedded-capable) | `CGO_ENABLED=1 GOFLAGS=-tags=gms_pure_go go install …` | Go 1.24+, C compiler |

**There is an npm-published Beads** (`@beads/bd`) — relevant because it is the one route a Node-based team already has tooling for. Note it is a *global* install, not a project dependency.

`go install` with `CGO_ENABLED=0` produces a **server-mode-only** binary that cannot run the default embedded Dolt backend; it requires an external `dolt sql-server` and `bd init --server`. Prefer Homebrew/npm/script.

Sync additionally requires **Dolt ≥ 2.2.0** on every machine (`bd` ≥ 0.59.0). ([sync-setup](https://beads.gascity.com/getting-started/sync-setup))

## 3. What `bd init` does — the big finding

**Verified.** `bd init` in a fresh git repo is far more invasive than "create a database". It wrote all of the following and **made a git commit** (`bd init: initialize beads issue tracking`, 18 files, 758 insertions):

```
.beads/               config.yaml, metadata.json, README.md, .gitignore,
                      hooks/{pre-commit,pre-push,post-merge,post-checkout,prepare-commit-msg},
                      embeddeddolt/            (the database; gitignored)
.claude/settings.json SessionStart hook → `bd prime --hook-json`
.codex/               hooks.json, config.toml
.agents/skills/beads/ SKILL.md + agents/openai.yaml   ← its own agent skill
AGENTS.md             created, with managed BEADS blocks
CLAUDE.md             created, with a managed BEADS block
.gitignore            appended
```

Two consequences for us:

- **It writes agent instruction files and commits them.** In a repo where `AGENTS.md`/`CLAUDE.md` are hand-maintained, that is an unrequested edit plus an unrequested commit. Flags that contain it: `--skip-agents` (no AGENTS.md / Claude / Codex setup), `--skip-hooks`, `--quiet` (non-interactive), `--stealth` (global gitignore, no local repo tracking), `--setup-exclude` (`.git/info/exclude` keeps beads files out of commits), `--role maintainer|contributor` (skips the wizard prompt).

  **Verified, and the important nuance: `--skip-agents` does not stop the commit.** `bd init --quiet --skip-agents` still makes the `bd init: initialize beads issue tracking` commit. There is **no `--no-commit` flag** — only `--stealth` / `--setup-exclude` avoid repo tracking entirely. What `--skip-agents` does buy, verified:

  | Behaviour | `bd init --quiet` | `bd init --quiet --skip-agents` |
  |---|---|---|
  | Writes managed blocks into `AGENTS.md` / `CLAUDE.md` | yes | **no** |
  | Installs `.claude/`, `.codex/`, `.agents/skills/beads/` | yes | **no** |
  | Makes a git commit | yes | **yes** |
  | Commits `.beads/` + `.gitignore` | yes | yes |

  **The staging is selective, not `git add -A`** (verified): with a dirty tracked file and an unrelated untracked file present, the `bd init` commit contained only `.beads/*` and `.gitignore`; `tracked.txt` stayed modified and `unrelated.txt` stayed untracked. The one trap — a **pre-existing untracked `AGENTS.md`/`CLAUDE.md` does get swept into that commit** even under `--skip-agents` (observed with an untracked `CLAUDE.md` plus an `AGENTS.md` symlink). In a repo where those files are already tracked and clean, nothing of theirs is committed.
- **Beads ships its own agent skill** at `.agents/skills/beads/SKILL.md`, in exactly our layout (`SKILL.md` + `agents/openai.yaml`, model-invoked, with a `description` full of trigger conditions). We do not need to write a Beads workflow skill; we need to decide whether to let it install alongside ours.

**Verified symlink behaviour.** With `AGENTS.md` → `CLAUDE.md` (this repo's layout) and an existing `CLAUDE.md`, `bd init --quiet` left the symlink intact and wrote its managed block into the real `CLAUDE.md`. `bd setup claude --check` then reported the integration current. The docs state `bd setup claude` skips the CLAUDE.md section when CLAUDE.md itself is a symlink; here the symlink was `AGENTS.md`, so the block landed. ([integrations/claude-code](https://beads.gascity.com/integrations/claude-code), [ide-setup](https://beads.gascity.com/getting-started/ide-setup))

## 4. Core model

A bead carries a hash ID (`bd-a1b2` — content-derived, so two agents or branches never mint the same ID and merges never renumber), a title, a type (`bug`, `task`, `feature`, `epic`, `chore`), a priority `0`–`4` (0 critical → 4 backlog; **not** high/medium/low), and a status `open → in_progress → closed`.

Dependency edge types (`bd dep add <issue> <depends-on> --type <t>`) — **verified** from `bd dep add --help`: `blocks` (default), `tracks`, `related`, `parent-child`, `discovered-from`, `until`, `caused-by`, `validates`, `relates-to`, `supersedes`. Only some affect `bd ready`:

| Blocking | Non-blocking |
|---|---|
| `blocks`, `parent-child`, `conditional-blocks`, `waits-for` | `related`, `tracks`, `discovered-from`, `caused-by`, `validates`, `supersedes` |

([core-concepts/dependencies](https://beads.gascity.com/core-concepts/dependencies))

**Verified ready-work semantics:** three open beads all appeared in `bd ready`; after `bd dep add B A`, `bd ready` returned 2 and B dropped out. Note `bd list --status=blocked` returned "No issues found" — blocked-ness is *computed*, not a stored status, so the query is `bd blocked`.

**Verified bulk wiring:** `bd dep add --file deps.jsonl` accepts newline-delimited `{"from":…,"to":…,"type":…}`, with `--no-cycle-check` per-edge and one whole-graph cycle check before commit. This is the primitive a "break a plan into tickets with blocking edges" skill wants.

**Verified JSON:** `bd create --json` returns the created bead including `id`; `bd ready --json` returns an array with `id`, `title`, `status`, `priority`, `issue_type`, `dependency_count`. Agents should always pass `--json`.

**Gates** park a step until the world catches up: type `human` (closed only by `bd gate resolve`), `timer` (Go durations — `24h`, never `1d`), `gh:run`, `gh:pr` (evaluated by `bd gate check`). A gate is a bead that blocks its waiters through a normal dependency edge — waiting on *other steps* is not a gate, it is a dependency. ([workflows/gates](https://beads.gascity.com/workflows/gates))

**Workflows** are a formula (TOML) → proto (template) → molecule (real beads) pipeline, with wisps as the ephemeral variant. Out of scope for a first adoption, but it is where repeatable checklists would live. ([workflows](https://beads.gascity.com/workflows))

## 5. Multi-agent coordination

- `bd update <id> --claim` is **atomic** — first claim wins, re-claiming what you hold is idempotent. `bd ready --claim --json` claims the first ready match. This is the guarantee against two agents grabbing the same issue. ([multi-agent/coordination](https://beads.gascity.com/multi-agent/coordination))
- **Merge slots** are an exclusive-access primitive, one per project (`bd merge-slot create|check|acquire|release`), for serialising conflict-prone work.
- There is **no agent registry** — assignees are plain strings; you discover active agents with `bd list --status in_progress --json`.
- `bd swarm create|status` builds a swarm molecule from an epic for structured fan-out.

## 6. Sync, conflicts, recovery

Issue data lives in Dolt and syncs under **`refs/dolt/data` on the ordinary git remote** — separate from `refs/heads/*`, so no extra server and no separate hosting. `bd init` wires the Dolt remote automatically when the repo has an `origin`. Day to day it is `bd dolt push` / `bd dolt pull`; a fresh clone runs `bd bootstrap`, because `git clone` does not fetch `refs/dolt/data`. ([sync-setup](https://beads.gascity.com/getting-started/sync-setup))

Rules worth encoding: never run raw `dolt` while the server is running (journal corruption); `bd dolt commit` before pulling; push before switching machines; **`.beads/issues.jsonl` is a passive export, not the source of truth, not the sync protocol, not a backup**.

**Merge conflicts** in issue data are *not* a git hunk conflict — the documented path is `bd doctor` → `bd doctor --fix` → verify → `bd dolt push`. Our `resolving-merge-conflicts` skill is about reconciling code hunks by intent and does not cover this; a Beads-backed repo needs the `bd doctor` path stated somewhere. ([recovery/merge-conflicts](https://beads.gascity.com/recovery/merge-conflicts))

**History squash** sheds reachable Dolt history that `dolt gc` cannot reclaim (every write mints a commit). It rewrites history, forces every other clone to re-clone, and needs all writers and scheduled syncs fenced first. Maintainer-only, rare, and dangerous. ([recovery/history-squash](https://beads.gascity.com/recovery/history-squash))

**Escape hatch:** `bd export` writes JSONL (`--all`, `--include-memories`, `--scrub`). There is also `bd notion sync` and GitHub/Jira/Linear config keys, but no documented one-shot "export to GitHub Issues".

## 7. Agent integration surface

The recommended route is **CLI + hooks, not MCP**: `bd prime` injects ~1–2k tokens of workflow context at session start, against 10–50k for MCP tool schemas. MCP (`uv tool install beads-mcp`) is for shell-less environments only, such as Claude Desktop. ([integrations/claude-code](https://beads.gascity.com/integrations/claude-code))

`bd setup <recipe>` writes per-harness integration; `--check` verifies, `--remove` removes only its own managed block. The two that matter to us:

| Recipe | Writes |
|---|---|
| `claude` | `.claude/settings.json` SessionStart hook + managed `CLAUDE.md` section |
| `codex` | `.agents/skills/beads/` + managed `AGENTS.md` section + `.codex/` hooks |

**Policy profiles** control what the agent may do at handoff: `conservative` (default — track work, but do not commit, push, or sync without approval), `minimal`, `team-maintainer` (may close beads, commit, push). Set with `bd config set agent.profile …` or `BD_AGENT_PROFILE`. The default is the safe one, and Beads never infers `team-maintainer` just because a remote exists.

Notably, the Beads docs argue **against** shipping Claude Skills ("Skills are Claude-specific, which would break beads' editor-agnostic approach") — yet `bd setup codex` installs one. Either way, a plugin is never required: **Beads is fully adoptable CLI-first**, which matches this fork's no-plugin stance. The optional Claude Code plugin (`/plugin marketplace add gastownhall/beads`) only adds `/beads:*` slash commands and a task agent, and it bundles no MCP server. ([integrations/claude-code-plugin](https://beads.gascity.com/integrations/claude-code-plugin))

## 8. Can `npx skills` install Beads? No.

**Verified** by unpacking `skills@1.5.22` (`vercel-labs/skills`): the package ships only `bin/cli.mjs` and `dist/cli.mjs`, and its `package.json` has **no `postinstall` or any lifecycle script**. Grepping the bundle for `postinstall|preinstall|onInstall|lifecycle|setupScript` found nothing. The README documents `add`, `use`, `list`, `find`, `update`, `remove`, `init` — all of them copy or symlink skill files into agent directories. Skill frontmatter is `name` + `description`; there is no dependency or prerequisite field.

So a teammate running `npx skills@latest add osxsystem/skills` **cannot** have `bd` installed as a side effect. What is achievable is the honest alternative: the skills land as files, and the **first thing the agent does when the setup skill runs** is detect `bd`, and if it is missing, print the one-line install command for the platform and wait. Installation is a human step; detection, guidance, and verification are the skill's job.

## 9. Preflight detection — verified exit codes

```bash
# Is bd installed?
command -v bd >/dev/null 2>&1 || { echo "bd not installed"; exit 1; }

bd version                       # e.g. "bd version 1.1.0 (Homebrew)"

# Is this repo a Beads workspace?  exit 0 = yes, exit 1 = no
if bd where >/dev/null 2>&1; then
  echo "beads workspace: $(bd where | head -1)"
else
  echo "no beads workspace here (bd init would create one)"
fi

# Sync configured?
bd dolt remote list              # expect: origin  <git remote url>
git ls-remote origin | grep dolt # expect: <hash>  refs/dolt/data
```

**Verified:** outside a Beads repo, both `bd where` and `bd ready` exit **1** with a hint on stderr; inside one, both exit **0**. Exit status is a reliable probe — but only when not piped, since a pipeline reports the last command's status.

## 10. Collisions with this repo's skills

| Our skill | With a Beads backend |
|---|---|
| `to-tickets` | Its whole output shape — slices with declaring blocking edges — is native: `bd create --json` per slice, then one `bd dep add --file` for the edges. Best fit of any skill. |
| `wayfinder` | The map/child/blocked/frontier/claim/resolve operations map almost 1:1: map = epic, children = `--parent` beads, frontier = `bd ready`, claim = `--claim` (atomic, unlike an assignee convention). |
| `triage` | Triage roles become labels (`bd update <id> --add-label`, `bd list --label-any`). The five canonical role strings still need a mapping file. |
| `to-spec` | "Publish to the issue tracker" becomes `bd create` with the spec as `--description`. |
| `implement` | Gains a real claim/close loop and `bd close --reason`; discovered work gets `--deps discovered-from:<id>` instead of a note. |
| `code-review` | Unaffected — it reviews a diff, not tickets. |
| `handoff` | Overlaps: Beads' own session-close protocol plus `bd remember` covers part of what a handoff document does. Not a conflict, but the two should not both claim to be the handoff mechanism. |
| `resolving-merge-conflicts` | **Gap.** It handles code hunks; Beads issue-data conflicts need `bd doctor --fix`. |
| `setup-osxsystem-skills` | The natural integration point: Beads is a fourth issue-tracker backend beside GitHub, GitLab, and local markdown. |

**One real conflict.** `bd prime` instructs: "Do NOT use TodoWrite, TaskCreate, or markdown files for task tracking", and the bundled Beads skill repeats it. Our **local-markdown** backend (`.scratch/<feature>/issues/NN-*.md`) is exactly that. The two cannot both be authoritative in one repo — so Beads is a *backend choice*, mutually exclusive with local markdown, not an additional layer on top of it.

## 11. Facts that will go stale

Version-stamp anything below on refresh (docs' own IDE-setup page carries "Last reviewed: 2026-07-10"):

- `bd` 1.1.0 / Dolt 2.2.2 minimums, and the Dolt ≥ 2.2.0 + `bd` ≥ 0.59.0 sync floor
- The `bd setup` recipe table (recipes are added often)
- Policy-profile names and the `agent.profile` key
- `skills` npm 1.5.22 having no lifecycle hooks — recheck before relying on it staying true
- The repo moved `steveyegge/beads` → `gastownhall/beads`, while Go modules still declare the old path
