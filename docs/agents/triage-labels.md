# Triage Labels

The skills speak in terms of five canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker, which is beads (`bd`). See [issue-tracker.md](./issue-tracker.md).

| Canonical role    | Label in our tracker | Meaning                                  |
| ----------------- | -------------------- | ---------------------------------------- |
| `needs-triage`    | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`      | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent` | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human` | `ready-for-human`    | Requires human implementation            |
| `wontfix`         | `wontfix`            | Will not be actioned                     |

The strings are unchanged from the canonical roles, because this repo had no competing vocabulary when the mapping was written and `ready-for-agent` was already in use on `skills-01x`.

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.

## Applying them

```bash
bd create "<title>" --labels ready-for-agent
bd update <id> --labels needs-info
bd list --label ready-for-agent
```

`bd` creates labels on demand, so there is no vocabulary to provision first. Two consequences worth knowing:

- A typo becomes a new label silently rather than erroring, so read the table rather than recalling it.
- `bd list --label <name>` defaults to open issues. Pass `--status closed` when auditing past work, or a label that is genuinely in use will look unused.

Edit the right-hand column to match whatever vocabulary you actually use.
