---
"osxsystem-skills": patch
---

Add `/implement-delegate` (beta, in development): given one Issue ID, it writes conversation-only decisions onto the spec, creates an `agent/` feature worktree and an Issue worktree off it, dispatches `implementer` or `implementer-kmp` in the background with a pointer-only brief, relays a BLOCKED question to the user and resumes the same implementer, reviews with `/code-review`, merges `--no-ff`, closes the Issue after the merge, and reports the push and PR commands without running them.
