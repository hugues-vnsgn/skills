## What it does

`kmp-ios-integration` connects the shared Kotlin framework to the iOS app and keeps the Kotlin→Swift API surface safe. It forces one choice up front — direct integration, CocoaPods, SPM, or KMMBridge — because two of them (direct and CocoaPods) are mutually exclusive and mixing them is the classic broken setup.

## When to reach for it

The agent reaches for it automatically when touching the Xcode↔Gradle boundary: `embedAndSignAppleFrameworkForXcode`, the `cocoapods {}` block, Podfiles, or exported `commonMain` API that Swift consumes. Reach for it yourself when Xcode "builds" but the Kotlin framework never updates, when a pod won't cinterop, or before publishing shared API to the iOS team. For module structure and the framework block itself, use [kmp-module-setup](../../skills/mobile/kmp-module-setup/SKILL.md).

## The checklist it carries

The Swift-facing API review: `@Throws` on throwing functions (missing it = production crash, not a Swift error), sealed classes behind SKIE or a facade, one coroutine-interop layer only, constrained generics, `@HiddenFromObjC` on internals. Plus the #1 support answer: **disable Xcode's User Script Sandboxing** or the framework build silently no-ops.

## It's working if

- Kotlin edits show up in the next Xcode build without manual Gradle runs.
- Kotlin exceptions surface as catchable Swift `throws`, never crashes.
- The exported header is a small facade, not the whole module.
