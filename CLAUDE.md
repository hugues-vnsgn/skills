This is the **osxsystem team fork** of mattpocock/skills, customized for mobile development with Kotlin Multiplatform + Compose Multiplatform (Android + iOS/Swift). Fork-specific conventions live in [MAINTENANCE.md](./MAINTENANCE.md); the `skills/team/` tree and its docs are fork additions that upstream syncs must preserve.

`skills/` is split by **provenance**. Upstream's buckets sit directly under it and are vendor territory — never moved, renamed, or edited outside the sanctioned list in [.fork/sanctioned-edits.txt](./.fork/sanctioned-edits.txt):

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used, not promoted
- `in-progress/` — beta: public on purpose, feedback wanted, not promoted
- `deprecated/` — no longer used

Every fork-authored skill lives under `skills/team/`, grouped by capability **domain**. Upstream never writes there, so it is conflict-free:

- `team/mobile/` — Kotlin Multiplatform / Compose Multiplatform team skills

A domain folder is created when its first skill lands — no empty growth slots. Each team domain is **promoted** and carries the same registration as an upstream promoted bucket: a bucket `README.md`, an entry in the top-level `README.md`, and a docs page.

Every skill in `engineering/`, `productivity/`, or any `team/<domain>/` (the **promoted** buckets) must have a reference in the top-level `README.md`. Skills in `misc/`, `in-progress/`, and `deprecated/` must not appear there.

Install commands are copied verbatim from [.agents/install-block.md](./.agents/install-block.md). This fork ships via [skills.sh](https://skills.sh/osxsystem/skills) only — upstream's Claude Code plugin route (`.claude-plugin/`) was removed, and upstream syncs that re-add it are resolved by deleting it again (see [MAINTENANCE.md](./MAINTENANCE.md)). The history of the plugin decision lives in [.agents/adr/0002-ship-as-a-claude-code-plugin.md](./.agents/adr/0002-ship-as-a-claude-code-plugin.md).

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder — an upstream bucket or a `team/<domain>/` folder — has a `README.md` that lists every skill in it with a one-line description, with the skill name linked to its `SKILL.md`. The promoted buckets' `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**; non-promoted bucket `README.md`s (`misc/`, `in-progress/`) use a flat list.

Skills in the promoted buckets — `engineering/`, `productivity/`, and every `team/<domain>/` — also have a human-facing docs page at `docs/<bucket>/<skill-name>.md`, where `<bucket>` is the skill's path under `skills/` (so `skills/team/mobile/kmp-module-setup` → `docs/team/mobile/kmp-module-setup.md`): the docs tree mirrors the promoted folders under `skills/`. The published URL is `https://aihero.dev/skills-<skill-name>` regardless of bucket — the docs path is repo organisation only, and `team/` is fork-local so aihero.dev never hosts it. When you add, rename, or change the behaviour of a skill in a promoted bucket, create or re-sync its docs page following [.agents/writing-docs.md](./.agents/writing-docs.md). A finished page carries four sections — **What it does**, **When to reach for it**, **Common questions**, **It's working if** — and `writing-docs.md` holds the template, the section order, and where to hunt for the questions. Skills in the non-promoted buckets (`misc/`, `in-progress/`, `deprecated/`) get **no** docs page.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](./.agents/invocation.md).

[`ask-matt`](./skills/engineering/ask-matt/SKILL.md) is the router that maps every user-reachable skill and how they relate. The same trigger that re-syncs a docs page applies to it: whenever you add, rename, remove, or change how a user-reachable skill fits the flows, re-read `ask-matt`'s `SKILL.md` and update it so the map stays accurate — a new skill it never mentions, or a stale one it still routes to, is a router that lies.

To (re)link every skill into the local harness skill directories (`~/.claude/skills`, `~/.agents/skills`), run `scripts/link-skills.sh`. Each entry is a symlink into this repo, so a `git pull` keeps installed skills current; re-run the script after adding, removing, or renaming a skill.
