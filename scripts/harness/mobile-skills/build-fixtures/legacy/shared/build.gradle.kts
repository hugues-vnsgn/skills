plugins { kotlin("multiplatform"); id("com.android.library") }
kotlin {
    androidTarget()
    iosArm64()
    iosSimulatorArm64()
    sourceSets { commonTest.dependencies { implementation(kotlin("test")) } }
}
android {
    namespace = "fixture.shared"
    compileSdk = 35
    defaultConfig { minSdk = 24 }
}
