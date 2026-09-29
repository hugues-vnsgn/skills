---
"osxsystem-skills": patch
---

`/implement-delegate` now takes a spec or epic ID, or no argument for the spec just written in the conversation, and walks its child Issues along their blocking edges: at most two implementers in flight, Issues whose descriptions suggest shared files kept apart, the frontier recomputed after each close, the feature branch's gates run after each merge, and a broken gate fixed by one implementer on the feature branch before anything else lands. Once every Issue is merged it reviews the whole branch, sends the findings to one fresh implementer as a single fix-up Issue, reviews that fix, and reports without pushing. A rerun resumes a partly built spec.
