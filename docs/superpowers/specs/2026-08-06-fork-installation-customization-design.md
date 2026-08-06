# Fork installation customization — design

**Date:** 2026-08-06
**Status:** Approved
**Scope:** This repo (`osxsystem/skills`) only. Nothing outside the repo is touched.

## Goal

Make skills.sh the single install route for this fork, pointed at `osxsystem/skills`, and reframe the README as a fork README that credits the upstream project (`mattpocock/skills`).

## Decisions made

1. **Delete `.claude-plugin/` entirely** (not just remove it from docs), and strip the plugin-registration rules from the internal rule files so no agent instruction points at a deleted file.
2. **Reframe the README as a fork README** (third person, osxsystem perspective) — not a minimal string swap.
3. **Drop the "Why These Skills Exist" essay** from the README; link upstream for the philosophy.
4. **No skill renames.** `setup-matt-pocock-skills` and `ask-matt` keep their names; pruning them is a separate, later task already noted in CUSTOMIZING.md's roadmap.

## Changes by file

### 1. `.claude-plugin/` — deleted

Both `plugin.json` and `marketplace.json` are removed. skills.sh becomes the only install route.

### 2. `.agents/install-block.md` — canonical install text

- Remove the "Claude Code — the plugin" canonical block, the official-marketplace explanation, "The two routes are exclusive", and the "Not the install story" section (the marketplace fallback no longer exists).
- Keep both skills.sh canonical blocks, with `mattpocock/skills` replaced by `osxsystem/skills`:
  - Whole-set: `npx skills@latest add osxsystem/skills`
  - Single-skill: `npx skills@latest add osxsystem/skills --skill=<name>` and `npx skills@latest update <name>`
- The instruction to keep `setup-matt-pocock-skills` among the selected skills stays (the skill keeps its name).

### 3. `README.md` — reframed as fork README

- **Badge / URLs:** every `skills.sh/…/mattpocock/skills` reference becomes `osxsystem/skills`.
- **Intro:** rewritten in third person — this is the osxsystem team fork, customized for Kotlin Multiplatform + Compose Multiplatform (Android + iOS/Swift) mobile development. A prominent note near the top: "This project uses [mattpocock/skills](https://github.com/mattpocock/skills)", crediting the upstream author and linking there for the philosophy behind the skills.
- **Installation:** single route — `npx skills@latest add osxsystem/skills` — followed by the existing "Run `/setup-matt-pocock-skills` once per repo" step. The Claude Code plugin instructions, the two-philosophies framing, and "pick one" language are removed.
- **Removed:** the "Why These Skills Exist" essay (failure modes #1–#4 and Summary) and the newsletter calls-to-action/banner links.
- **Kept unchanged:** the full Reference section (Engineering / Productivity / Mobile tables, User-invoked vs Model-invoked split, all skill links).

### 4. Rule files — `CLAUDE.md`, `MAINTENANCE.md`, `CUSTOMIZING.md`

- **Registration layers:** `.claude-plugin/plugin.json` is dropped everywhere it is listed as a layer a promoted skill must be registered in. Promoted skills now register in three places: bucket `README.md`, top-level `README.md`, and the `docs/<bucket>/<name>.md` page.
- **Validation:** all `claude plugin validate . --strict` steps are removed.
- **MAINTENANCE.md sync checklist:** the post-sync steps referencing manifests and `plugin.json` are replaced; add a note that upstream changes under `.claude-plugin/` are resolved by keeping the directory deleted.
- **CLAUDE.md:** the sentence describing `marketplace.json` as a fallback marketplace goes away; the install-commands sentence still points at `.agents/install-block.md` as the canonical source. The `in-progress/` bucket description changes from "not shipped in the plugin" to "not promoted".
- **ADR `.agents/adr/0002-ship-as-a-claude-code-plugin.md`:** untouched — historical record. References to it may remain where they read as history, but no live instruction should depend on the plugin existing.

### 5. Explicitly not touched

- Anything outside this repo.
- Skill names and skill folders.
- `package.json`, `package-lock.json`, `CHANGELOG.md`, `.changeset/` — upstream release machinery, harmless to leave.
- `docs/` skill pages — they carry no install commands (the site renders them), so no edits needed.
- `research/`, `scripts/link-skills.sh`.

## Success criteria

- `grep -ri "claude-plugin\|plugin install\|claude plugins" README.md CLAUDE.md MAINTENANCE.md CUSTOMIZING.md .agents/install-block.md` returns no live install instructions (historical ADR references excluded).
- `grep -rn "mattpocock/skills" README.md .agents/install-block.md` matches only the upstream credit link(s), not install commands or badges.
- `.claude-plugin/` does not exist.
- README opens as a fork README with the upstream credit note and installs via `npx skills@latest add osxsystem/skills`.
