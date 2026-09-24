# Mobile

House skills for Kotlin Multiplatform + Compose Multiplatform development targeting Android and iOS (Swift). Technical guidance checked against official sources on 2026-09-24. Larger skills keep conditional detail in bundled references; shorter skills are self-contained.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[kmp-module-setup](./kmp-module-setup/SKILL.md)**: Configure shared-module plugins, targets, source sets, compatible versions and Apple frameworks for the installed toolchain.
- **[kmp-ios-integration](./kmp-ios-integration/SKILL.md)**: Connect shared code to Xcode and verify Swift-facing APIs, errors and coroutine behavior.
- **[compose-multiplatform-ui](./compose-multiplatform-ui/SKILL.md)**: Build shared screens and verify native iOS interop, navigation ownership, resources, touch and accessibility.
- **[kmp-release-and-publish](./kmp-release-and-publish/SKILL.md)**: Prepare and verify release artifacts, signing, CI and library publication with explicit upload/release scope.
- **[kmp-test-seams](./kmp-test-seams/SKILL.md)**: Choose common or platform test placement and discover the existing task that verifies the change.

## Beta

Not promoted: no docs page, and excluded from the top-level `README.md` until they graduate. Try them and say what breaks, because they can change or disappear without warning.

- **[kmp-boundaries](./kmp-boundaries/SKILL.md)**: Design common capability interfaces, expect/actual choices, platform binding lifetimes and completion contracts.
- **[kmp-ktor](./kmp-ktor/SKILL.md)**: Configure platform engines, trusted-origin bearer auth, bounded retries, serialization and MockEngine verification.
