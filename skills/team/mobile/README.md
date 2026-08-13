# Mobile

Team skills for Kotlin Multiplatform + Compose Multiplatform development targeting Android and iOS (Swift). Built from the official kotlinlang.org docs (researched 2026-08); each skill bundles its research as reference files.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[kmp-module-setup](./kmp-module-setup/SKILL.md)** — Scaffold or audit a shared KMP module: targets, source-set hierarchy, version catalog (Kotlin/AGP/CMP pinned together), framework block, expect/actual vs interfaces + DI.
- **[kmp-ios-integration](./kmp-ios-integration/SKILL.md)** — Connect the shared framework to Xcode: direct integration vs CocoaPods vs SPM vs KMMBridge decision table, setup checklists, and a Swift-facing API review checklist (@Throws, sealed classes, coroutines, SKIE).
- **[compose-multiplatform-ui](./compose-multiplatform-ui/SKILL.md)** — Shared Compose UI: per-platform entry points, composeResources/Res, Navigation and ViewModel in common code, SwiftUI/UIKit interop both directions, iOS performance and accessibility.
- **[kmp-release-and-publish](./kmp-release-and-publish/SKILL.md)** — Ship it: Android release with R8 over shared code, iOS archive/TestFlight (privacy manifest, dSYMs), Maven Central via the Central Portal, CI runner split with konan caching, test task map.
- **[kmp-test-seams](./kmp-test-seams/SKILL.md)** — The platform layer under the red-green loop: seams in `commonMain`, `commonTest` vs `androidHostTest`/`iosTest`, and the cheapest Gradle task that proves a slice green. The loop itself stays with the `tdd` skill.
