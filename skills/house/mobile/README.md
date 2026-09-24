# Mobile

House skills for Kotlin Multiplatform + Compose Multiplatform development and native SwiftUI/UIKit (Android and iOS). The KMP skills' technical guidance was checked against official sources on 2026-09-24. Larger skills keep conditional detail in bundled references; shorter skills are self-contained.

`swiftui-expert-skill` is adapted from [avdlee/swiftui-agent-skill](https://github.com/avdlee/swiftui-agent-skill) at commit `b24e68a965dc4b5bd2cc41dc60c094a26a9379ce` ([MIT license](./swiftui-expert-skill/LICENSE)). `uikit-expert` is adapted from [ivan-magda/uikit-expert-skill](https://github.com/ivan-magda/uikit-expert-skill) at commit `45c70f0f31e63c62bcb11da6c7bb3b4759dac393` ([MIT license](./uikit-expert/LICENSE)).

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[kmp-module-setup](./kmp-module-setup/SKILL.md)**: Configure shared-module plugins, targets, source sets, compatible versions and Apple frameworks for the installed toolchain.
- **[kmp-ios-integration](./kmp-ios-integration/SKILL.md)**: Connect shared code to Xcode and verify Swift-facing APIs, errors and coroutine behavior.
- **[compose-multiplatform-ui](./compose-multiplatform-ui/SKILL.md)**: Build shared screens and verify native iOS interop, navigation ownership, resources, touch and accessibility.
- **[swiftui-expert-skill](./swiftui-expert-skill/SKILL.md)**: Native SwiftUI implementation and review: state and `@Observable` data flow, view composition, adaptive layout, accessibility, API migration, and Instruments trace capture/analysis.
- **[uikit-expert](./uikit-expert/SKILL.md)**: Native UIKit implementation and review: view-controller lifecycle, Auto Layout, collection views, navigation, memory, concurrency, accessibility, and SwiftUI interop.
- **[kmp-release-and-publish](./kmp-release-and-publish/SKILL.md)**: Prepare and verify release artifacts, signing, CI and library publication with explicit upload/release scope.
- **[kmp-test-seams](./kmp-test-seams/SKILL.md)**: Choose common or platform test placement and discover the existing task that verifies the change.
- **[tdd-kmp](./tdd-kmp/SKILL.md)**: Red-green-refactor for KMP/CMP apps, from shared rules to Android and SwiftUI, with per-platform test evidence.

## Beta

Not promoted: no docs page, and excluded from the top-level `README.md` until they graduate. Try them and say what breaks, because they can change or disappear without warning.

- **[kmp-boundaries](./kmp-boundaries/SKILL.md)**: Design common capability interfaces, expect/actual choices, platform binding lifetimes and completion contracts.
- **[kmp-ktor](./kmp-ktor/SKILL.md)**: Configure platform engines, trusted-origin bearer auth, bounded retries, serialization and MockEngine verification.
