---
name: compose-multiplatform-ui
description: Use when building shared UI with Compose Multiplatform, creating the app skeleton and per-platform entry points (MainActivity, MainViewController), using composeResources/Res, Navigation Compose or ViewModel in commonMain, embedding SwiftUI/UIKit in Compose (or vice versa), or debugging iOS-specific Compose issues (frame rate caps, accessibility, viewModel() crashes on iOS).
---

# Compose Multiplatform UI

Shared Compose UI across Android and iOS: entry points, resources, navigation, ViewModel, and native-UI interop. Full detail and version tables: [reference.md](reference.md).

## Entry points

- **Common**: root `@Composable fun App()` in `commonMain`, wrapped in `MaterialTheme`.
- **Android**: `MainActivity` calls `setContent { App() }`.
- **iOS**: `fun MainViewController(): UIViewController = ComposeUIViewController { App() }` in `iosMain`; Swift hosts it via `UIViewControllerRepresentable`.
- **Required on iOS**: `CADisableMinimumFrameDurationOnPhone = true` in `Info.plist`, or Compose is capped below ProMotion refresh rates.

CMP builds on Jetpack Compose. On Android it resolves to Google's real `androidx` artifacts; other targets use JetBrains ports. Jetpack knowledge transfers directly. Multiplatform ports of Lifecycle/ViewModel/Navigation live at `org.jetbrains.androidx.*` coordinates.

## Resources

```
src/commonMain/composeResources/
├── drawable/  strings/  fonts/  files/
```

Generated `Res` class: `stringResource(Res.string.app_name)`, `painterResource(Res.drawable.icon)`, `Res.readBytes("files/data.json")` (suspend), `Res.getUri(...)` for handing files to platform APIs. Locale/density/theme qualifiers supported; multi-module resources need Kotlin 2.0+.

## Navigation & ViewModel in common code

```kotlin
implementation("org.jetbrains.androidx.navigation:navigation-compose:<version>")
```

Same API as Jetpack: `rememberNavController()`, `NavHost`, type-safe `@Serializable` routes.

ViewModel gotcha: **on iOS you cannot call `viewModel()` with no arguments** (no type reflection), so always pass an initializer: `viewModel { OrderViewModel() }`. Desktop needs `kotlinx-coroutines-swing` for `Dispatchers.Main.immediate`.

## Native UI interop (both directions)

- SwiftUI **in** Compose: pass a `() -> UIViewController` factory (wrapping `UIHostingController`) from Swift into Kotlin, render with `UIKitViewController(factory = ...)`.
- UIKit views in Compose: `UIKitView(factory = { MKMapView() }, update = { ... })`; `@ObjCAction` for target-action callbacks.
- Compose in UIKit/SwiftUI: `ComposeUIViewController` is a plain `UIViewController`, so push it, tab it, or wrap it in `UIViewControllerRepresentable`.

## Iteration & verification loop

- **Hot reload is desktop/JVM-only**: use the desktop target as the fast sandbox for common UI, then verify Android/iOS.
- Judge iOS scrolling/animation performance on **release** builds on a real device; debug Kotlin/Native is much slower.
- `Modifier.testTag` maps to `accessibilityIdentifier` → XCTest UI automation and `performAccessibilityAudit()` work against Compose.

## Common mistakes

- No-arg `viewModel()` on iOS → runtime failure; use the initializer lambda.
- Missing `CADisableMinimumFrameDurationOnPhone` → mysterious 60fps cap on ProMotion devices.
- Judging performance on debug builds → false alarms.
- Android-only artifacts (`androidx.compose.*`) declared in `commonMain` → use `org.jetbrains.*` equivalents.
- Streaming large files through `Res.readBytes` → not supported; use `Res.getUri()` + platform APIs.
