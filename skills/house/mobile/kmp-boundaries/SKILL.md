---
name: kmp-boundaries
description: Use when designing the API between common Kotlin code and Android or iOS capabilities, choosing interfaces versus expect/actual, or fixing platform binding lifecycle and cancellation contracts. Gradle source-set and plugin configuration belongs to kmp-module-setup.
---

# KMP Boundary Design

Inspect the caller, required platforms and existing dependency lifetime before choosing an abstraction. Describe a product capability in common code and keep platform mechanics in the implementation.

## Choose the boundary

| Need | Shape |
|---|---|
| Stateless leaf utility with one implementation per target | An `expect` function/property with platform `actual` implementations |
| State, dependencies, test fakes, lifecycle or runtime selection | A common interface and per-platform bindings |
| An existing platform type that must satisfy a common declaration | Consider expect/actual classes or typealiases after checking export and testing constraints |
| Two targets share implementation code | Put it in a suitable intermediate source set; use module setup guidance for the Gradle wiring |

Split capabilities such as `ShareSheet`, `Clipboard` and `Biometrics` rather than growing one `Platform` object. Keep business decisions in common code; platform implementations translate platform results and failures into the agreed contract.

Expect/actual classes remain Beta in the official guidance checked 2026-09-24. Interfaces allow multiple implementations and simpler substitution; this is a preference for the capability case, not a ban on compiler-supported declarations. [Expected and actual declarations](https://kotlinlang.org/docs/multiplatform/multiplatform-expect-actual.html)

## Define lifetime and completion

For platform UI operations, establish all of these at the call boundary:

- Which foreground Activity or iOS presenter owns the operation, and what happens when none is available.
- Whether completion means the launch was requested, the UI was presented, or the user finished.
- Which dispatcher may call the platform API, how cancellation propagates, and how callbacks are released.

An Android binding that needs UI belongs to an Activity scope. Keep the Activity out of app-scoped objects; use a lifecycle-aware provider if a longer-lived caller needs access. Do not assume a value obtained from `LocalContext.current` is an Activity. On iOS, use the active presenting controller and release delegates/callbacks with their owner.

```kotlin
// commonMain: request accepted, not proof of presentation or user completion
interface ShareSheet {
    suspend fun requestShare(text: String)
}
```

An Android implementation can switch to `Dispatchers.Main.immediate`, check its current Activity and call `startActivity(Intent.createChooser(...))`. Returning from `startActivity` proves only that launch was requested. If callers need the user's result, design a separate result/callback contract supported by that platform. See [Android Activity lifecycle](https://developer.android.com/guide/components/activities/activity-lifecycle).

## Shared state and native UX

Share business state, validation and route data when their semantics agree. Choose ownership of visual navigation, permissions presentation and platform chrome from the product's UI architecture. A Compose-owned back stack and a SwiftUI-owned back stack are both valid; each navigation event needs one owner to avoid duplicate pushes. Do not generalize a native-shell choice into a rule against shared navigation.

Test the common contract with a fake and verify the real binding on the affected platform, including owner destruction and cancellation. Report the chosen interface, lifetime and observable completion semantics. A fake passing does not prove the native implementation works.

Related skills, when installed: `kmp-ios-integration` for Swift export and coroutine bridging, `compose-multiplatform-ui` for native UI interop, `kmp-ktor` for HTTP behavior, and `kmp-test-seams` for the test source set and task. These are optional specializations, not prerequisites.
