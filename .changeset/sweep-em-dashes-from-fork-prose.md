---
"osxsystem-skills": patch
---

Remove every em dash from fork-owned prose, closing the rule `CLAUDE.md` has stated since upstream's 2026-08-20 sync without anything enforcing it. 682 occurrences across 57 files, rewritten rather than substituted: a colon where a list or definition follows, a semicolon between independent clauses, a comma for an appositive, a period where the clause was really a second sentence, and a conjunction where the dash was hiding the logical connective.

Three things changed beyond punctuation. The `⚠ TBD` marker `to-prd` writes into a PRD is now `⚠ TBD: <who decides>` in both the skill and its docs page, so the two still agree. `CUSTOMIZING.md` no longer claims the promoted house domains are mobile and platform, which stopped being true when delivery, discovery, quality and writing landed. Empty Sync note cells in `.fork/divergence.md` read `None` instead of a bare dash.

Seven skill descriptions were rewritten. Four are unquoted YAML scalars where a colon-space would have made the front matter invalid and dropped the skill from skills.sh discovery silently, which is the same failure a changeset already fixed once before; each was parsed to confirm.

Upstream territory is untouched: the three en dashes in `docs/engineering/diagnosing-bugs.md` are upstream's own bytes and stay as they are.
