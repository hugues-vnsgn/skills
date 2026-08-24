## What it does

`compose-multiplatform-ui` covers building shared UI with Compose Multiplatform: per-platform entry points, resources, navigation, ViewModel in common code, and embedding native iOS UI in Compose (and vice versa). Its core orientation: CMP *is* Jetpack Compose on Android, resolving to the same `androidx` artifacts, so Jetpack knowledge transfers and only the iOS-specific deltas need learning.

## When to reach for it

The agent reaches for it automatically when writing composables in `commonMain`, setting up `MainViewController`/`ComposeUIViewController`, using `Res` resources or Navigation Compose, or mixing SwiftUI/UIKit with Compose. Reach for it yourself when iOS-specific Compose symptoms appear: a 60fps cap on ProMotion devices, `viewModel()` crashing on iOS, or accessibility/XCTest questions.

## The iOS deltas it teaches

`CADisableMinimumFrameDurationOnPhone` in Info.plist (or ProMotion is capped), initializer-lambda `viewModel { ... }` (no-arg reflection doesn't exist on iOS), desktop as the hot-reload sandbox (hot reload is JVM-only), and judging performance only on release builds.

## Common questions

**`viewModel()` crashes on iOS but works fine on Android. Why?**

No-argument `viewModel()` relies on type reflection to construct the ViewModel, and that reflection doesn't exist on iOS. Pass an initializer lambda instead, `viewModel { OrderViewModel() }`, and it works on every target, Android included, so there's no reason to branch by platform here.

**Compose feels capped at 60fps on an iPhone that supports ProMotion. What did I miss?**

`CADisableMinimumFrameDurationOnPhone = true` in `Info.plist`. Without it, iOS caps Compose below ProMotion's refresh rate, and the symptom looks like a performance problem rather than a missing plist key, since there's no crash or warning pointing at it.

**Should I trust the animation smoothness I'm seeing in the debug build?**

No. Debug Kotlin/Native is meaningfully slower than release, so scrolling and animation performance only mean something on a release build on a real device. A debug-build judgment call is the fastest way to chase a performance problem that doesn't exist in what ships.

**Can I use `androidx.compose.*` artifacts in `commonMain`?**

No, those coordinates are Android-only. CMP resolves to the real `androidx` artifacts on Android specifically, but shared code needs the `org.jetbrains.androidx.*` multiplatform ports of the same APIs (Lifecycle, ViewModel, Navigation). Jetpack knowledge transfers directly; only the Maven coordinate changes.

## It's working if

- Common UI iterates on desktop hot reload, then verifies on both phones.
- No `androidx.compose.*` coordinates appear in `commonMain`, only `org.jetbrains.*` ports.
- VoiceOver and XCTest automation work against Compose screens via `testTag`.
