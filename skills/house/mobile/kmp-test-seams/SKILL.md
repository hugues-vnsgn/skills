---
name: kmp-test-seams
description: Use when choosing a Kotlin Multiplatform test source set or the existing Gradle task that verifies a change, including common tests, Android host versus device tests, and iOS simulator tests. Use kmp-boundaries for designing the platform capability API itself.
---

# KMP Test Seams

Place the test where its dependencies are available, then run the cheapest configured task that exercises the changed behavior. Inspect the module plugins, declared targets and test source sets first. This supplies platform knowledge to any testing workflow; for the red-green loop in a KMP/CMP app, use `tdd-kmp`, or `tdd` where `tdd-kmp` is not installed.

## Place the test

| Behavior/dependency | Source set |
|---|---|
| Shared logic or a repository using multiplatform fakes/MockEngine | `commonTest` with `kotlin.test` and multiplatform test dependencies |
| Android implementation that can run on a local JVM | Android host tests: `androidHostTest` for the Android-KMP plugin; inspect the legacy module's unit-test source set |
| Android framework/device behavior that needs instrumentation | Android device tests, not host tests; `androidDeviceTest` for the Android-KMP plugin |
| Apple APIs or iOS binding lifecycle | `iosTest` or the matching target test source set |

A platform interface helps common tests substitute a fake, but an `actual` implementation is not the only reason to write a platform test. Host tests do not establish device UI behavior. A common test runs on the targets whose tasks you actually execute, not automatically on every platform because of its directory.

## Discover and select tasks

Run `./gradlew :<module>:tasks --all` and inspect the build before selecting a command. Substitute the real module path; examples below are candidates, not guaranteed task names.

| Configured target/plugin | Candidate and condition |
|---|---|
| Separate JVM target | `:<module>:jvmTest`, only if that target exists and exercises the changed code |
| Legacy Android plugin | `:<module>:testDebugUnitTest` or the existing variant's unit-test task |
| Android-KMP library plugin | Enable host tests first if needed, then use the task shown by Gradle (commonly `:<module>:testAndroidHostTest`) |
| iOS ARM simulator | `:<module>:iosSimulatorArm64Test` on macOS with compatible Xcode and simulator runtime |
| Android instrumentation | Discover the connected/device-managed test task; requires a suitable device or emulator; hardware-dependent behavior may need a physical device |

For a mobile-only module, use its Android host or iOS simulator task for common logic. Do not add a JVM target merely to obtain `jvmTest`. After changing an iOS implementation, run the iOS task even when the JVM/common test passed.

The Android-KMP plugin disables host/device tests by default. Current configuration uses `kotlin { android { withHostTest {} } }` and `withDeviceTest {}`; older plugin versions use `withHostTestBuilder`/`withDeviceTestBuilder`. For that plugin, AGP 8.10/8.11 uses the `androidLibrary` target block; 8.12+ uses `android`. Match the installed API and inspect whether the device test's source-set tree includes `commonTest` rather than assuming it does.

Use `allTests` only after checking its task graph and host requirements; it is not proof that instrumented or unsupported-host tests ran. Check test reports for the expected tests, and distinguish PASS from UP-TO-DATE, NO-SOURCE or SKIPPED when reporting what executed.

## Completion evidence

Report the test location, exact module-qualified command, executed test result, and platforms not verified. Build/SDK/simulator failures are infrastructure failures until evidence identifies a product regression. Keep the result scoped to the behavior and platform exercised.

Checked 2026-09-24: [KMP testing](https://kotlinlang.org/docs/multiplatform/multiplatform-run-tests.html), [Android-KMP test configuration](https://developer.android.com/kotlin/multiplatform/plugin#configure-tests).
