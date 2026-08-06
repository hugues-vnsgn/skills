## What it does

`kmp-module-setup` scaffolds or audits a shared Kotlin Multiplatform module: which targets to declare, how the source-set hierarchy works, what goes in the version catalog, and how to configure the iOS framework block. It treats the version catalog as a compatibility contract — Kotlin, AGP, and Compose Multiplatform are pinned and bumped together, never independently.

## When to reach for it

The agent reaches for it automatically when creating or modifying a shared module's `build.gradle.kts`, adding targets, or deciding where platform-specific code should live. Reach for it yourself when starting a new shared module, reviewing one, or planning a Kotlin/AGP/CMP version bump. For wiring the built framework into Xcode, use [kmp-ios-integration](../../skills/mobile/kmp-ios-integration/SKILL.md) instead.

## The decision it encodes

The recurring fork is **expect/actual vs interface + DI**: expect/actual only for leaf utilities (UUID, clock, platform name); interfaces with DI for anything with behavior, state, or that tests must fake. expect/actual *classes* stay off the table — still Beta, and officially discouraged.

## It's working if

- New modules compile for both `iosSimulatorArm64` and Android on the first try.
- Version bumps go through `libs.versions.toml` with the compatibility table checked, not "latest everything".
- Swift never sees mangled type names like `Kotlinx_coroutines_coreFlow`.
