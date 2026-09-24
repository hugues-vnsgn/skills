## What it does

`kmp-ios-integration` connects shared Kotlin code to Xcode and checks the API Swift consumes. It preserves the existing integration route unless the task calls for migration, and verifies the Swift caller rather than treating a Kotlin compile as sufficient.

## When to reach for it

Type `/kmp-ios-integration`, or the agent reaches for it automatically for Xcode framework integration, Pod failures, exported Kotlin APIs and coroutine bridges.

| Work | Skill |
|---|---|
| Direct integration, CocoaPods, SPM or Swift API behavior | This skill |
| Producing the framework and configuring targets | [kmp-module-setup](kmp-module-setup.md) |
| Embedding native UI or Compose screens | [compose-multiplatform-ui](compose-multiplatform-ui.md) |

## Check the consumer boundary

Objective-C framework export and Swift export have different mappings and build integration. The skill identifies the selected path before reasoning about exceptions, generics or coroutine cancellation. References load separately for interop and CocoaPods work.

## Common questions

**The app runs old Kotlin code after an Xcode build. Where should I look?**

Inspect the active scheme, build phase, generated framework and script log. Direct integration also needs the documented script-sandboxing setting; stop a Gradle daemon started under the sandbox before retrying. The symptom alone does not establish a cause.

**A Kotlin exception crashes Swift instead of being catchable. What changes?**

At the Objective-C export boundary, declare the expected exception types with `@Throws`, then exercise the error from Swift. Suspend cancellation needs its own check with the selected bridge.

**Should I replace the existing coroutine bridge with Swift export?**

A working bridge stays unless migration is part of the task. Swift export is still Alpha in the checked documentation. Test cancellation and Flow termination with the actual generated API when evaluating a change.

## It's working if

- Kotlin edits appear in the actual Xcode scheme's next build.
- Swift can call the exported API and handle its declared errors.
- Cancellation and stream termination have observed results where used.

## Where it fits

A standalone integration reference between [kmp-module-setup](kmp-module-setup.md) and [compose-multiplatform-ui](compose-multiplatform-ui.md). The first produces binaries; the second handles UI ownership and interop. [ask-matt](https://aihero.dev/skills-ask-matt) carries the wider workflow map.
