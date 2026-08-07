---
"osxsystem-skills": patch
---

`ask-matt` now routes to the mobile bucket.

The router mapped every promoted skill except the four Kotlin Multiplatform /
Compose Multiplatform ones, which have shipped in `skills/mobile/` since the
fork added the bucket. They now appear as a **Platform knowledge** layer that
runs beneath the main flow, alongside the existing vocabulary layer.

No skill behaviour changes — this is the map catching up with the repo.
