---
name: kmp-module-setup
description: Use when creating or changing a Kotlin Multiplatform module's Gradle plugins, targets, source-set hierarchy, version catalog, or Apple framework configuration, including Android-KMP plugin migration. For platform-capability API design, use kmp-boundaries.
---

# KMP Module Setup

Configure the shared module for the project's actual targets and toolchain. Inspect `settings.gradle.kts`, the wrapper, version catalog, module plugins and existing CI before proposing changes. Preserve working versions unless the task needs an upgrade; Kotlin, AGP and CMP have compatibility ranges, not a rule that every version must change together.

## Choose the Android plugin path

| Existing configuration | Apply |
|---|---|
| `com.android.library` with KMP | Legacy `androidTarget()` and top-level `android {}`. Keep a targeted fix on this path unless migration is requested or required for compatibility. |
| `com.android.kotlin.multiplatform.library` | Configure the Android library inside `kotlin {}`. Use the DSL for the installed AGP version, as described in [reference.md](reference.md#android-library-configuration). |
| Android app combined with shared code | A migration to the Android-KMP library plugin needs a separate app module for `MainActivity`, signing, variants and application metadata. |

The Android-KMP plugin has one variant. Supply environment configuration through a common interface or generated multiplatform constants; keep flavors and signing in the consuming app. Enable Android resources and test components only when needed.

## Source sets and dependencies

Let the default hierarchy create `iosMain`/`iosTest` for the declared iOS targets. Standard layouts need no manual `dependsOn`. Platform code can see common declarations; common code cannot import `java.*` or Apple `platform.*` APIs.

For a JVM-only dependency shared by Android and Desktop, read [custom source sets](reference.md#custom-source-sets). Confirm the second target exists before adding a shared layer. A mobile-only project does not need a Desktop target just to follow a sample.

## Framework configuration

For framework names, static/dynamic linkage, explicit dependency exports or XCFramework assembly, read [Apple binaries](reference.md#apple-binaries). Confirm what the iOS app actually imports before exporting dependencies. A public dependency needs `api(...)` and an explicit framework `export(...)` when its declarations must be exported; a mangled name alone is not proof of the cause.

## Verify the configuration

Discover tasks with `./gradlew :<module>:tasks --all`, then run the relevant Android compilation and Apple simulator compilation/link tasks on a capable host. Report the selected plugin/version branch, changed configuration and exact task results. If an SDK or host is unavailable, distinguish configuration inspection from successful compilation.

Related skills, when installed: `kmp-boundaries` owns capability interfaces and expect/actual choices; `kmp-ios-integration` owns Xcode consumption; `kmp-test-seams` owns test placement and task selection. None is required to apply the configuration guidance here.
