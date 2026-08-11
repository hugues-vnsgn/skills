---
"osxsystem-skills": patch
---

Two new skills, from a second pass over ClaudeKit's catalogue.

`port-from-repo` (engineering, user-invoked) brings a capability across from
another codebase without bringing its architecture with it — understand,
challenge, adapt, verify. It delegates four of those phases to skills this repo
already owns, so it stays small: `/grilling` for the challenge, `/codebase-design`
for the seam, `/tdd` for the build, `/code-review` for close-out.

`when-stuck` (in-progress, model-invoked) collects five techniques for
design-level stuck-ness — inversion, the scale game, simplification cascades,
meta-patterns, collision — scoped away from bugs and undecided plans so it
doesn't compete with `/diagnosing-bugs` or `/grilling`.

`ask-matt` gains an on-ramp for `port-from-repo`, and its opening line stops
claiming a fixed number of on-ramps now that there are four.
