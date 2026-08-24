## What it does

`compose-multiplatform-ui` covers building shared UI with Compose Multiplatform: the iOS shell decision, per-platform entry points, resources, navigation and ViewModel in common code, and embedding native iOS UI in Compose (and vice versa). Its core orientation: CMP *is* Jetpack Compose on Android, resolving to the same `androidx` artifacts, so Jetpack knowledge transfers and only the iOS-specific deltas need learning. It is written against Compose Multiplatform 1.11.x, and it routes build wiring to `kmp-module-setup` and `kmp-ios-integration` rather than repeating it.

## When to reach for it

Type `/compose-multiplatform-ui`, or the agent reaches for it automatically when a task fits: writing composables in `commonMain`, setting up `MainViewController`/`ComposeUIViewController`, using `Res` resources or either navigation library, or mixing SwiftUI/UIKit with Compose. Reach for it yourself when iOS-specific Compose symptoms appear: a startup crash naming `CADisableMinimumFrameDurationOnPhone`, `viewModel()` crashing on iOS, an embedded native view that feels laggy or swallows gestures, VoiceOver skipping an interop view, or the question of whether Liquid Glass is reachable at all. For the Xcode and framework seam instead, use [kmp-ios-integration](https://aihero.dev/skills-kmp-ios-integration).

## The decision it makes you take first

Whether iOS runs a **full-Compose shell** (one `ComposeUIViewController` owning tabs and back stack, the default) or a **native SwiftUI shell** (SwiftUI owns `TabView` and `NavigationStack`, Compose renders one screen per destination). That is the only route to iOS 26 Liquid Glass, because the system draws those effects through native containers, and reversing the choice later is a rewrite rather than a refactor. The skill puts it before the screen-writing sections for that reason, and carries the worked migration plus the `if #available(iOS 26.0, *)` fallback.

## The iOS deltas it teaches

`CADisableMinimumFrameDurationOnPhone` in Info.plist (or the app crashes at startup), the exact `composeResources` directory names (`values/`, `font/`, not `strings/`, `fonts/`), initializer-lambda `viewModel { ... }` (no-arg reflection doesn't exist on iOS), the `ComposeUIViewController(configure = { ... })` knobs where most iOS behaviour actually lives, `UIKitInteropProperties` for touch and accessibility on embedded native views, desktop as the hot-reload sandbox (hot reload is JVM-only), and judging performance only on release builds.

## Common questions

**`viewModel()` crashes on iOS but works fine on Android. Why?**

No-argument `viewModel()` relies on type reflection to construct the ViewModel, and that reflection doesn't exist on iOS. Pass an initializer lambda instead, `viewModel { OrderViewModel() }`, and it works on every target, Android included, so there's no reason to branch by platform here.

**The iOS app crashes at startup and the message mentions `CADisableMinimumFrameDurationOnPhone`. Is that a Compose bug?**

No, it's Compose telling you the key is missing. Set `CADisableMinimumFrameDurationOnPhone = true` in `Info.plist`. Since 1.7.0 the check is strict and a missing or `false` value crashes deliberately, on the reasoning that a loud failure beats the old symptom: Compose silently capped below ProMotion's refresh rate, which reads as a performance problem rather than a missing plist key. If you're seeing that silent cap instead of a crash, someone turned off `enforceStrictPlistSanityCheck`.

**The `MKMapView` I embedded feels laggy, and scrolling fights it. Is interop just slow?**

No, that's the cooperative touch model. Since 1.7.0 Compose holds a touch for about 150ms so the parent composable gets first refusal on the gesture, which is right for a small native control inside a scrollable and wrong for a full-screen map. `UIKitInteropProperties(interactionMode = UIKitInteropInteractionMode.NonCooperative)` restores immediate pass-through.

**VoiceOver skips right over my embedded native view. Did I forget semantics?**

Probably not. `isNativeAccessibilityEnabled` is off by default, so Compose doesn't hand accessibility resolution to the interop subtree. A native view with its own accessibility support has to opt in, and the fix is a property rather than a semantics modifier.

**Can I use `androidx.compose.*` artifacts in `commonMain`? And what about `implementation(compose.material3)`?**

`androidx.compose.*` coordinates are Android-only; shared code needs the `org.jetbrains.androidx.*` multiplatform ports of the same APIs. The `compose.*` aliases the Gradle plugin provides are a separate trap: they've been deprecated since 1.10.0-beta01, so write the direct Maven coordinate in the version catalog instead. A CMP BOM is planned but hasn't shipped, so versions stay pinned by hand.

**Should I trust the animation smoothness I'm seeing in the debug build?**

No. Debug Kotlin/Native is meaningfully slower than release, so scrolling and animation performance only mean something on a release build on a real device. A debug-build judgment call is the fastest way to chase a performance problem that doesn't exist in what ships.

## It's working if

- The iOS shell shape is a decision on record before screens get written, not something the code drifted into.
- Common UI iterates on desktop hot reload, then verifies on both phones.
- No `androidx.compose.*` coordinates and no `compose.*` plugin aliases appear in the build files.
- VoiceOver and XCTest automation work against Compose screens via `testTag`, and against interop views that opted in.
- Navigation 3 destinations, where used, carry entry decorators so ViewModels die with the destination.

## Where it fits

A reach-for-it-anytime reference that runs *beneath* the flow rather than as a step in it: the agent pulls it in whenever the work is shared-UI-shaped, and you reach for it directly when the platform, not the process, is what you're stuck on. Its neighbours are [kmp-ios-integration](../../../skills/house/mobile/kmp-ios-integration/SKILL.md), because the framework and Xcode seam this skill deliberately refuses to duplicate lives there, [kmp-module-setup](../../../skills/house/mobile/kmp-module-setup/SKILL.md), because the targets and version catalog that decide which Compose APIs resolve at all are settled earlier, and [kmp-boundaries](../../../skills/house/mobile/kmp-boundaries/SKILL.md), because a composable that needs a platform capability is asking a boundary question, not a UI one. For the whole map, see [ask-matt](https://aihero.dev/skills-ask-matt).
