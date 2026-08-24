## What it does

`kmp-release-and-publish` ships KMP work: Android release builds through Play, iOS archives through TestFlight/App Store, libraries to Maven Central, and the CI that runs it all. Its organizing rule: **only Apple-touching jobs run on macOS**, and everything else stays on Ubuntu at a tenth of the cost.

## When to reach for it

The agent reaches for it automatically for release configs, signing, store submission, `maven-publish`/Central Portal setup, or GitHub Actions workflows in a KMP repo. Reach for it yourself when a crash appears only in release builds (R8 over shared code), when App Store review flags privacy, or when deciding which Gradle task tests what.

## The traps it disarms

R8 strips reflection-using shared code (serialization, Ktor, Koin), so QA a minified build and read `missing_rules.txt`. The privacy manifest must cover the shared framework or Apple rejects. Maven Central 2026 = Central Portal + vanniktech plugin, one macOS host, no `-SNAPSHOT`. `~/.konan` gets cached keyed on the version-catalog hash.

## Common questions

**The app works fine in debug but crashes only in the release build. Where do I even start?**

R8 shrinking the shared module, almost certainly. `commonMain` code that leans on reflection, such as kotlinx.serialization, Ktor, Koin and Room, needs keep rules, or R8 strips something it can't see is used. Read `missing_rules.txt` from the failing build first; it names what got stripped. This is exactly why a minified build needs its own QA pass rather than trusting that debug behavior transfers.

**Do I need to sign or configure the iOS app differently because it has a KMP framework in it?**

No. The framework builds transparently as part of the normal Xcode archive step and gets signed with the app's own certificate, so there's no separate provisioning to set up. What *is* KMP-specific: a privacy manifest covering the shared framework's required-reason API usage (a real App Store rejection risk), and uploading the framework's dSYMs so crashes symbolicate back to Kotlin lines instead of showing up as unreadable native frames.

**Why does publishing to Maven Central need a specific host?**

Because Apple targets can only be built and signed on macOS, and the Central Portal forbids duplicate root-module uploads from two different hosts. So the whole publish, every target and not just the Apple ones, has to run from one macOS machine in one job, rather than splitting targets across runners the way test jobs do.

**Why is CI only using a macOS runner for some jobs?**

Because macOS runners cost roughly 10x what Ubuntu runners do, and most of a KMP CI pipeline doesn't touch Apple targets at all. `commonTest` logic and Android assemble/bundle run fine on Ubuntu; only the iOS link, `iosSimulatorArm64Test`, and archive steps need macOS. Routing everything to macOS "to be safe" is the mistake this splits you away from, and it's a cost problem with no correctness benefit.

## It's working if

- iOS tests run locally via `./gradlew iosSimulatorArm64Test` with Xcode closed.
- The CI bill shows macOS minutes only for link/test/archive jobs.
- Release-only crashes are rare because minified builds are QA'd before rollout.
