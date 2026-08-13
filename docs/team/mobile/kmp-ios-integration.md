## What it does

`kmp-ios-integration` connects the shared Kotlin framework to the iOS app and keeps the Kotlin→Swift API surface safe. It forces one choice up front — direct integration, CocoaPods, SPM, or KMMBridge — because two of them (direct and CocoaPods) are mutually exclusive and mixing them is the classic broken setup.

## When to reach for it

The agent reaches for it automatically when touching the Xcode↔Gradle boundary: `embedAndSignAppleFrameworkForXcode`, the `cocoapods {}` block, Podfiles, or exported `commonMain` API that Swift consumes. Reach for it yourself when Xcode "builds" but the Kotlin framework never updates, when a pod won't cinterop, or before publishing shared API to the iOS team. For module structure and the framework block itself, use [kmp-module-setup](../../../skills/team/mobile/kmp-module-setup/SKILL.md).

## The checklist it carries

The Swift-facing API review: `@Throws` on throwing functions (missing it = production crash, not a Swift error), sealed classes behind SKIE or a facade, one coroutine-interop layer only, constrained generics, `@HiddenFromObjC` on internals. Plus the #1 support answer: **disable Xcode's User Script Sandboxing** or the framework build silently no-ops.

## Common questions

**Xcode says the build succeeded, but the app is running old Kotlin code. What's wrong?**

User Script Sandboxing is almost certainly still on. It's the #1 support answer because the failure is silent — the Gradle build phase runs, reports success, and produces nothing, so nothing in the Xcode log points at it. Disable "User Script Sandboxing" in Build Settings, and if the Gradle daemon already started under a sandboxed run, stop it with `./gradlew --stop` before rebuilding.

**A Kotlin exception is crashing the app instead of arriving in Swift as a normal error. Why?**

Missing `@Throws(Exception::class)` on the throwing Kotlin function. Without it, the exception crosses into Swift as an uncaught Objective-C exception — a crash, not a `throws`-able Swift error. It's the one item on the review checklist that fails in production rather than at build time.

**Should I use SKIE or KMP-NativeCoroutines for suspend functions and Flow?**

Pick exactly one. Both solve the same problem — default `suspend`/`Flow` interop gives no cancellation and an opaque Flow type in Swift — and running both at once is an unsupported combination, not a stronger fix. SKIE additionally covers sealed-class exhaustiveness and default arguments, so it's the more common default unless the project already commits to KMP-NativeCoroutines.

**I have both CocoaPods and direct integration set up. Now what?**

Pick one; they're mutually exclusive in the same module. Moving off CocoaPods means `pod deintegrate` and removing the `cocoapods {}` block *before* wiring up `embedAndSignAppleFrameworkForXcode` — not alongside it. Mixing the two is a listed common mistake because the symptoms (duplicate frameworks, workspace confusion) don't obviously point back to "two integration methods are both active."

## It's working if

- Kotlin edits show up in the next Xcode build without manual Gradle runs.
- Kotlin exceptions surface as catchable Swift `throws`, never crashes.
- The exported header is a small facade, not the whole module.
