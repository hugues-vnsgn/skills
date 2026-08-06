---
"osxsystem-skills": patch
---

Rename `setup-matt-pocock-skills` to `setup-osxsystem-skills`.

The skill's behaviour is unchanged — only its name, directory, and docs page
move. Run `/setup-osxsystem-skills` instead of the old command.

**If you installed a previous version,** the old skill is still linked under its
old name and will surface a broken slash command. Remove it:

```bash
rm -f ~/.claude/skills/setup-matt-pocock-skills \
      ~/.agents/skills/setup-matt-pocock-skills
```

Also in this release: `package.json` now identifies this fork rather than
upstream, and `scripts/sync-plugin-version.mjs` is deleted. That script synced a
`.claude-plugin/plugin.json` this fork does not ship, and its failure was
breaking the release workflow.
