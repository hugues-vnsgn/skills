plugins {
    kotlin("multiplatform")
    id("com.android.kotlin.multiplatform.library")
}
kotlin {
    android {
        namespace = "fixture.shared"
        compileSdk = 36
        minSdk = 24
        androidResources { enable = true }
        withHostTest {}
        optimization {
            consumerKeepRules.apply {
                publish = true
                file("consumer-proguard-rules.pro")
            }
        }
    }
    iosArm64()
    iosSimulatorArm64()
    targets.withType<org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget>().configureEach {
        binaries.framework {
            baseName = "Shared"
            isStatic = true
        }
    }
    sourceSets {
        commonTest.dependencies { implementation(kotlin("test")) }
    }
}
