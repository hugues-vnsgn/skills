# Platform knowledge

Nine model-invoked references support KMP/CMP and native iOS work. Choose by the immediate question; a feature can need several at different stages.

| Question | Skill |
|---|---|
| Which Gradle plugin, target, source set or framework configuration? | `/kmp-module-setup` |
| How should common code call a platform capability, with what lifetime and completion contract? | `/kmp-boundaries` (beta) |
| How does Xcode consume shared code, and what does Swift see? | `/kmp-ios-integration` |
| How should shared screens, native UI interop and navigation ownership work? | `/compose-multiplatform-ui` |
| How should native SwiftUI views handle state, layout, accessibility or an Instruments trace? | `/swiftui-expert-skill` |
| How should a UIKit-owned screen handle lifecycle, Auto Layout, collection views or SwiftUI interop? | `/uikit-expert` |
| How should the Ktor client handle engines, credentials, retries and HTTP errors? | `/kmp-ktor` (beta) |
| Where should a test live and which existing task proves this change? | `/kmp-test-seams` |
| How should the release artifact be verified, signed and published? | `/kmp-release-and-publish` |

`/tdd-kmp` owns the KMP/CMP red-green loop, and `/tdd` owns the generic one. `/kmp-test-seams` supplies platform placement and task discovery without requiring a new JVM target. Release CI consumes those selected checks; release/publish does not own a second test-task map.

Module setup owns build mechanics. Boundaries owns the capability API. iOS integration owns the Swift/Xcode consumer. Compose owns shared UI behavior and the shared-vs-native shell decision, and preserves an existing shell unless the requested change requires different ownership. SwiftUI owns native SwiftUI views, and UIKit owns UIKit-owned screens.
