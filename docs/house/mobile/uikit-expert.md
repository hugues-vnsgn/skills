## What it does

`uikit-expert` guides native UIKit implementation, review, and refactoring. It covers view-controller lifecycle, Auto Layout, collection views and cell configuration, navigation, animation, memory management, concurrency, adaptive appearance, accessibility, and UIKit–SwiftUI interop.

It separates correctness from optional performance work. Lifecycle and containment errors are treated as bugs; downsampling and prefetching are suggested when evidence or the task calls for them. It does not prescribe MVVM, Coordinators, or a formatting style.

## When to reach for it

Type `/uikit-expert`, or the agent reaches for it automatically when building or reviewing UIKit views and view controllers. Reach for it when constraints churn, reusable cells show stale images, view controllers leak, navigation transitions race, or UIKit needs to host SwiftUI content. For a screen owned by SwiftUI, use [swiftui-expert-skill](./swiftui-expert-skill.md) instead; for a screen owned by shared Compose UI, use [compose-multiplatform-ui](./compose-multiplatform-ui.md).

## The lifecycle boundary

- **One-time setup:** install subviews, constraints, and delegates in `viewDidLoad`.
- **Geometry-dependent work:** use `viewIsAppearing` rather than assuming layout is final in `viewDidLoad`.
- **Reusable content:** keep stable data-source identifiers and verify identity when an asynchronous image finishes loading.
- **SwiftUI inside UIKit:** give `UIHostingController` proper child-view-controller containment and retain it for the lifetime of its container.

## Common questions

**Does this require an architecture rewrite?**

No. It supplies UIKit-specific correctness and API guidance without mandating MVVM, VIPER, or Coordinators. Business logic can be separated for testability without reorganizing the whole app.

**Should I replace every UIKit view with SwiftUI?**

No. UIKit remains the owner of existing UIKit screens. The skill covers targeted interop when a particular component needs SwiftUI, not wholesale migration.

## It's working if

- Programmatic constraints activate without repeated creation or Auto Layout conflicts during updates.
- A reused list cell never displays an image loaded for the previous item.
- View controllers deallocate after dismissal, and background work stops with their lifecycle.
- VoiceOver and Dynamic Type work for custom controls, and newer APIs have availability fallbacks where required.

## Where it fits

A reach-for-it-anytime native UI reference. [swiftui-expert-skill](./swiftui-expert-skill.md) covers SwiftUI-owned screens; [compose-multiplatform-ui](./compose-multiplatform-ui.md) covers shared Compose screens and the iOS shell decision. [ask-matt](https://aihero.dev/skills-ask-matt) routes the wider set.
