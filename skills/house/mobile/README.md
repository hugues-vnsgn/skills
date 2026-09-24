# Mobile

House skills for Kotlin Multiplatform + Compose Multiplatform development and native SwiftUI/UIKit (Android and iOS). The KMP skills were built from official kotlinlang.org docs (researched 2026-08); each bundles its research as reference files.

`swiftui-expert-skill` is adapted from [avdlee/swiftui-agent-skill](https://github.com/avdlee/swiftui-agent-skill) at commit `b24e68a965dc4b5bd2cc41dc60c094a26a9379ce` ([MIT license](./swiftui-expert-skill/LICENSE)). `uikit-expert` is adapted from [ivan-magda/uikit-expert-skill](https://github.com/ivan-magda/uikit-expert-skill) at commit `45c70f0f31e63c62bcb11da6c7bb3b4759dac393` ([MIT license](./uikit-expert/LICENSE)).

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[kmp-module-setup](./kmp-module-setup/SKILL.md)**: Scaffold or audit a shared KMP module: targets, source-set hierarchy, version catalog (Kotlin/AGP/CMP pinned together), framework block, expect/actual vs interfaces + DI.
- **[kmp-ios-integration](./kmp-ios-integration/SKILL.md)**: Connect the shared framework to Xcode: direct integration vs CocoaPods vs SPM vs KMMBridge decision table, setup checklists, and a Swift-facing API review checklist (@Throws, sealed classes, coroutines, SKIE).
- **[compose-multiplatform-ui](./compose-multiplatform-ui/SKILL.md)**: Shared Compose UI: the full-Compose vs native SwiftUI shell decision, per-platform entry points, composeResources/Res, Navigation and ViewModel in common code, SwiftUI/UIKit interop both directions, iOS performance and accessibility.
- **[swiftui-expert-skill](./swiftui-expert-skill/SKILL.md)**: Native SwiftUI implementation and review: state and `@Observable` data flow, view composition, adaptive layout, accessibility, API migration, and Instruments trace capture/analysis.
- **[uikit-expert](./uikit-expert/SKILL.md)**: Native UIKit implementation and review: view-controller lifecycle, Auto Layout, collection views, navigation, memory, concurrency, accessibility, and SwiftUI interop.
- **[kmp-release-and-publish](./kmp-release-and-publish/SKILL.md)**: Ship it: Android release with R8 over shared code, iOS archive/TestFlight (privacy manifest, dSYMs), Maven Central via the Central Portal, CI runner split with konan caching, test task map.
- **[kmp-test-seams](./kmp-test-seams/SKILL.md)**: Quick lookup for `commonTest` vs platform source sets and the Gradle task that proves a slice green.
- **[tdd-kmp](./tdd-kmp/SKILL.md)**: Red-green-refactor for KMP/CMP apps, from shared rules to Android and SwiftUI, with per-platform test evidence.

## Beta

Not promoted: no docs page, and excluded from the top-level `README.md` until they graduate. Try them and say what breaks, because they can change or disappear without warning.

- **[kmp-boundaries](./kmp-boundaries/SKILL.md)**: Choosing the boundary shape when common code reaches a platform API: a common interface with per-platform bindings vs `expect`/`actual` vs separate implementations, keeping actuals thin, the Activity-owned platform-UI binding, custom intermediate source sets, and the AGP-9 constraints on shared code.
- **[kmp-ktor](./kmp-ktor/SKILL.md)**: Ktor client in KMP: `HttpClient` configuration, per-platform engine selection, kotlinx.serialization, bearer auth with refresh, `MockEngine` testing, and error mapping at the repository boundary.
