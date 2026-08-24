---
"osxsystem-skills": minor
---

Rewrite `compose-multiplatform-ui` against current Compose Multiplatform (1.11.x), pulled from the official JetBrains multiplatform-dev docs.

The skill was a correct fact sheet that had gone quiet on the things that now bite hardest on iOS. Four gaps closed:

**It never named the shell decision.** A CMP iOS app either runs one `ComposeUIViewController` that owns tabs and back stack, or hands the navigation chrome to SwiftUI's `TabView`/`NavigationStack` and renders one Compose screen per destination. The second shape is the only route to iOS 26 **Liquid Glass**, because the system draws those effects through the native containers and no Compose API or shader reproduces them. It also decides navigation library, entry-point count, and the Swift side all at once, and reversing it later is a rewrite. The decision now sits above the screen-writing sections, with the worked migration (navigation interception via `snapshotFlow`, the `LocalUseNativeNavigation` local, the two `UIViewControllerRepresentable` bridges) and the `if #available(iOS 26.0, *)` fallback in the reference.

**`UIKitInteropProperties` was missing entirely**, which is where interop bugs actually get fixed and whose defaults are the surprising part: touches run through a cooperative 150ms delay since 1.7.0 (so a full-screen map feels laggy and fights the scroll until `interactionMode = NonCooperative`), `isNativeAccessibilityEnabled` is off (so VoiceOver skipping a native view is a property, not a semantics bug), and `placedAsOverlay` is what a transparent native layer needs.

**The `compose.*` Gradle aliases are deprecated** from 1.10.0-beta01, so `implementation(compose.material3)` is exactly the muscle memory that now writes deprecated code. The skill asks for direct Maven coordinates and notes the BOM is planned, not shipped.

**Navigation 3** (CMP 1.10+) is now covered alongside `navigation-compose`, including the leak that has nothing warning about it: without `entryDecorators`, ViewModels stay scoped to the Activity instead of the destination.

Also added: the `ComposeUIViewController(configure = { ... })` knob table (`opaque`, `onFocusBehavior`, `enforceStrictPlistSanityCheck`, `parallelRendering`), concurrent rendering going default-on in 1.11.0, `compose.resources` Gradle knobs (`nameOfResClass`, `customDirectory`), `PlatformImeOptions` for iOS keyboard traits, a version anchor in the body, and explicit routing to `kmp-module-setup` / `kmp-ios-integration` / `kmp-boundaries` for anything build-shaped.

Four errors the skill had been carrying, caught by review and corrected against the docs:

- The `composeResources` tree named `strings/` and `fonts/`, neither of which exists. The real directories are `values/` (holding `strings.xml`, with locale qualifiers as `values-es/`) and `font/`, singular. A misnamed directory generates nothing and reports nothing, so this was the most expensive kind of wrong.
- `CADisableMinimumFrameDurationOnPhone` was described as causing a silent frame-rate cap when missing. Since 1.7.0 the check is strict and the app **crashes at startup**; the silent cap only survives behind `enforceStrictPlistSanityCheck = false`. The docs page went further and said "there's no crash or warning pointing at it", which was the exact opposite of current behaviour.
- `accessibilitySyncOptions` was presented as a live `configure` knob. It was **removed in 1.8.0**, when the iOS accessibility tree became lazy and needs no configuration, so the snippet passing `AccessibilitySyncOptions.Always(...)` would not have compiled on the version the skill anchors to.
- `interopProperties =` was offered as the older name for the `UIKitInteropProperties` parameter. It has been `properties =` since the API shipped in 1.7.0; `interopProperties` exists only as a typo in one JetBrains migration-doc snippet, so hedging between them taught an API that never existed.

Smaller corrections in the same pass: Navigation 3 is no longer alpha off Android (stable 1.1.x as of 1.11), the Navigation 3 decorator coordinates now name the multiplatform artifacts rather than the Android-flavoured ones, `useSeparateRenderThreadWhenPossible` is marked as changelog prose rather than a real property, the `placedAsOverlay` snippet carries the `@OptIn` it needs to compile, the Kotlin floor notes the 2.1.0-vs-2.2 discrepancy between the compatibility page and the 1.10.0 release notes, and a leaked research note ("The assigned URL 404'd") is gone from the reference. The docs page also gained the `## Where it fits` section the template requires.

Removed: `reference.md`'s CocoaPods section, which was a verbatim duplicate of `kmp-ios-integration/cocoapods-reference.md`. It is a pointer now, keeping only the two facts that change what Compose code can assume (iOS resources land outside `.lproj`, so `CFBundleLocalizations` does nothing to them; raw `pod install` drops them from the bundle where `./gradlew podInstall` does not).
