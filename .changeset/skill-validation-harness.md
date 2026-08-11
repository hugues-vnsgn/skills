---
"osxsystem-skills": patch
---

Skill validation now runs in CI.

The structural validator that checks this repo's own invariants — bucket-README
membership and grouping, docs-page sections, invocation-mode consistency across
`SKILL.md` and `agents/openai.yaml`, link resolution, `ask-matt` routing
freshness, the verbatim install block — has moved into `scripts/harness/` and
runs on every pull request. A new `scripts/check-confusable-skills.py` fails
when two model-invoked skill descriptions overlap enough to compete for the
same trigger.

No skill behaviour changes. The rules were already written down in `CLAUDE.md`;
now something checks them.
