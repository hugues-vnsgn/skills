You are Research Agent 2 of 3. Research **Compose Multiplatform UI development and CocoaPods integration** for a mobile dev team building shared Kotlin + Compose Multiplatform apps targeting Android and iOS.

Use WebFetch/WebSearch on these official docs (and anything they link that's relevant):
- https://kotlinlang.org/docs/multiplatform/compose-multiplatform-create-first-app.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-cocoapods-overview.html
- https://kotlinlang.org/docs/multiplatform/compose-multiplatform-and-jetpack-compose.html
- https://kotlinlang.org/docs/multiplatform/compose-multiplatform-resources.html
- https://kotlinlang.org/docs/multiplatform/compose-multiplatform-navigation-routing.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-cocoapods-libraries.html
- https://kotlinlang.org/docs/multiplatform/multiplatform-cocoapods-xcode.html

Cover:
1. Creating a Compose Multiplatform app: project template (KMP wizard), module layout, entry points per platform (MainActivity, MainViewController, ComposeUIViewController).
2. Compose Multiplatform vs Jetpack Compose: what's shared, what differs, versioning (CMP releases vs Jetpack Compose), current stable version as of 2026.
3. Resources (compose.resources / Res class), navigation, ViewModel/lifecycle in common code.
4. Interop with native UI: embedding SwiftUI/UIKit in Compose and vice versa.
5. CocoaPods integration: kotlin("native.cocoapods") plugin setup, podspec generation, pod dependencies from Kotlin, linking the shared module into an Xcode project via Pods, pod install workflow, common errors and fixes.
6. Hot reload / previews, and iOS-specific Compose concerns (performance, accessibility).

WRITE your final report as markdown to the file `/Users/hugues_mini/Codes/skills/research/agent2-compose-cocoapods.md`. Structure it with headings, concrete code/config snippets, and a "Skill recommendations" section at the end suggesting what agent skills a team should have for this area. Writing that file is your primary deliverable — do it even if some fetches fail (note failures in the report).
