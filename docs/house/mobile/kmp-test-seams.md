## What it does

`kmp-test-seams` answers two placement questions: where a Kotlin Multiplatform test belongs and which Gradle task runs it. It is a quick lookup, not the test-first loop. [tdd-kmp](./tdd-kmp.md) drives the loop across shared Kotlin and mobile targets.

## When to reach for it

Type `/kmp-test-seams`, or the agent reaches for it automatically when a KMP repo raises a placement or task question mid-loop.

| Your question | Where to go |
|---|---|
| What should I test, and how do I prove the fix? | [tdd-kmp](./tdd-kmp.md) for KMP/CMP work |
| Does this test live in `commonTest` or a platform source set? | here |
| Which Gradle task do I run to call this slice green? | here, then the task map in [kmp-release-and-publish](../../../skills/house/mobile/kmp-release-and-publish/SKILL.md) |
| Should this platform service be `expect`/`actual` or an interface? | [kmp-module-setup](../../../skills/house/mobile/kmp-module-setup/SKILL.md), which owns that fork |

## Seams are a placement decision, not just a design one

KMP adds a second axis to the seam: which target owns the behavior. Shared rules can live behind an interface in `commonMain` and run in `commonTest` with `kotlin.test` and multiplatform fakes. Platform `actual`s need Android or iOS tests; a UI regression needs an affected-target UI test, not another shared-state assertion.

That is why the cheapest task that covers the seam is the right one to run: `jvmTest` for pure common logic, and a simulator or device task, `iosSimulatorArm64Test` or `testDebugUnitTest`, only before claiming a platform-touching slice green.

## Common questions

**The `/tdd` skill used to have a Kotlin Multiplatform section. Where did it go?**

The source-set and Gradle-task guidance moved here when the fork removed its append from upstream's `/tdd`. For the full KMP/CMP red-green loop, use [tdd-kmp](./tdd-kmp.md).

**Does this replace `/tdd-kmp` on a KMP project?**

No. Use [tdd-kmp](./tdd-kmp.md) for the full red-green loop; use this skill when you only need the source set or runner.

**A slice passes `jvmTest` but I touched an `actual`. Am I done?**

No. `jvmTest` never compiled the `actual` you changed. A platform-touching slice is green only once the platform's own task runs it.

## It's working if

- Shared rules run from `commonTest`, platform `actual`s from a platform source set, and UI behavior from a UI test on the affected target.
- The loop you run most often is a fast one; simulator and device tasks show up at slice boundaries, not on every red-green cycle.
- Nobody is asking "which Gradle task do I run" in review.

## Where it fits

A reach-for-it-anytime reference, not a step in the flow: [tdd-kmp](./tdd-kmp.md) owns the KMP/CMP loop. [kmp-module-setup](../../../skills/house/mobile/kmp-module-setup/SKILL.md) shapes the shared module, and [kmp-release-and-publish](../../../skills/house/mobile/kmp-release-and-publish/SKILL.md) owns the full Gradle task map. For the whole map, see [ask-matt](https://aihero.dev/skills-ask-matt).
