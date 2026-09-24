# KMP build configuration

Checked 2026-09-24 against the official sources below. Resolve the project's versions first; these examples illustrate the selected plugin path rather than a universal version catalog.

## Compatibility

Check Kotlin against Gradle, AGP and Xcode in the [KMP compatibility guide](https://kotlinlang.org/docs/multiplatform/multiplatform-compatibility-guide.html). Check UI dependencies separately in [CMP compatibility](https://kotlinlang.org/docs/multiplatform/compose-compatibility-and-versioning.html). The Compose compiler plugin version matches Kotlin. CMP has its own release version; an upgrade does not automatically require bumping all other tools.

## Android library configuration

The [Android-KMP plugin documentation](https://developer.android.com/kotlin/multiplatform/plugin) distinguishes the paths:

| Plugin/version | Target DSL |
|---|---|
| Legacy `com.android.library` with KMP | `kotlin { androidTarget() }` plus top-level `android {}` |
| Android-KMP plugin, AGP 8.10/8.11 | `kotlin { androidLibrary { ... } }` |
| Android-KMP plugin, AGP 8.12+ | `kotlin { android { ... } }` |

Legacy KMP integration uses deprecated AGP APIs; AGP 9 requires compatibility opt-ins. Consult the installed release's migration guide instead of treating every AGP 9 project as already migrated.

For the Android-KMP plugin on AGP 8.12+, the library setup is:

```kotlin
plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidKmpLibrary)
}
kotlin {
    android {
        namespace = "com.example.shared"
        compileSdk = libs.versions.androidCompileSdk.get().toInt()
        minSdk = libs.versions.androidMinSdk.get().toInt()
        androidResources { enable = true } // when this module needs Android resources
    }
    iosArm64()
    iosSimulatorArm64()
    sourceSets {
        commonTest.dependencies { implementation(kotlin("test")) }
    }
}
```

The catalog alias `androidKmpLibrary` must name `com.android.kotlin.multiplatform.library`. Keep app variants, `BuildConfig` assumptions, signing and launcher components outside this single-variant library. Move Android `externalNativeBuild` into a standalone Android library when needed. Enable Java compilation with `withJava()` only for Java sources in the module.

Host/device tests are disabled by default with this plugin. The current DSL exposes `withHostTest {}` and `withDeviceTest {}`; older versions use builder APIs. Inspect the installed API before configuring them. Test placement and task discovery are covered by `kmp-test-seams` when installed.

Consumer rules require explicit publishing, unlike the legacy `android.defaultConfig.consumerProguardFiles(...)` path:

```kotlin
kotlin {
    android {
        optimization {
            consumerKeepRules.apply {
                publish = true
                file("consumer-proguard-rules.pro")
            }
        }
    }
}
```

## Custom source sets

Use the default hierarchy for the ordinary iOS grouping. For a nonstandard target subset, explicitly retain the hierarchy template and connect the custom set. This example assumes the **legacy** Android target plus an existing Desktop JVM target:

```kotlin
kotlin {
    androidTarget()
    jvm()
    iosArm64()
    iosSimulatorArm64()
    applyDefaultHierarchyTemplate()
    sourceSets {
        val jvmAndroidMain by creating {
            dependsOn(commonMain.get())
            dependencies { implementation(libs.jackson.module.kotlin) }
        }
        androidMain.get().dependsOn(jvmAndroidMain)
        jvmMain.get().dependsOn(jvmAndroidMain)
    }
}
```

With the Android-KMP plugin, configure its `android` target instead of declaring `androidTarget()`. Check the generated hierarchy after syncing. Declaration order follows Kotlin variable scope, not a special requirement that Android be declared last. See [manual hierarchy configuration](https://kotlinlang.org/docs/multiplatform/multiplatform-hierarchy.html#manual-configuration).

## Apple binaries

For an app consuming an Objective-C framework:

```kotlin
kotlin {
    listOf(iosArm64(), iosSimulatorArm64()).forEach { target ->
        target.binaries.framework {
            baseName = "Shared"
            isStatic = true
        }
    }
}
```

Choose linkage from the app's integration requirements. Static frameworks link into the app binary; dynamic frameworks need embedding and signing. An extension is not by itself proof that dynamic linkage is required. Keep the existing working linkage unless there is a concrete reason to change it.

Only `api` dependencies can be explicitly exported:

```kotlin
kotlin {
    sourceSets.commonMain.dependencies { api(project(":core-models")) }
    iosArm64().binaries.framework { export(project(":core-models")) }
}
```

Apply exports consistently to all shipped framework targets. Avoid transitive export unless consumers require the entire dependency graph. Keep implementation libraries behind a Swift-friendly facade where possible.

For binary distribution, create an `XCFramework` and add each target framework to it; discover generated assembly tasks instead of assuming their names. See [native binaries and framework export](https://kotlinlang.org/docs/multiplatform/multiplatform-build-native-binaries.html) and [XCFramework publication](https://kotlinlang.org/docs/multiplatform/multiplatform-build-native-binaries.html#build-xcframeworks).
