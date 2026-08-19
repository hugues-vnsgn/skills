---
"osxsystem-skills": minor
---

Add `to-prd` and open the `discovery` team domain.

**Skills**

- New skill `to-prd` (`skills/team/discovery/`) — turn the current conversation into a Product Requirements Document. Synthesis first: it drafts every section it can defend from what was already discussed, asks one batched round of questions only for the decisions no agent can make (Key Result targets, contacts, the release cut), and marks deferred decisions `⚠ TBD` instead of inventing them. Unripe ideas are refused and routed to `grill-with-docs`. Adapted from the ecosystem's `create-prd` (phuryn/pm-skills) into this repo's synthesis idiom. Smoke-tested in isolation on both paths: rich post-grilling context (full PRD, zero invented numbers) and a two-line idea (refusal with routing).
- `discovery` is the first skill's landing that opens the reserved domain folder — bucket README, top-level README section, docs page, and analyst/staff role-page entries all added.

**Flow**

- `ask-matt`'s main flow gains a step: `grill-with-docs → to-prd (initiative-scale only) → to-spec → to-tickets → implement`. A single well-scoped feature skips the PRD step.
