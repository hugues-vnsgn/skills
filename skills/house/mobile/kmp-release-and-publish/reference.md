# KMP release reference

Checked 2026-09-24. Resolve the project's plugin versions and distribution route before copying commands. The examples use placeholder module/scheme names; discover the actual ones.

## App release checks

### Android

KMP produces an Android library consumed by an ordinary app. Use the app's release variant (for example `:<app>:bundleRelease`) with its existing signing configuration. Keep signing passwords in environment/CI secret bindings, not Gradle files or shell arguments. See [Android app signing](https://developer.android.com/studio/publish/app-signing).

Test a minified artifact, including serialization, dependency injection and any reflection-based behavior. Inspect dependency-provided consumer rules and the actual R8 warning before adding rules. Do not keep entire shared packages by default. Consumer-rule publication belongs to the library's Android plugin configuration: the current Android-KMP plugin requires `optimization.consumerKeepRules.publish = true` and rule files. See [consumer keep rules](https://developer.android.com/kotlin/multiplatform/plugin#consumer-proguard-rules). The legacy `consumerProguardFiles` DSL is not interchangeable with that API.

### iOS

Archive the actual Xcode scheme/configuration. A Pod-based app uses its workspace; direct integration typically uses the project. Keep the framework build phase appropriate to the selected integration method rather than adding another one at release time.

Verify:

- The archive has the intended bundle ID, signing identity, entitlements and deployment target.
- Shared code and resources are included with the correct device architecture and linkage.
- The privacy manifest covers the app and shared code's actual required-reason API usage. Inspect dependencies and the archive; do not invent a generic declaration.
- The crash reporting service receives symbol files matching the archived binaries. Static shared code is linked into the app; a separate framework dSYM is not always the right artifact.

See [KMP app publication](https://kotlinlang.org/docs/multiplatform/multiplatform-publish-apps.html), [privacy manifests](https://kotlinlang.org/docs/apple-privacy-manifest.html) and [native debugging](https://kotlinlang.org/docs/native-debugging.html#debug-ios-applications).

## Library publication

KMP publishing creates a root `kotlinMultiplatform` publication and target publications. Consumers use Gradle metadata to select a target. Keep coordinates/version consistent, validate the POM and signing configuration, and check that all intended targets are present before uploading. For remote Swift consumers, distribute the XCFramework through the existing SPM/Pod packaging pipeline and align its version with the release tag.

A single coordinated macOS publisher avoids duplicate root uploads and supports Apple binary/cinterop work. Pure Apple klibs can be produced from other hosts in supported configurations; linking/testing Apple binaries, CocoaPods and cinterop have additional host constraints. See [publication and host requirements](https://kotlinlang.org/docs/multiplatform/multiplatform-publish-lib-setup.html).

### Central Portal releases and snapshots

Use the project's installed publishing plugin and inspect its task/help output. With `com.vanniktech.maven.publish`, `publishToMavenCentral` stages a deployment and `publishAndReleaseToMavenCentral` requests release. Automatic-release options can alter the former, so inspect configuration before treating a task name as an approval boundary. Read the [plugin documentation](https://vanniktech.github.io/gradle-maven-publish-plugin/central/) for the installed version rather than adding a configuration-cache workaround unconditionally.

| Destination | Contract |
|---|---|
| Maven Central release repository | Immutable releases; validate namespace, signatures, sources, documentation artifacts and required POM metadata |
| Central Portal snapshot repository | Enable snapshots for the namespace and publish `-SNAPSHOT` through its separate endpoint; consumers opt into that repository |
| Local/internal repository | Useful for local integration and organization-specific distribution |

Snapshots are not immutable Central releases. See [Sonatype's snapshot instructions](https://central.sonatype.org/publish/publish-portal-snapshots/) and [release requirements](https://central.sonatype.org/publish/requirements/).

Use a Portal user token, not the account password. Prefer existing protected signing keys. If key creation/export is requested, use a restricted directory outside the checkout and the project's secret-management procedure; never include private key contents or passwords in an example command line. See [KMP publication tutorial](https://kotlinlang.org/docs/multiplatform/multiplatform-publish-libraries-to-maven.html).

## CI and publication boundaries

Derive the matrix from the shipped targets and installed test tasks. Avoid a hardcoded `jvmTest` job for a project with no JVM target. Linux jobs can handle Android compilation/host tests; macOS jobs handle Apple linking, simulator checks and archiving. Runner prices and architectures change, so check the project's selected runner rather than embedding a cost multiplier.

Use `gradle/actions/setup-gradle` for Gradle caching. If caching `~/.konan` separately, include OS/architecture and Kotlin/toolchain inputs in the cache key; do not share incompatible compiler distributions across runner architectures. Pin action/tool versions according to the repository's dependency policy.

For a requested dry run, build/validate locally or stage only in a non-public destination explicitly included in the request. Uploading to TestFlight, Play tracks or a Portal deployment still changes an external service. Reuse explicit authorization, but do not infer it from a build or signing task.

After a failed upload, inspect whether a deployment/artifact already exists. Resume the known deployment when supported; stop if the destination/version cannot be established. Report upload and public-release results independently. See [KMP GitHub Actions](https://kotlinlang.org/docs/multiplatform/github-actions-for-kmp.html).
