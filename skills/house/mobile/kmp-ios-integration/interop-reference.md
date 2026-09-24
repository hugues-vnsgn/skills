# iOS integration and Swift interop

Checked 2026-09-24 against the official sources below. These sections describe Objective-C framework export unless Swift export is explicitly selected. Inspect the project's Kotlin version and integration method before applying them.

## Integration methods

From the [iOS integration overview](https://kotlinlang.org/docs/multiplatform/multiplatform-ios-integration-overview.html):

| Method | Local/Remote | How | Pick when |
|---|---|---|---|
| **Direct integration** (`embedAndSignAppleFrameworkForXcode`) | Local | Run-script build phase invokes Gradle; Kotlin build becomes part of the Xcode build | Mono-repo, no CocoaPods needed. **Default**, and what the KMP IDE plugin and wizard set up |
| **CocoaPods (local)** | Local | Kotlin CocoaPods Gradle plugin + Podfile | You need CocoaPods *dependencies inside the KMP module*, or the iOS app is already Pod-based |
| **SPM (local package)** | Local | Wrap the framework in a local Swift package | Mono-repo where the iOS team is SwiftPM-first and there are no CocoaPods deps |
| **SPM + XCFramework (remote)** | Remote | Publish an XCFramework as a remote Swift package | Separate repos / shared code distributed as a versioned third-party dependency; SwiftPM-preferring iOS team |
| **CocoaPods + XCFramework (remote)** | Remote | `podPublish*XCFramework` tasks produce XCFramework + podspec | Same as above but the consuming ecosystem is CocoaPods |
| **KMMBridge** (Touchlab, third-party, not in the official overview) | Remote | Gradle tooling that automates building, versioning, and publishing XCFrameworks as SPM/CocoaPods packages (GitHub releases, S3, etc.) | Larger orgs where the iOS team should consume shared code as a normal binary dependency without running Gradle at all |

### Direct integration details (the default choice)

Requirements: `binaries.framework {}` declared on the iOS targets; if migrating from CocoaPods, run `pod deintegrate` and remove the `cocoapods {}` block first.

Xcode setup: add a **Run Script phase**, move it **before Compile Sources**, untick "Based on dependency analysis", and **disable User Script Sandboxing** in Build Settings (restart the Gradle daemon with `./gradlew --stop` if it was built sandboxed):

```bash
if [ "YES" = "$OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED" ]; then
  echo "Skipping Gradle build task invocation (IDE already built the framework)"
  exit 0
fi
cd "$SRCROOT/.."
./gradlew :shared:embedAndSignAppleFrameworkForXcode
```

The `OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED=YES` guard prevents double-building when the IDE launches the iOS run configuration. For custom (non Debug/Release) Xcode configurations, add a user-defined `KOTLIN_FRAMEWORK_BUILD_TYPE` setting.

### Decision guidance

- **Team of Android+iOS devs in one repo, Compose Multiplatform UI:** direct integration. Simplest, no dependency-manager overhead, and with CMP the Swift-facing surface is tiny (a `MainViewController()` entry point).
- **iOS app already on CocoaPods, or KMP module needs a Pod:** CocoaPods integration.
- **Independent iOS team that shouldn't touch Gradle:** remote XCFramework via SPM (hand-rolled `multiplatform-spm-export` setup, or KMMBridge to automate publishing).
- CocoaPods is in maintenance mode ecosystem-wide; for new remote setups prefer SPM.

---

## Swift API through Objective-C

Kotlin exports to iOS through an **Objective-C framework header** (Swift export is a separate, Alpha path). Consequences:

### What maps well

| Kotlin | Swift (via ObjC) |
|---|---|
| `class` | `class` |
| `interface` | `protocol` |
| `String`, `List`, `Map` | `String`, `Array`, `Dictionary` (bridged via `NSString`/`NSArray`/`NSDictionary`) |
| `enum class` | a class with static members (NOT a Swift enum) |
| `suspend fun` | `async` function *and* completion-handler variant |
| Top-level functions in `Foo.kt` | static members on `FooKt` |
| `@Throws(...)` functions | Swift `throws` |

### Common pitfalls

- **Sealed classes lose exhaustiveness.** They export as a plain class hierarchy; Swift `switch` needs a `default` case and gives no compile-time completeness check. Use an existing SKIE bridge or an explicit facade when exhaustive handling is required. Evaluate Swift export separately against the project version.
- **Coroutines:** `suspend` maps to completion handlers / basic `async` with **no proper cancellation**, and caller-thread restrictions depend on the Kotlin version and bridge configuration. `Flow` exports as an opaque generic object. If the caller needs cancellation/streaming, use the project's SKIE or KMP-NativeCoroutines bridge, or implement an explicit bridge. Avoid overlapping transformations of the same API; preserve a working setup.
- **Default arguments disappear.** ObjC has no default args; Swift callers must pass every parameter. Mitigate with overloads or SKIE (which regenerates default-argument overloads).
- **Generics are crippled:** type parameters surface as nullable unless constrained `<T : Any>`; interfaces lose generics entirely; variance is dropped.
- **Enums aren't Swift enums**: no `switch` exhaustiveness, no `CaseIterable` (SKIE fixes this too).
- **Primitives box:** `Int?` becomes `KotlinInt?`; `List<Int>` becomes `[KotlinInt]`.
- **Collection bridging overhead** on hot paths, so cast to `NSDictionary`/`NSArray` when profiling shows it matters.
- **Exceptions:** un-`@Throws`-annotated Kotlin exceptions **crash** the app when they cross into Swift. Declare the exceptions Swift callers are expected to handle with `@Throws`; prefer specific types. Suspend functions have special cancellation export behavior, so test the selected bridge.
- **Subclassing:** only `final`-friendly patterns; overriding ObjC initializers needs `@OverrideInit`; clashing overrides need `@ObjCSignatureOverride`. Inline/value classes don't export properly.

### Naming and surface control

```kotlin
@ObjCName(swiftName = "OrderStore")           // rename for Swift
class OrderStoreImpl { 
    @ObjCName("index") fun indexOf(@ObjCName("of") element: String): Int = TODO()
}

@HiddenFromObjC          // keep internal-ish API out of the framework header
fun kotlinOnlyHelper() {}

@ShouldRefineInSwift     // exported as __-prefixed; write a hand-rolled Swift wrapper
fun rawApi(): Any = TODO()
```

KDoc is exported into the header (Xcode autocomplete shows it); disable with `exportKdoc.set(false)` if needed.

**SKIE** (Touchlab, [skie.touchlab.co](https://skie.touchlab.co/)) is an optional interop layer: sealed-class enums, real async/await with cancellation, `Flow` → `AsyncSequence`, default arguments, exhaustive enums. Caveats: don't mix its coroutine interop with KMP-NativeCoroutines, and completion-handler call sites stop compiling once SKIE's async interop is on.

**Design advice:** keep the exported surface deliberately small and ObjC-friendly, a thin facade in `commonMain` (view models / repositories returning simple types), with `@HiddenFromObjC` on the rest. With Compose Multiplatform the surface often shrinks to one `fun MainViewController(): UIViewController`.

---


## Swift export and verification

[Swift export](https://kotlinlang.org/docs/native-swift-export.html) remains Alpha as checked 2026-09-24. It uses its own build integration, supports direct integration, and has different type/coroutine mappings from Objective-C export. Preserve the selected production bridge; evaluate adoption only when the task requests it or needs its capabilities. Recheck the exact Kotlin release instead of relying on a cached feature timeline.

For an API change, compile a small Swift caller that imports the actual generated module. Exercise the success and declared error paths, cancellation of a suspending call, and termination of a Flow consumer where used. An overload existing in Kotlin does not establish its spelling or lifetime behavior in Swift.

Framework production, explicit dependency exports and XCFramework assembly belong to module setup. For standalone use, inspect `binaries.framework`, its `baseName`, linkage and generated tasks before configuring the Xcode consumer.

## Sources

- [Direct integration](https://kotlinlang.org/docs/multiplatform/multiplatform-direct-integration.html)
- [Integration methods](https://kotlinlang.org/docs/multiplatform/multiplatform-ios-integration-overview.html)
- [Swift/Objective-C interop](https://kotlinlang.org/docs/native-objc-interop.html)
- [Swift export](https://kotlinlang.org/docs/native-swift-export.html)
