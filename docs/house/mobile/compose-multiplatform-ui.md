## What it does

`compose-multiplatform-ui` covers shared screens, resources, navigation, ViewModels and native iOS interop. It preserves the app's existing shell for screen-local work. Navigation ownership becomes a design decision when the requested UI requires it.

## When to reach for it

Type `/compose-multiplatform-ui`, or the agent reaches for it automatically for common Compose UI, UIKit/SwiftUI embedding and iOS touch, rendering or accessibility issues.

| Work | Skill |
|---|---|
| Screens, resources, navigation ownership and embedded native views | This skill |
| Xcode integration or the Swift-facing API | [kmp-ios-integration](kmp-ios-integration.md) |
| Gradle plugins, targets and framework configuration | [kmp-module-setup](kmp-module-setup.md) |

## One owner for navigation

Compose can own the back stack, or native containers can own navigation while Compose renders destinations. Native containers provide system-rendered navigation chrome. A bridge needs one owner for each event so a push or swipe-back does not leave two stacks disagreeing.

A native shell can support older iOS versions too. Keeping separate full-Compose and native shells behind an OS check is an optional product decision with extra testing cost.

## Common questions

**An embedded map feels laggy. Must the shell change?**

No. Inspect the interop touch policy first. Cooperative handling lets Compose claim gestures; noncooperative handling passes them straight to the native view. Verify both the map and its surrounding scroll behavior.

**VoiceOver skips an embedded native view. Is automatic accessibility enough?**

Automatic Compose tree synchronization does not guarantee accessible native content. Check `isNativeAccessibilityEnabled`, the native view's labels/actions and focus order on iOS.

**`viewModel()` works on Android but fails on iOS. Why?**

The default reflective construction path is unavailable on iOS. Supply an initializer or explicit factory, and check the destination's ViewModel owner and disposal behavior.

## It's working if

- A screen-local fix preserves the working navigation architecture.
- Back, swipe-back and tab changes leave a consistent destination state.
- iOS touch and accessibility checks run on iOS, beyond a Desktop preview.
- Performance conclusions state the device and release/debug build mode.

## Where it fits

A standalone shared-UI reference. [kmp-ios-integration](kmp-ios-integration.md) covers the Xcode consumer, and [kmp-boundaries](../../../skills/house/mobile/kmp-boundaries/SKILL.md) designs capabilities called by UI code. See [ask-matt](https://aihero.dev/skills-ask-matt) for the wider map.
