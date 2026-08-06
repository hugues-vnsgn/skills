You are Research Agent 1 of 3. Research **Kotlin Multiplatform fundamentals and iOS integration** for a mobile dev team building shared Kotlin + Compose Multiplatform apps targeting Android and iOS (Swift).

Use WebFetch/WebSearch on these official docs (and anything they link that's relevant):
- https://kotlinlang.org/docs/multiplatform/get-started.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-ios-integration-overview.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-expect-actual.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-share-on-platforms.html

Cover:
1. KMP project structure (source sets: commonMain, androidMain, iosMain; hierarchy; Gradle plugins and version catalog conventions).
2. expect/actual mechanism and when to prefer interfaces + DI instead.
3. iOS integration options compared: direct integration (embedAndSignAppleFrameworkForXcode), CocoaPods, SPM, KMMBridge — trade-offs and which to pick when.
4. Swift/Kotlin interop: what Kotlin API surface exports well to Swift/ObjC, common pitfalls (sealed classes, coroutines, default args, generics), naming (@ObjCName, SKIE).
5. Recommended Gradle config snippets (framework config, static vs dynamic, binaries).
6. Common pitfalls and current best practices as of 2026 (note the current stable Kotlin version).

WRITE your final report as markdown to the file `/Users/hugues_mini/Codes/skills/research/agent1-kmp-core.md`. Structure it with headings, concrete code/config snippets, and a "Skill recommendations" section at the end suggesting what agent skills a team should have for this area. Writing that file is your primary deliverable — do it even if some fetches fail (note failures in the report).
