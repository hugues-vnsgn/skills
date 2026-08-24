# Issue Tracker

Issues for this repo live in **beads (`bd`)**, a local issue tracker backed by a Dolt database in `.beads/`. Not GitHub Issues, and not markdown checklists.

This is an "other/custom" tracker rather than one of the skills' first-class backends. [`.out-of-scope/mainstream-issue-trackers-only.md`](../../.out-of-scope/mainstream-issue-trackers-only.md) explains why niche trackers are not wired into the skills directly, and routes exactly this case here.

## The commands skills should use

| Intent | Command |
| ------ | ------- |
| Find available work | `bd ready` |
| Read one issue | `bd show <id>` |
| Create an issue | `bd create "<title>" -d "<description>" -p <0-3> --labels <labels>` |
| Create from a long spec | `bd create "<title>" --body-file <path>` |
| Claim work | `bd update <id> --claim` |
| Add findings without overwriting | `bd update <id> --append-notes "<text>"` |
| Finish work | `bd close <id>` |
| Query directly, bypassing routing | `bd sql "select ..."` |

Issue IDs look like `skills-01x`: the `skills-` prefix plus a short suffix. Run `bd prime` at the start of a session for the full command reference.

## Writing an issue from a skill

`to-spec` and `to-tickets` publish here. Two conventions matter:

- **Long specs go in a file, not a flag.** Use `--body-file` and keep the markdown source under `.scratch/<date>-<slug>.md`, so the spec stays readable and diffable in the repo while the issue holds the canonical copy. This is what [`.scratch/2026-08-23-account-migration-spec.md`](../../.scratch/2026-08-23-account-migration-spec.md) and `skills-01x` did.
- **Acceptance criteria are a field, not a heading.** Pass `--acceptance` rather than burying them in the description, so `bd show` surfaces them.

## Handing work to an agent

Apply the `ready-for-agent` label. See [triage-labels.md](./triage-labels.md) for the full vocabulary. bd creates labels on demand, so no setup step is needed before first use.

## Two failure modes worth knowing

**Writes can land in a store you are not reading.** `bd` supports routing writes to a different database than the one `bd list` reads. When that is misconfigured, `bd create` succeeds, `bd list` shows the issue, and `bd close` cannot find it, while `bd doctor` reports no errors. This repo hit it for eight days in August 2026. If a close silently fails, cross-check with `bd sql`, which ignores routing and talks to the repo store directly:

```bash
bd sql "select id, status from issues where id = '<id>'"
```

**Sync is not a git commit.** Issue data lives in a Dolt database and syncs over `refs/dolt/data` on the git remote; `.beads/issues.jsonl` is a passive export, not the source of truth. Committing that file does not publish an issue. See the [sync concepts doc](https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md).

## GitHub Issues

Deliberately unused. `.fork/divergence.md` records that GitHub Issues is not the tracker for this repo. Do not open, read, or triage GitHub Issues here, and do not fall back to `gh issue create` when `bd` is unavailable; report the failure instead.

Pull requests are a different matter: they are the review surface and are used normally. They are not a request surface, so an incoming PR does not enter the triage queue as an issue.
