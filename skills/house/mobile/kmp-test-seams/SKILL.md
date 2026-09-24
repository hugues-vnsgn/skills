---
name: kmp-test-seams
description: Use when a Kotlin Multiplatform repo raises the question of where a test belongs or which Gradle task proves it, whether commonTest or androidHostTest/iosTest, seams that live in commonMain over platform services, and choosing jvmTest, testDebugUnitTest or iosSimulatorArm64Test to run a slice.
---

# KMP Test Seams

This is a quick lookup for **where the test goes** and **which Gradle task proves it**. For the red-green loop in a KMP/CMP app, use `tdd-kmp`.

## Seams and test tasks

For shared rules, prefer seams in `commonMain` behind interfaces over platform services (see `kmp-module-setup`). Test them in `commonTest` with `kotlin.test` and multiplatform fakes. Platform `actual`s belong in `androidHostTest` or `iosTest`; Compose UI and SwiftUI behavior need their own UI tests (see `tdd-kmp`). Pick a task that executes the test on the affected target: `jvmTest` for pure common logic, `testDebugUnitTest` or `iosSimulatorArm64Test` for platform code. Full task map: `kmp-release-and-publish`.
