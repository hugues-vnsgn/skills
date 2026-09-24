---
name: kmp-ios-integration
description: Use when connecting a Kotlin Multiplatform shared module to an iOS/Xcode app, choosing between direct integration, CocoaPods, SPM, or KMMBridge; setting up embedAndSignAppleFrameworkForXcode or the cocoapods plugin; debugging "pod not found", script-sandboxing, or framework-not-found Xcode errors; or reviewing Kotlin API that Swift will consume (sealed classes, suspend functions, @Throws, generics).
---

# KMP iOS Integration

Wire the shared Kotlin framework into the iOS app. Inspect Kotlin/Xcode versions, the existing integration route and generated framework/module name first. Read [interop-reference.md](interop-reference.md) when choosing integration or reviewing Swift API behavior; read [cocoapods-reference.md](cocoapods-reference.md) only for Pod-based builds.

## Choosing an integration method

| Pick | When |
|---|---|
| **Direct integration** (`embedAndSignAppleFrameworkForXcode`) | Mono-repo, no CocoaPods deps; the **default**, and what the KMP wizard generates |
| **CocoaPods plugin** | The KMP module needs Pod dependencies, or the iOS app is already Pod-based |
| **SPM local / remote XCFramework** | SwiftPM-first iOS team; remote when shared code ships as a versioned binary |
| **KMMBridge** | Separate iOS team that must never run Gradle |

Direct integration and CocoaPods framework integration are **mutually exclusive for the same shared module**. Migrating off CocoaPods: `pod deintegrate` + remove the `cocoapods {}` block first.

## Direct integration checklist

1. `binaries.framework {}` declared on the iOS targets.
2. Xcode Run Script phase (before Compile Sources, dependency-analysis unticked):
   ```bash
   if [ "YES" = "$OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED" ]; then exit 0; fi
   cd "$SRCROOT/.."
   ./gradlew :shared:embedAndSignAppleFrameworkForXcode
   ```
3. **Disable "User Script Sandboxing"** in Build Settings; run `./gradlew --stop` if the daemon started sandboxed. (Silent failure otherwise, and the #1 support question.)
4. Custom Xcode configurations need a user-defined `KOTLIN_FRAMEWORK_BUILD_TYPE`.

## CocoaPods quick path

`kotlin("native.cocoapods")` plugin (version = Kotlin version) → `cocoapods { version; summary; homepage; ios.deploymentTarget; framework { baseName } }` → `./gradlew podInstall` for the configured Podfile (inspect project-specific Bundler/multi-project commands before substituting it) → open the **`.xcworkspace`** → disable script sandboxing. Pod deps from Kotlin via `pod("Name") { version = ... }`; `@import`-style headers need `extraOpts += listOf("-compiler-option", "-fmodules")`. Error→fix table in [cocoapods-reference.md](cocoapods-reference.md).

## Swift-facing API review checklist

When editing exported `commonMain` API, check each item, because these fail silently at the boundary:

- **Declare expected errors with `@Throws`** at the Objective-C export boundary. Prefer the specific exception types callers can handle; unexpected exceptions crossing that boundary terminate the process. Suspend cancellation has special behavior, so test the selected bridge.
- **Sealed classes** lose exhaustiveness in Swift (`default:` required). Fix with SKIE, or keep them behind a facade.
- **`suspend`/`Flow`**: default interop gives no cancellation and opaque Flow objects. Preserve the existing **SKIE**, KMP-NativeCoroutines or explicit bridge, and verify cancellation; avoid overlapping transformations of the same API.
- **Default arguments disappear** (ObjC); add overloads or SKIE.
- **Generics**: unconstrained `<T>` becomes nullable-everything; constrain `<T : Any>`.
- **Enums** are classes in Swift, not Swift enums (no exhaustive switch), which SKIE fixes.
- Keep the surface small: `@HiddenFromObjC` internals, `@ObjCName` for Swift-idiomatic names, thin facade in `commonMain`. With Compose Multiplatform the surface is often just `fun MainViewController(): UIViewController`.
- **Swift export** is a separate Alpha path with different mappings and build integration. Evaluate it explicitly against the installed Kotlin release; do not silently replace a working Objective-C bridge.

## Common mistakes

- Leaving User Script Sandboxing on → framework silently never builds.
- Mixing CocoaPods and direct integration in one module.
- Opening `.xcodeproj` after `pod install` instead of `.xcworkspace`.
- Exporting the whole module API instead of a facade → slow header generation, ugly Swift.
- Un-annotated throwing API crossing into Swift → production crashes.

## Verify the consumer

Build the actual Xcode scheme/configuration after integration changes. For exported API changes, compile a Swift caller and exercise expected errors, cancellation and stream termination where relevant. Report the integration route, generated module name and observed build/test results; a Kotlin compile alone does not verify Swift consumption.

Checked 2026-09-24: [direct integration](https://kotlinlang.org/docs/multiplatform/multiplatform-direct-integration.html), [Objective-C interop](https://kotlinlang.org/docs/native-objc-interop.html), [Swift export](https://kotlinlang.org/docs/native-swift-export.html). `kmp-module-setup`, when installed, owns framework production; this skill owns its Xcode consumer.
