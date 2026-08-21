This is the **osxsystem team fork** of mattpocock/skills, customized for mobile development with Kotlin Multiplatform + Compose Multiplatform (Android + iOS/Swift). Fork-specific conventions live in [MAINTENANCE.md](./MAINTENANCE.md); the `skills/team/` tree and its docs are fork additions that upstream syncs must preserve.

`skills/` is split by **provenance**. Upstream's buckets sit directly under it and are vendor territory — never moved, renamed, or edited outside the sanctioned list in [.fork/sanctioned-edits.txt](./.fork/sanctioned-edits.txt):

- `engineering/`: daily code work
- `productivity/`: daily non-code workflow tools
- `misc/`: kept around but rarely used, not promoted
- `in-progress/`: beta: public on purpose, feedback wanted, not promoted
- `deprecated/`: no longer used

Every fork-authored skill lives under `skills/team/`, grouped by capability **domain**. Upstream never writes there, so it is conflict-free:

- `team/mobile/` — Kotlin Multiplatform / Compose Multiplatform team skills
- `team/platform/` — the skill toolchain itself: repo setup, porting capabilities in, unsticking a design

A domain folder is created when its first skill lands — no empty growth slots. Each team domain is **promoted** and carries the same registration as an upstream promoted bucket: a bucket `README.md`, an entry in the top-level `README.md`, and a docs page.

Upstream encodes maturity in the bucket — `in-progress/` is beta. A team domain encodes capability instead, so maturity rides in the catalog: a skill whose [.fork/catalog.yaml](./.fork/catalog.yaml) entry carries `status: beta` is exempt from promotion — no docs page, kept out of the top-level `README.md`, listed under a flat `## Beta` heading in its bucket `README.md`. Drop the field to promote it, and add the missing registration in the same change.

Every skill in `engineering/`, `productivity/`, or any `team/<domain>/` (the **promoted** buckets) must have a reference in the top-level `README.md`. Skills in `misc/`, `in-progress/`, `deprecated/`, and any team skill marked `status: beta` must not appear there.

Install commands are copied verbatim from [.agents/install-block.md](./.agents/install-block.md). This fork ships via [skills.sh](https://skills.sh/osxsystem/skills) only — upstream's Claude Code plugin *install route* was removed. `.claude-plugin/` holds exactly one file, the generated [marketplace.json](./.claude-plugin/marketplace.json), which exists only so the installer's picker renders one collapsible group per domain with a "select all" row; `plugin.json` stays deleted and CI fails if a sync brings it back. Regenerate the manifest with `python3 scripts/generate-marketplace.py` whenever [.fork/catalog.yaml](./.fork/catalog.yaml) changes — never hand-edit it, and never take upstream's copy on conflict (see [MAINTENANCE.md](./MAINTENANCE.md)). The history of the plugin decision, and why the one file came back, lives in [.agents/adr/0002-ship-as-a-claude-code-plugin.md](./.agents/adr/0002-ship-as-a-claude-code-plugin.md).

A skill this fork does not ship carries `metadata.internal: true` in its `SKILL.md` frontmatter, which keeps it out of the installer's picker while `--skill=<name>` still installs it and `scripts/link-skills.sh` still links it locally. That covers every skill under `skills/team/in-development/`, anything in `deprecated/`, and any skill whose subject is maintaining this repo itself (`sync-upstream`), which would do nothing in the project it was installed into. The marker is independent of the generated `marketplace.json`, which groups by bucket and still lists the skill. Upstream's `misc/` and `in-progress/` are **not** marked: they are upstream's deliberate published output, so they stay installable and the picker pools them under its own `Other` heading.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder — an upstream bucket or a `team/<domain>/` folder — has a `README.md` that lists every skill in it with a one-line description, with the skill name linked to its `SKILL.md`. The promoted buckets' `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**; non-promoted bucket `README.md`s (`misc/`, `in-progress/`) use a flat list, as does the `## Beta` heading a team domain adds below its groups.

Skills in the promoted buckets — `engineering/`, `productivity/`, and every `team/<domain>/` — also have a human-facing docs page at `docs/<bucket>/<skill-name>.md`, where `<bucket>` is the skill's path under `skills/` (so `skills/team/mobile/kmp-module-setup` → `docs/team/mobile/kmp-module-setup.md`): the docs tree mirrors the promoted folders under `skills/`. The published URL is `https://aihero.dev/skills-<skill-name>` regardless of bucket — the docs path is repo organisation only, and `team/` is fork-local so aihero.dev never hosts it. When you add, rename, or change the behaviour of a skill in a promoted bucket, create or re-sync its docs page following [.agents/writing-docs.md](./.agents/writing-docs.md). A finished page carries four sections — **What it does**, **When to reach for it**, **Common questions**, **It's working if** — and `writing-docs.md` holds the template, the section order, and where to hunt for the questions. Skills in the non-promoted buckets (`misc/`, `in-progress/`, `deprecated/`) and team skills marked `status: beta` get **no** docs page.

Alongside the per-skill pages, `docs/roles/` carries one entry page per audience in [.fork/catalog.yaml](./.fork/catalog.yaml) — engineer, designer, analyst, qa, staff. Each lists every skill whose `audience` names that role, in a curated reading order, linking to the skill's docs page or to its `SKILL.md` where it has none. The catalog is the source of truth and the pages are the view: refine the `audience` list there, never per page, and re-sync the affected role pages in the same change.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](./.agents/invocation.md).

[`ask-matt`](./skills/engineering/ask-matt/SKILL.md) is the router that maps every user-reachable skill and how they relate. The same trigger that re-syncs a docs page applies to it: whenever you add, rename, remove, or change how a user-reachable skill fits the flows, re-read `ask-matt`'s `SKILL.md` and update it so the map stays accurate: a new skill it never mentions, or a stale one it still routes to, is a router that lies.

To (re)link every skill into the local harness skill directories (`~/.claude/skills`, `~/.agents/skills`), run `scripts/link-skills.sh`. Each entry is a symlink into this repo, so a `git pull` keeps installed skills current; re-run the script after adding, removing, or renaming a skill.

No em-dashes anywhere in this repo's prose (`SKILL.md` files, docs, `README.md`, `CHANGELOG.md`, ADRs, changesets, code comments). Where a sentence reaches for one, rewrite it instead with a comma, colon, period, parentheses, or a conjunction, whichever the sentence actually wants; never do a blind character substitution.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:6cd5cc61 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->
