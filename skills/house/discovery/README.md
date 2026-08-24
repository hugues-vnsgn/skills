# Discovery

House skills for the phase before the spec — turning an idea into documents a CEO, BA, and engineer can all read and mean the same thing by. Fork-authored: upstream owns none of these bytes.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[to-prd](./to-prd/SKILL.md)**: turn the current conversation into a Product Requirements Document: synthesis first, one batched round of questions for the decisions only the user can make, saved in the repo and linked from the tracker.
