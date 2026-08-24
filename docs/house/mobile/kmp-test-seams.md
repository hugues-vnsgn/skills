## What it does

`kmp-test-seams` answers the two questions Kotlin Multiplatform adds to a test-first loop: where the **seam** goes, and which Gradle task proves the slice green. It is not a TDD skill. It never runs the loop, states no rules about it, and defers everything about what makes a test worth keeping to [tdd](https://aihero.dev/skills-tdd). It only supplies the platform half that a single-platform TDD reference has no way to know.

## When to reach for it

Type `/kmp-test-seams`, or the agent reaches for it automatically when a KMP repo raises a placement or task question mid-loop.

| Your question | Where to go |
|---|---|
| What should I test, and what makes this test worth keeping? | [tdd](https://aihero.dev/skills-tdd), which owns the loop |
| Does this test live in `commonTest` or a platform source set? | here |
| Which Gradle task do I run to call this slice green? | here, then the task map in [kmp-release-and-publish](../../../skills/house/mobile/kmp-release-and-publish/SKILL.md) |
| Should this platform service be `expect`/`actual` or an interface? | [kmp-module-setup](../../../skills/house/mobile/kmp-module-setup/SKILL.md), which owns that fork |

## Seams are a placement decision, not just a design one

In a single-platform repo, choosing a seam is about depth: how much behaviour sits behind how small an interface. KMP adds a second axis, *which source set the seam lives in*, and the two interact. A seam in `commonMain`, behind an interface over the platform service, gives you a red-green loop that runs in `commonTest` with `kotlin.test` and multiplatform fakes: fast, and it covers both platforms at once. A seam that reaches into a platform `actual` forces the test into `androidHostTest` or `iosTest`, where the loop is slower and only proves one platform.

That is why the cheapest task that covers the seam is the right one to run: `jvmTest` for pure common logic, and a simulator or device task, `iosSimulatorArm64Test` or `testDebugUnitTest`, only before claiming a platform-touching slice green.

## Common questions

**The `/tdd` skill used to have a Kotlin Multiplatform section. Where did it go?**

Here, unchanged. It was an append onto an upstream file, which meant a merge conflict on every upstream sync of `tdd`. Extracting it into a fork-owned skill retired that conflict: upstream's `tdd` is byte-identical to upstream again, and this skill cross-references it by name.

**Does this replace `/tdd` on a KMP project?**

No. Run `/tdd`, which is still the loop and the reference for what a good test is. This one layers underneath it, the same way `kmp-module-setup` layers underneath ordinary module design.

**A slice passes `jvmTest` but I touched an `actual`. Am I done?**

No. `jvmTest` never compiled the `actual` you changed. A platform-touching slice is green only once the platform's own task runs it.

## It's working if

- Tests default to `commonTest`, and a test in `androidHostTest` or `iosTest` is there because it exercises an `actual`, not by habit.
- The loop you run most often is a fast one; simulator and device tasks show up at slice boundaries, not on every red-green cycle.
- Nobody is asking "which Gradle task do I run" in review.

## Where it fits

A reach-for-it-anytime reference that runs *beneath* the flow rather than as a step in it: the platform layer under [tdd](https://aihero.dev/skills-tdd), which stays the step. Its neighbours are [kmp-module-setup](../../../skills/house/mobile/kmp-module-setup/SKILL.md), because a seam you can fake in `commonTest` is a module-shape decision made earlier, and [kmp-release-and-publish](../../../skills/house/mobile/kmp-release-and-publish/SKILL.md), because it owns the full Gradle task map this skill picks from. For the whole map, see [ask-matt](https://aihero.dev/skills-ask-matt).
