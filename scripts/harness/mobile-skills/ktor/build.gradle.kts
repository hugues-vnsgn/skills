plugins {
 kotlin("jvm") version "2.3.21"
 kotlin("plugin.serialization") version "2.3.21"
}
repositories { mavenCentral() }
dependencies {
 implementation("io.ktor:ktor-client-core:3.1.3")
 implementation("io.ktor:ktor-client-auth:3.1.3")
 implementation("io.ktor:ktor-client-content-negotiation:3.1.3")
 implementation("io.ktor:ktor-serialization-kotlinx-json:3.1.3")
 testImplementation("io.ktor:ktor-client-mock:3.1.3")
 testImplementation(kotlin("test-junit"))
}
kotlin { jvmToolchain(21) }
tasks.test { testLogging { events("passed", "failed", "skipped"); showStandardStreams = true } }
