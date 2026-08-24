# Compose Multiplatform: Reference

Compiled from official kotlinlang.org docs (2026-08).

---

## 1. Creating a Compose Multiplatform App

### Project creation

Two official routes:

- **Kotlin Multiplatform IDE plugin** in IntelliJ IDEA / Android Studio: *File | New | Project → Kotlin Multiplatform*, pick targets (Android, iOS, Desktop, Web) and enable the **Share UI** option for iOS/web.
- **KMP web wizard** at [kmp.jetbrains.com](https://kmp.jetbrains.com/) generates a downloadable project with the same layout.

### Module layout

The generated project (full-target template) contains:

| Module | Role |
|---|---|
| `shared` (or `composeApp`) | Kotlin Multiplatform module: shared logic + shared Compose UI (Gradle) |
| `androidApp` | Android application wrapper |
| `iosApp` | Xcode project producing the iOS app |
| `desktopApp` | JVM desktop app |
| `webApp` | Kotlin/JS and Kotlin/Wasm apps |

Inside the shared module, source sets split by platform: `commonMain` (shared Kotlin + Compose), `androidMain`, `iosMain` (Kotlin/Native), `jvmMain` (desktop), `jsMain`, `wasmJsMain`.

### Entry points per platform

- **Common:** a root `@Composable fun App()` in `commonMain` (e.g. `shared/src/commonMain/kotlin/App.kt`) wrapping content in `MaterialTheme`.
- **Android:** a `MainActivity` in `androidMain`/`androidApp` calling `setContent { App() }`.
- **iOS:** a function in `iosMain` returning a `UIViewController`:

```kotlin
fun MainViewController(): UIViewController = ComposeUIViewController { App() }
```

The Swift side (`iosApp`) hosts this view controller, via SwiftUI's `UIViewControllerRepresentable` or directly in UIKit (see §4).

- **Desktop:** a `main()` using `application { Window { App() } }` in `jvmMain`.
- **Web:** `ComposeViewport(document.body) { App() }`.

Template `App.kt` (abbreviated, from the docs):

```kotlin
@Composable
@Preview
fun App() {
    MaterialTheme {
        var showContent by remember { mutableStateOf(false) }
        Column(
            modifier = Modifier
                .background(MaterialTheme.colorScheme.primaryContainer)
                .safeContentPadding()
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Button(onClick = { showContent = !showContent }) { Text("Click me!") }
            AnimatedVisibility(showContent) {
                val greeting = remember { Greeting().greet() }
                Image(painterResource(Res.drawable.compose_multiplatform), null)
                Text("Compose: $greeting")
            }
        }
    }
}
```

### Running

- **Android:** run the `androidApp` configuration against an emulator/device.
- **iOS:** run the `iosApp` configuration against a simulator; for physical devices set the Team ID in Xcode and enable developer mode on the phone.
- **Desktop:** `desktopApp [hot] 🔥` configuration ships with Compose Hot Reload by default (CMP 1.10.0+).
- **Web:** `webApp[js]` / `webApp[wasmJs]`, serves at `http://localhost:8080/`. For cross-browser compatibility builds: `./gradlew composeCompatibilityBrowserDistribution`.

---

## 2. Compose Multiplatform vs Jetpack Compose

**Relationship:** Compose Multiplatform (JetBrains) builds directly on Jetpack Compose (Google), sharing the same compiler, runtime, and core APIs (`@Composable`, `remember`, modifiers, layout, animation, Material/Material3). Jetpack Compose knowledge transfers directly.

**Key mechanism:** on the Android target, CMP resolves to **Google's official Jetpack artifacts** (`androidx.compose.material3:material3`); on other targets it uses JetBrains' ports (`org.jetbrains.compose.material3:material3`). Gradle Module Metadata handles the swap automatically, so Android builds are literally running Jetpack Compose.

**Differences:**
- Platforms: CMP = Android + iOS + desktop + web; Jetpack Compose = Android only.
- Not available in CMP: `androidx.compose.runtime.rxjava2/rxjava3`, Android-only components, and platform-specific APIs (desktop window handling, iOS UIKit interop exist only per-platform).
- Jetpack-only ecosystem pieces (e.g. Maps Compose) need Android-specific handling; CMP libraries are consumable from plain Android Jetpack apps (backward compatible).
- Jetpack multiplatform ports available from JetBrains: Lifecycle, ViewModel, Navigation Compose (`org.jetbrains.androidx.*` coordinates).

**Versioning (as of 2026):**
- **Current stable Compose Multiplatform: 1.11.1**, mapping to **Jetpack Compose 1.11.2**.
- CMP releases ship separately from Kotlin/Jetpack Compose, typically **1-3 months after** the corresponding Jetpack Compose release.
- Kotlin: minimum 2.1.0; K2 compiler mandatory since CMP 1.8.0; Kotlin 2.2.20+ recommended for iOS/web.
- Recent mapping table (CMP → Jetpack Compose): 1.11.1 → 1.11.2; 1.10.3 → 1.10.5; 1.9.3 → 1.9.4; 1.8.2 → 1.8.2; 1.7.3 → 1.7.6.
- Supported platforms at 1.11.1: Android 5.0+ (API 21), **iOS 14+**, macOS 13 arm64+, Windows 10+, Ubuntu 20.04+, WasmGC browsers. 64-bit only.

---

## 3. Resources, Navigation, ViewModel in Common Code

### Resources (`compose.resources` / `Res` class)

Library: `org.jetbrains.compose.components:components-resources` (included automatically when using the Compose Gradle plugin; explicit dependency needed for library modules).

Directory layout under each source set:

```
src/commonMain/composeResources/
├── drawable/   # images, vector XML
├── strings/    # strings.xml (per-locale via qualifiers, e.g. strings-de/)
├── fonts/      # font files
└── files/      # raw files
```

A `Res` class is **generated at build time**. Usage:

```kotlin
Text(stringResource(Res.string.app_name))
Image(painterResource(Res.drawable.icon), contentDescription = null)
Text("Hello", fontFamily = FontFamily(Font(Res.font.custom_font)))
val bytes: ByteArray = Res.readBytes("files/data.json")   // suspend
val uri = Res.getUri("files/video.mp4")                    // for platform APIs / external libs
```

Notes:
- Qualifiers supported for language, screen density, theme.
- **Multi-module resources** work with Kotlin 2.0+ and Gradle 7.6+, so resources can live in any module/source set.
- Web resource loading is async; most other reads are synchronous on the caller thread. Large-file streaming isn't supported, so use `Res.getUri()` and hand it to system APIs.

### Navigation

The assigned URL 404'd; current page is `compose-navigation-routing.html`. Multiplatform Navigation is **Stable** across Android, iOS, desktop, web.

```kotlin
commonMain.dependencies {
    implementation("org.jetbrains.androidx.navigation:navigation-compose:2.9.2")
}
```

Same API as Jetpack: `rememberNavController()`, `NavHost`, type-safe `@Serializable` routes:

```kotlin
@Serializable data object StartScreen
@Serializable data class Patient(val name: String, val age: Long)

@Composable
fun App() {
    val navController = rememberNavController()
    NavHost(navController, startDestination = StartScreen) {
        composable<StartScreen> { /* ... */ }
        composable<Patient> { backStackEntry -> /* ... */ }
    }
}
```

- Each back-stack entry is a `LifecycleOwner` (RESUMED when settled, STARTED while transitioning).
- Web: `navController.bindToBrowserNavigation()` syncs routes to the URL fragment and browser back/forward; `@SerialName("start")` gives readable URLs.
- Deep links and Navigation 3 have their own doc pages (`compose-navigation-deep-links.html`, `compose-navigation-3.html`).
- Reference samples: JetBrains `nav_cupcake` example and the KotlinConf app.

### ViewModel / Lifecycle in common code

```toml
[versions]
androidx-viewmodel = "2.10.0"
[libraries]
androidx-lifecycle-viewmodel-compose = { module = "org.jetbrains.androidx.lifecycle:lifecycle-viewmodel-compose", version.ref = "androidx-viewmodel" }
```

```kotlin
@Composable
fun CupcakeApp(viewModel: OrderViewModel = viewModel { OrderViewModel() }) {
    val uiState by viewModel.uiState.collectAsState()
}
```

Gotchas:
- On non-JVM platforms (iOS in particular) you **cannot call `viewModel()` with no arguments**, because type reflection is unavailable, so always pass an initializer lambda or explicit factory.
- Desktop needs `kotlinx-coroutines-swing` so `Dispatchers.Main.immediate` works for ViewModel coroutines.

---

## 4. Interop with Native iOS UI

Bidirectional, both with SwiftUI and UIKit.

### Compose inside SwiftUI

```kotlin
fun MainViewController(): UIViewController = ComposeUIViewController {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("This is Compose code", fontSize = 20.sp)
    }
}
```

```swift
struct ComposeViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Main_iosKt.MainViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
```

**Required:** add `CADisableMinimumFrameDurationOnPhone = true` to `Info.plist` so Compose can render at high refresh rates.

### SwiftUI inside Compose

Pass a `UIViewController` factory from Swift (wrapping SwiftUI in `UIHostingController`) into a Kotlin entry point that uses `UIKitViewController`:

```kotlin
@OptIn(ExperimentalForeignApi::class)
fun ComposeEntryPointWithUIViewController(
    createUIViewController: () -> UIViewController
): UIViewController = ComposeUIViewController {
    Column(Modifier.fillMaxSize()) {
        Text("SwiftUI inside Compose")
        UIKitViewController(factory = createUIViewController, modifier = Modifier.size(300.dp))
    }
}
```

```swift
Main_iosKt.ComposeEntryPointWithUIViewController(createUIViewController: {
    UIHostingController(rootView: VStack { Text("SwiftUI in CMP") })
})
```

### UIKit both directions

- Compose in UIKit: the `ComposeUIViewController` is just a `UIViewController`, so drop it into a `UINavigationController`/`UITabBarController`.
- UIKit in Compose: `UIKitView(factory = { MKMapView() }, modifier = ..., update = { ... })`. `factory` creates the view, `update` runs when observed Compose state changes; `@ObjCAction` is needed for Objective-C target-action callbacks. Docs show worked examples for maps, `UITextField` two-way binding, `AVCaptureSession` camera, and `WKWebView`.

---

## 5. CocoaPods Integration

### Environment setup

CocoaPods needs Ruby (1.9+; docs use 3.4.7 via rvm/rbenv). Avoid the Homebrew CocoaPods install (Xcodeproj compatibility issues):

```bash
rbenv install 3.4.7 && rbenv global 3.4.7
sudo gem install -n /usr/local/bin cocoapods
```

### Plugin setup

The CocoaPods Gradle plugin version **must match the Kotlin plugin version** (min Kotlin 1.7.0):

```toml
[plugins]
kotlinCocoapods = { id = "org.jetbrains.kotlin.native.cocoapods", version.ref = "kotlin" }
```

```kotlin
// shared module build.gradle.kts
plugins {
    kotlin("multiplatform")
    kotlin("native.cocoapods")
}

kotlin {
    iosArm64(); iosSimulatorArm64()
    cocoapods {
        // required — feed the generated podspec
        version = "1.0"
        summary = "Shared KMP module"
        homepage = "https://example.com"
        ios.deploymentTarget = "16.0"

        name = "MyCocoaPod"                       // optional; defaults to project name
        framework {
            baseName = "Shared"
            isStatic = false                      // dynamic by default
            transitiveExport = false
        }
        // map custom Xcode configurations to Kotlin build types
        xcodeConfigurationToNativeBuildType["CUSTOM_DEBUG"] = NativeBuildType.DEBUG
        xcodeConfigurationToNativeBuildType["CUSTOM_RELEASE"] = NativeBuildType.RELEASE

        podfile = project.file("../iosApp/Podfile") // enables automatic pod install integration
    }
}
```

The `podspec` Gradle task generates `<name>.podspec` next to the module, embedding a script phase that rebuilds the Kotlin framework during Xcode builds.

### Pod dependencies from Kotlin (`pod()`)

Declared inside `cocoapods {}`; each pod gets a cinterop binding importable as `cocoapods.<PodName>.*`:

```kotlin
cocoapods {
    pod("SDWebImage") { version = "5.20.0" }                         // CDN
    pod("local_dep") { source = path(project.file("../pod_dep")) }   // local path
    pod("SDWebImage") {                                              // git
        source = git("https://github.com/SDWebImage/SDWebImage") { tag = "5.20.0" }
        // also: commit = "...", branch = "..."
    }
    specRepos { url("https://github.com/Kotlin/kotlin-cocoapods-spec.git") } // custom spec repo
    pod("example")

    pod("FirebaseAuth") {
        packageName = "FirebaseAuthWrapper"       // import FirebaseAuthWrapper.Auth
        version = "11.7.0"
        extraOpts += listOf("-compiler-option", "-fmodules")  // needed for @import headers
    }
}
```

Other knobs: `moduleName` for pods whose framework name differs (`pod("SDWebImage/MapKit") { moduleName = "SDWebImageMapKit" }`), `headers = "GNSMessages.h"` for pods without a `.modulemap`, `useInteropBindingFrom()` to share cinterop bindings between dependent pods, `linkOnly` to link without generating bindings. `ios.deploymentTarget` is mandatory. After edits, re-sync Gradle to regenerate bindings.

### Linking the shared module into Xcode via Pods

Podfile in `iosApp/`:

```ruby
target 'iosApp' do
  use_frameworks!            # or use_modular_headers! — one is required
  platform :ios, '16.0'      # deployment target required on every target
  pod 'shared', :path => '../shared'   # local path to the Kotlin module
end
```

Multi-target (e.g. iOS + tvOS): repeat the `pod ... :path =>` line per target and set `tvos.deploymentTarget` etc. in the `cocoapods {}` block.

### Workflow

1. Edit `build.gradle.kts` (pods, framework config).
2. Run `pod install`, or preferably **`./gradlew podInstall`**, which also creates required directories/resources.
3. Open **`.xcworkspace`** (never `.xcodeproj` after pod install).
4. In Xcode Build Settings, **disable "User Script Sandboxing"** for the app target.
5. Build in Xcode. The Kotlin framework rebuilds automatically via the podspec's script phase. With multiple Xcode projects, run `pod install` manually for each.

⚠️ CocoaPods integration is **mutually exclusive with direct integration** (`embedAndSignAppleFrameworkForXcode`); pick one.

### Common errors and fixes

| Symptom | Fix |
|---|---|
| Xcode build can't find `pod` | Set `kotlin.apple.cocoapods.bin=/Users/you/.rbenv/shims/pod` in `local.properties` |
| Module/framework not found | `gem update --system && gem update`; check `use_frameworks!` and deployment targets present |
| Framework name mismatch | `pod("X/Sub") { moduleName = "..." }` |
| Pod has no `.modulemap` | `headers = "SomeHeader.h"` in the `pod()` block |
| Resources missing from app bundle | Use `./gradlew podInstall` instead of raw `pod install` |
| Rsync/sandbox error during build | Disable User Script Sandboxing in Xcode; `./gradlew --stop` |
| Obj-C `@import` headers fail cinterop | `extraOpts += listOf("-compiler-option", "-fmodules")` |

---

## 6. Hot Reload, Previews, and iOS-Specific Concerns

### Compose Hot Reload

- **JVM/desktop only** for now. Official guidance: use the desktop target as your fast-iteration sandbox for common UI, then verify on Android/iOS.
- Bundled and on by default for desktop targets since **CMP 1.10.0**; earlier versions apply plugin `org.jetbrains.compose.hot-reload` manually.
- Requires Kotlin 2.1.20+, JetBrains Runtime (Java 21), IntelliJ 2025.2.2+ / Android Studio Otter+.
- Workflow: run "desktopApp with Compose Hot Reload", save a file, changes apply to the running app.
- `@Preview` on common composables (as in the template's `App()`) renders in the IDE; hot reload is a separate, running-app mechanism.

### iOS performance

- Compose renders via its own canvas (Skia/Skiko) inside `ComposeUIViewController`. Add `CADisableMinimumFrameDurationOnPhone` to `Info.plist` or the app is capped below ProMotion refresh rates.
- Debug Kotlin/Native builds are markedly slower than release, so judge scrolling/animation performance on **release** builds on real devices.

### iOS accessibility

- Compose semantics map automatically to iOS Accessibility (VoiceOver, screen readers); `Modifier.testTag` maps to `accessibilityIdentifier`, enabling **XCTest** UI automation and `performAccessibilityAudit()`.
- Tune tree syncing via `ComposeUIViewController(configure = { accessibilitySyncOptions = AccessibilitySyncOptions.Always(...) })`. Modes: `Never`, `WhenRequiredByAccessibilityServices`, `Always`, with an optional debug logger.
- Material3 has no built-in high-contrast scheme: detect `UIAccessibilityDarkerSystemColorsEnabled` and supply custom palettes (WCAG 4.5:1 standard text, 7:1 for stricter compliance).
- AssistiveTouch and Full Keyboard Access work with Compose content.

---

