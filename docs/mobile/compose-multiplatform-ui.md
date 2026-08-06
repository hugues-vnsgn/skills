## What it does

`compose-multiplatform-ui` covers building shared UI with Compose Multiplatform: per-platform entry points, resources, navigation, ViewModel in common code, and embedding native iOS UI in Compose (and vice versa). Its core orientation: CMP *is* Jetpack Compose on Android — the same `androidx` artifacts — so Jetpack knowledge transfers, and only the iOS-specific deltas need learning.

## When to reach for it

The agent reaches for it automatically when writing composables in `commonMain`, setting up `MainViewController`/`ComposeUIViewController`, using `Res` resources or Navigation Compose, or mixing SwiftUI/UIKit with Compose. Reach for it yourself when iOS-specific Compose symptoms appear: a 60fps cap on ProMotion devices, `viewModel()` crashing on iOS, or accessibility/XCTest questions.

## The iOS deltas it teaches

`CADisableMinimumFrameDurationOnPhone` in Info.plist (or ProMotion is capped), initializer-lambda `viewModel { ... }` (no-arg reflection doesn't exist on iOS), desktop as the hot-reload sandbox (hot reload is JVM-only), and judging performance only on release builds.

## It's working if

- Common UI iterates on desktop hot reload, then verifies on both phones.
- No `androidx.compose.*` coordinates appear in `commonMain` — only `org.jetbrains.*` ports.
- VoiceOver and XCTest automation work against Compose screens via `testTag`.
