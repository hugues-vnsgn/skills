## What it does

`swiftui-expert-skill` guides native SwiftUI implementation, review, and refactoring across iOS and macOS. It covers state ownership and `@Observable` data flow, view identity, adaptive layout, lists, navigation, animation, accessibility, and SDK migrations. When a performance problem needs runtime evidence, it can record and analyse Instruments traces with bundled scripts.

It treats each view as an invalidation boundary: pass a view only the data it reads, and keep frequently changing state close to the subtree that consumes it. Its reference files are consulted by topic rather than loaded all at once.

## When to reach for it

Type `/swiftui-expert-skill`, or the agent reaches for it automatically when writing or reviewing native SwiftUI screens. Reach for it when the question is how a SwiftUI view should own state, lay out across available space, expose accessible controls, or adopt a newer API without breaking older deployment targets. For shared Kotlin UI rendered through Compose, use [compose-multiplatform-ui](./compose-multiplatform-ui.md) instead.

## The platform boundary

- **SwiftUI owns the screen:** use this skill for native views, even when a Kotlin framework supplies the data.
- **Compose owns the screen:** use [compose-multiplatform-ui](./compose-multiplatform-ui.md) for shared views and iOS interop.
- **A trace shows jank or hangs:** this skill can correlate SwiftUI updates, hitches, and main-thread samples; its scripts require Xcode's `xctrace` to capture or export a trace.

## Common questions

**Does it require MVVM or rewriting UIKit screens?**

No. It does not enforce an architecture or mandate UIKit migration. It prefers native SwiftUI APIs when building SwiftUI views and bridges to UIKit when needed.

**Will it automatically add Liquid Glass to an existing app?**

No. It adopts Liquid Glass only when explicitly requested, and checks API availability and fallbacks for the app's deployment target.

## It's working if

- State updates redraw the smallest view subtree that reads the changed value.
- Lists preserve row identity across inserts and reorders, so focus and row state survive.
- Newer APIs have availability gates and usable fallbacks on supported older OS versions.
- An investigated performance regression cites trace or profiling evidence rather than attributing jank to an unmeasured view.

## Where it fits

A reach-for-it-anytime native UI reference. [compose-multiplatform-ui](./compose-multiplatform-ui.md) owns shared Compose screens and the iOS shell decision; this skill owns the SwiftUI view work once a native shell or screen is chosen. [ask-matt](https://aihero.dev/skills-ask-matt) maps the rest of the skill set.
