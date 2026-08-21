---
"osxsystem-skills": patch
---

Add `sync-upstream`, a maintainer skill that drives an upstream merge. It defers to `.fork/sync-playbook.md` for the steps and carries what the playbook cannot: how to read the delta, how to classify a conflict before resolving it, how to handle a repo-wide style sweep, and the failures that look like breakage and are not. Beta, and marked internal so the installer does not offer a skill that only works in this repo.
