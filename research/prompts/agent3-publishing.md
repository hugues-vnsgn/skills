You are Research Agent 3 of 3. Research **publishing Kotlin Multiplatform apps and libraries** for a mobile dev team building shared Kotlin + Compose Multiplatform apps targeting Android and iOS.

Use WebFetch/WebSearch on these official docs (and anything they link that's relevant):
- https://kotlinlang.org/docs/multiplatform/multiplatform-publish-apps.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-publish-libraries-to-maven.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-publish-lib-setup.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-run-tests.html

Cover:
1. Publishing Android app from a KMP project: release build, signing, bundles (AAB), Play Store specifics for KMP/Compose apps, ProGuard/R8 with Compose Multiplatform.
2. Publishing iOS app: archiving in Xcode, signing/provisioning with the embedded shared framework, App Store submission specifics for KMP apps, bitcode/symbols considerations.
3. Publishing KMP libraries to Maven: maven-publish setup, publishing all targets (host requirements — Apple targets need macOS), Sonatype/Maven Central via the Central Portal in 2026, signing artifacts, klib format.
4. CI/CD patterns: GitHub Actions matrix for KMP (macOS runners for iOS), caching Gradle/Konan, Fastlane usage with KMP, TestFlight & Play internal tracks.
5. Testing across platforms: common tests, platform tests, running iOS simulator tests from Gradle.
6. Versioning strategy for shared libraries consumed by both platforms.

WRITE your final report as markdown to the file `/Users/hugues_mini/Codes/skills/research/agent3-publishing.md`. Structure it with headings, concrete code/config snippets, and a "Skill recommendations" section at the end suggesting what agent skills a team should have for this area. Writing that file is your primary deliverable — do it even if some fetches fail (note failures in the report).
