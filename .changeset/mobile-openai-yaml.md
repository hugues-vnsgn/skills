---
"osxsystem-skills": patch
---

The four `skills/mobile/` skills now carry the `agents/openai.yaml` that
`.agents/invocation.md` requires of every skill. They stay model-invoked, so
the files hold Codex UI metadata only and no `policy` block.
