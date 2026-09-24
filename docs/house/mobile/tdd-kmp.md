## What it does

`tdd-kmp` drives a test-first change in a Kotlin Multiplatform or Compose Multiplatform app, including its native Android and SwiftUI consumers. It places the test at the layer that owns the behavior and requires an observed assertion failure before the fix. A passing shared test cannot prove a UI regression is fixed.

## When to reach for it

Type `/tdd-kmp`, or the agent reaches for it when a KMP/CMP feature or bug fix needs a red-green loop. Use [tdd](https://aihero.dev/skills-tdd) outside KMP/CMP; use [kmp-test-seams](../../../skills/house/mobile/kmp-test-seams/SKILL.md) when you only need to locate a test or choose its runner.

## Red on the affected target

For shared rules, start in `commonTest` and run a target that executes it. Platform code and UI need a test on the affected Android or iOS target. A compile failure, a skipped suite, or a runner that executes zero tests is not red or green. Each slice ends with the same test passing on the same target.

## Common questions

**Can a shared-state test prove a SwiftUI rendering bug is fixed?**

No. Test the visible interaction in XCUITest or the Kotlin-to-Swift observation path in Swift tests, depending on where the failure lives.

**What if I cannot run the affected device or simulator?**

Report the blocker and what the runnable layers proved. Do not report another target's pass as coverage for the missing one.

## It's working if

- The red report shows the failing assertion from an executed test, not a build or runner error.
- The green report names the executed-test count for each affected target.
- A UI fix includes the original on-screen journey and inspected rendered result.

## Where it fits

A test-first route inside [implement](https://aihero.dev/skills-implement) for KMP/CMP work. [kmp-test-seams](../../../skills/house/mobile/kmp-test-seams/SKILL.md) remains the quick source-set and Gradle task reference, while [tdd](https://aihero.dev/skills-tdd) serves other codebases. [ask-matt](https://aihero.dev/skills-ask-matt) maps the full flow.
