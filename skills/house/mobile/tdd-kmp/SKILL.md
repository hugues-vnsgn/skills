---
name: tdd-kmp
description: Test-driven development in Kotlin Multiplatform and Compose Multiplatform mobile apps, including native Android and SwiftUI consumers. Use for test-first features, a regression test before a bug fix, or red-green-refactor in a KMP repo; skip it when the request only verifies existing behavior.
---

# Mobile TDD

## Choose the behavior and layer

Name the observable behavior and the public boundary that shows it; ask only when the intended behavior or scope is unclear.
For a bug, that behavior is the symptom the user saw: reproduce it on the affected platform first, on the device the user named.

Place the test at the lowest layer that owns the failure.
No number of tests at a lower layer can see the bug: a shared-state test misses a stale SwiftUI render, and a green shared-rule test does not prove the screen still calls that rule.

| Behavior | Test location |
| --- | --- |
| Shared rules, mapping, repositories, ViewModel state | `commonTest` with `kotlin.test` |
| Platform services, Kotlin `actual`s | Platform test source set; a device or simulator for real platform APIs |
| Shared Compose UI | Common Compose UI tests, run on the affected target |
| Android-only logic / Compose UI | Host unit tests / instrumented Compose tests |
| Swift logic, Kotlin-to-Swift observation | XCTest or Swift Testing |
| SwiftUI interaction | XCUITest |

Open the nearest existing test at that layer and copy its idioms, fakes, and runner command; add a library only when no existing test can express the behavior.
`commonTest` has no runtime of its own and a test directory alone does not enable a suite, so confirm which target tasks actually run it with `./gradlew :<module>:tasks --all`.

When the change reverses current behavior, find what pins it first: the existing tests, and the commit that introduced it (`git log -S`, then read its full message).
When that commit or test records the behavior as deliberate, stop and ask the user before changing it, quoting the recorded reason.

This step is done when you can name the behavior, the test file, the exemplar test, and one command that executes tests in that source set.

Read [tests.md](tests.md) when writing assertions, coroutine/Flow tests, shared Compose tests, or native UI tests.
Read [mocking.md](mocking.md) when the behavior crosses HTTP, storage, time, platform services, or UI lifecycle effects.

## Red, green, refactor

Work in vertical slices: one behavior on one platform goes from red to green before the next begins.

1. **Red:** Write one test for one behavior, entering through the same function, event, or control that production callers use.
   Its expected value is a literal from the requirement, never a call to production code or a reuse of its constants.
   When the change reverses existing behavior, flip the old assertion instead of adding a new one.
   Run it against the unfixed code.
   It is red only when the report shows the test executed and its assertion failed with a message that names the missing behavior.
   A compile error, a failed lookup or enabled-state check, a device hang, or a runner failure is a setup failure.
   A test that passes on its first run points at the fixture, discovery, or boundary: fix that before touching production code.
2. **Green:** Implement only enough production behavior to pass, then rerun the same test on the same target with the same scenario.
3. **Refactor:** While green, simplify what this slice introduced, then rerun the affected tests.
4. Repeat until every behavior in the request, with its failure and boundary cases, has its own red-to-green pair.
   For a bug, that is one regression test for the symptom plus one case for each branch the fix adds.

### Prove a red you did not watch

When a test arrived after its production code, or its red was lost, break exactly the step the test's name claims (revert that change, or run the archived pre-fix build), watch the test fail, then restore.
If it stays green, the test does not prove that step: rename it to what it does prove, or record that the behavior holds by construction.
A different, easier mutation proves only itself.
Any edit to the test, fixture, or double after the red makes that red stale: collect it again.

### Setup budget

Once one layer is red, proving the same behavior at another layer is optional unless the user asked for it.
Judge setup by the failures you actually hit, so try the layer before weighing its cost.
A setup failure you can fix inside the repository in one step (a test dependency, a JVM flag, a test manifest, a runner argument) is routine: fix it and continue.
Stop and report what is proven, what blocks, and which layer could prove the rest when the next fix needs something outside the repository or costly to undo (a device, an emulator or system image, machine settings, a new Xcode target), when the same setup failure survives two fixes, or after four distinct setup failures on one layer; continue on the user's word.
When you stop, leave the suite passing: take the blocked test out and describe it in the report.
Give each device run a timeout, since a hang before the first assertion is a setup failure.

## Prove completion

Run the affected suites on every target the change reaches.
When shared Kotlin changes, rebuild the framework the iOS app consumes, for the architecture under test, before Swift tests; a stale framework is a setup failure.
For UI changes, replay the original journey on each affected platform and inspect the rendered result.

Read the evidence from the report, not the exit code: the executed-test count per target (JUnit XML, `Executed N tests`), since wrappers and instrumentation runners can exit 0 on a failed run.
Each of these is a **false green**, a pass that proves nothing:

- `NO-SOURCE`, zero executed tests, or skipped tests
- a compile-only or CI build success
- a suite that ran on one target standing in for another: a shared test that ran only on iOS says nothing about Android
- a shared-state or Kotlin/Native test standing in for a UI pass
- a lint or release gate reported for files it never checks

Report the behavior tested, the red assertion message, the green command with its executed-test count per target, the tested revision, and platform/device coverage.
List unrun targets and blockers separately.
