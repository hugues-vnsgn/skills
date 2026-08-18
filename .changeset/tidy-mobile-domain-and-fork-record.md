---
"osxsystem-skills": minor
---

Tidy the mobile domain and make the fork record self-checking.

**Skills**

- Retired `kotlin-multiplatform`. It was transplanted from another codebase and never adapted, and its central guidance had gone stale: it routed to `expect`/`actual` by default, which JetBrains now advise against for classes. Its one sound section — the custom intermediate source set for sharing across a target subset — moved into `kmp-boundaries`.
- `kmp-boundaries` gains that section, plus the `expect`/`actual`-classes-are-Beta caveat and the functions-vs-classes distinction. Fixed `skikoMain` (not a real source set) and a pointer to a `references/ios-interop.md` that never existed.
- `kmp-ktor` no longer points at skills outside this repo, and defines the error type it tells you to map to.
- Six skills registered as `status: beta`: `kmp-boundaries`, `kmp-ktor`, `herdr`, `bro`, `improve-claude-md`, `show-me`.

**Harness**

- New `forkcheck` assertion `declared-trees-exist`: a row in `divergence.md`'s Additions table can no longer outlive the tree it describes. Paths marked `(planned)` are exempt so a tree can still be forward-declared.
