# The canonical install block

One install story, one wording. `README.md`, `.changeset/*`, and every page under `docs/` must say **this** and nothing else. Change it here first, then propagate.

The single install route is [skills.sh](https://skills.sh/hugues-vnsgn/skills), which copies editable skill files into the project — files you own and can edit. Nothing updates behind your back; pull the latest changes with `npx skills update`.

## Whole set — on `README.md`

<canonical-block name="skills-sh-whole-set">

```bash
npx skills@latest add hugues-vnsgn/skills
```

Skills are grouped by domain — **Engineering**, **Productivity**, and one group per house domain (**Mobile**, **Platform**, and so on) — and each group header takes a single keystroke to select everything under it. Pick the groups or the individual skills you want, then choose which coding agents to install them on. **Expand **Platform** and make sure `setup-osxsystem-skills` is ticked.**

Claude Code, Codex, Cursor, Pi and 70-odd other agents are offered by name. **[omp (oh-my-pi)](https://omp.sh) is not yet listed by name — choose the `agents` target**, which writes to `~/.agents/skills`, the location omp reads natively.

</canonical-block>

## Single skill — wherever one skill is named on its own

Note that **`docs/` pages are not a consumer of this block**: ai-hero renders the install widget above the body, so a page that writes the commands out duplicates it. See [writing-docs.md](./writing-docs.md).

<canonical-block name="skills-sh-one-skill">

```bash
npx skills@latest add hugues-vnsgn/skills --skill=<name>
```

```bash
npx skills@latest update <name>
```

</canonical-block>

`skills@latest` is the pinned spelling in both. The pages under `docs/` used to carry their own copy of these commands; those blocks are now deleted rather than corrected, because the site renders the install commands itself.

## No plugin route

Upstream ships a Claude Code plugin from `.claude-plugin/`; this fork deleted that directory, and skills.sh is the only install route. Upstream syncs that re-add `.claude-plugin/` are resolved by deleting it again — see [MAINTENANCE.md](../MAINTENANCE.md). The history of the plugin decision lives in [adr/0002-ship-as-a-claude-code-plugin.md](./adr/0002-ship-as-a-claude-code-plugin.md).
