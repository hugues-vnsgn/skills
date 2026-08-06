## What it does

`kmp-release-and-publish` ships KMP work: Android release builds through Play, iOS archives through TestFlight/App Store, libraries to Maven Central, and the CI that runs it all. Its organizing rule: **only Apple-touching jobs run on macOS** — everything else stays on Ubuntu at a tenth of the cost.

## When to reach for it

The agent reaches for it automatically for release configs, signing, store submission, `maven-publish`/Central Portal setup, or GitHub Actions workflows in a KMP repo. Reach for it yourself when a crash appears only in release builds (R8 over shared code), when App Store review flags privacy, or when deciding which Gradle task tests what.

## The traps it disarms

R8 strips reflection-using shared code (serialization, Ktor, Koin) — QA a minified build, read `missing_rules.txt`. The privacy manifest must cover the shared framework or Apple rejects. Maven Central 2026 = Central Portal + vanniktech plugin, one macOS host, no `-SNAPSHOT`. `~/.konan` gets cached keyed on the version-catalog hash.

## It's working if

- iOS tests run locally via `./gradlew iosSimulatorArm64Test` with Xcode closed.
- The CI bill shows macOS minutes only for link/test/archive jobs.
- Release-only crashes are rare because minified builds are QA'd before rollout.
