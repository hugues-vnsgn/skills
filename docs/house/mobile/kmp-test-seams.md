## What it does

`kmp-test-seams` chooses where a KMP test belongs and which configured task can prove the change. It discovers the project's targets before suggesting commands, so a mobile-only app is not sent to a nonexistent `jvmTest` task. It is a lookup, not the test-first loop: [tdd-kmp](./tdd-kmp.md) drives the loop across shared Kotlin and mobile targets.

## When to reach for it

Type `/kmp-test-seams`, or the agent reaches for it automatically when test placement or execution is unclear.

| Question | Skill |
|---|---|
| Common, Android host/device, or iOS test? | This skill |
| Which existing module-qualified task verifies this change? | This skill |
| How should the platform capability API be designed? | [kmp-boundaries](../../../skills/house/mobile/kmp-boundaries/SKILL.md) |
| How should a test-first loop proceed? | [tdd-kmp](./tdd-kmp.md) for KMP/CMP work, otherwise [tdd](https://aihero.dev/skills-tdd) |

## A seam needs platform evidence

A fake in `commonTest` checks the caller's contract. It does not exercise the real Android or iOS implementation. Host tests can cover some Android code; UI/device behavior needs the appropriate platform runner. Common code is verified on the targets whose tasks actually ran.

## Common questions

**We only target Android and iOS. Do we need to add JVM for fast tests?**

No. Use the configured Android host or iOS simulator task that covers the behavior. Add a target only when the project needs it.

**Why are Android host-test tasks missing?**

The Android-KMP plugin disables test components by default. Inspect its version, enable the required component with that version's DSL, then discover the generated task.

**Does this replace `/tdd-kmp` on a KMP project?**

No. Use [tdd-kmp](./tdd-kmp.md) for the full red-green loop; use this skill when you only need the source set or the task.

**The task succeeded with `NO-SOURCE`. Is the change verified?**

No tests executed. Check source-set placement and reports before claiming the behavior passed.

## It's working if

- Commands name a real module and task in the project.
- Platform changes have evidence from that platform.
- The report distinguishes executed tests from skipped or absent tests.

## Where it fits

A standalone platform reference beneath [tdd-kmp](./tdd-kmp.md), which owns the KMP/CMP loop; it can support [tdd](https://aihero.dev/skills-tdd) or other testing workflows too. [kmp-module-setup](kmp-module-setup.md) supplies build configuration; [kmp-release-and-publish](kmp-release-and-publish.md) assembles verified tasks into release CI. See [ask-matt](https://aihero.dev/skills-ask-matt) for the full map.
