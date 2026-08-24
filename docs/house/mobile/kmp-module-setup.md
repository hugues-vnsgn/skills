## What it does

`kmp-module-setup` scaffolds or audits a shared Kotlin Multiplatform module: which targets to declare, how the source-set hierarchy works, what goes in the version catalog, and how to configure the iOS framework block. It treats the version catalog as a compatibility contract — Kotlin, AGP, and Compose Multiplatform are pinned and bumped together, never independently.

## When to reach for it

The agent reaches for it automatically when creating or modifying a shared module's `build.gradle.kts`, adding targets, or deciding where platform-specific code should live. Reach for it yourself when starting a new shared module, reviewing one, or planning a Kotlin/AGP/CMP version bump. For wiring the built framework into Xcode, use [kmp-ios-integration](../../../skills/house/mobile/kmp-ios-integration/SKILL.md) instead.

## The decision it encodes

The recurring fork is **expect/actual vs interface + DI**: expect/actual only for leaf utilities (UUID, clock, platform name); interfaces with DI for anything with behavior, state, or that tests must fake. expect/actual *classes* stay off the table — still Beta, and officially discouraged.

## Common questions

**Swift is seeing type names like `Kotlinx_coroutines_coreFlow`. Where does that come from?**

A dependency declared with `implementation` instead of `api`. Types from an `implementation` dependency aren't part of your module's public ABI, so the framework header can't name them properly and they surface mangled. Exporting a type across the framework boundary needs `api(...)` in the dependency block *and* `export(...)` in the framework block — both, not either. Avoid reaching for `transitiveExport = true` to make the problem go away; it exports the whole graph and bloats the binary.

**Do I need to wire `dependsOn` between source sets?**

No, for any standard layout. Declaring `androidTarget()`, `iosArm64()`, and `iosSimulatorArm64()` gives you the default hierarchy free on Kotlin 1.9.20 and later — `commonMain → appleMain → iosMain → iosArm64Main` is already connected. Manual `dependsOn` wiring is the most common thing to find in an audit and delete. You only need it for a genuinely non-standard hierarchy.

**Why can't I just bump Kotlin on its own?**

Because Kotlin, AGP, and Compose Multiplatform are one compatibility contract, not three independent versions — a given CMP release maps to a specific Jetpack Compose release and expects a specific Kotlin. Version drift between the three is the single most common setup failure. Bump them together in `libs.versions.toml`, checked against the official compatibility table, rather than moving one at a time.

**I wrote `expect class` for a service and now it's painful to test. What should it have been?**

An interface in `commonMain` with per-platform implementations supplied by DI. `expect class` is still Beta, warns without `-Xexpect-actual-classes`, and gives you no seam to fake in tests — the platform implementation *is* the type. Keep expect/actual for leaf utilities with no state or dependencies; anything a test needs to substitute wants an interface, or an `expect fun createX(): X` factory.

## It's working if

- New modules compile for both `iosSimulatorArm64` and Android on the first try.
- Version bumps go through `libs.versions.toml` with the compatibility table checked, not "latest everything".
- Swift never sees mangled type names like `Kotlinx_coroutines_coreFlow`.
