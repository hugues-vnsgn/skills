---
"osxsystem-skills": minor
---

Group the installer's skill picker by domain, with a select-all per group.

`npx skills@latest add osxsystem/skills` previously listed all 45 skills flat, one keystroke per skill. It now renders six collapsible groups — Engineering, Productivity, Team Delivery, Team Mobile, Team Platform, Team Quality — each with a header row that selects everything under it. Upstream's `misc/` and `in-progress/` skills stay installable under the picker's own "Other" heading.

The installer derives groups from `.claude-plugin/marketplace.json` and nothing else, so this fork now generates that one file from `.fork/catalog.yaml` (`python3 scripts/generate-marketplace.py`, gated by `--check` in CI). It is picker metadata, not an install route: `plugin.json` stays deleted, skills.sh remains the only documented way in, and the `plugin-dir-marketplace-only` guard fails the build if a sync brings the rest of the directory back.

`CLAUDE.md` gains the convention that a skill this fork does not ship carries `metadata.internal: true`, which keeps it out of the picker while `--skill=<name>` still installs it.

Known trade-off: the installer disables type-to-filter search whenever groups are present, and opens them expanded. Both are upstream behaviours in [vercel-labs/skills](https://github.com/vercel-labs/skills); a fix is being sent there separately.
