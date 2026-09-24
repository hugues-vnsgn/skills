---
name: kmp-release-and-publish
description: Use when preparing KMP Android/iOS release artifacts, configuring signing or release CI, validating minified builds and Apple archives, or publishing a KMP library. For test placement and individual Gradle test-task selection, use kmp-test-seams.
---

# KMP Release and Publish

Identify the deliverable first: Android app, iOS app, Maven library or Apple binary distribution. Inspect the project's release configuration, target list and existing pipeline. Preserve its distribution method unless the task requires changing it.

| Deliverable | Read when needed |
|---|---|
| Android bundle or iOS archive | [App release checks](reference.md#app-release-checks) |
| Maven library or snapshots | [Library publication](reference.md#library-publication) |
| CI topology, credentials, retries | [CI and publication boundaries](reference.md#ci-and-publication-boundaries) |

## Release evidence

For Android, build the actual signed/minified release variant and smoke-test code paths affected by shrinking. Inspect bundled consumer rules and R8 diagnostics before adding project rules; using kotlinx.serialization or Ktor does not by itself justify blanket keep rules.

For iOS, archive the actual scheme and verify the linked framework, resources, privacy manifest coverage and matching symbols. Linkage matters: a static framework's code lands in the app binary, so inspect the archive's symbol files instead of assuming every shared module produces an independently uploaded framework dSYM.

For a library, verify coordinates, tag/version agreement, target publications, POM, signing and API compatibility. Stage/test artifacts before releasing them. Use one coordinated publisher to avoid duplicate root publications. A macOS publisher is the simple choice for Apple binaries/cinterop; pure klib publication has different host requirements.

## CI and authorization

Choose runners from the tasks actually required. Ordinary Android/JVM checks can run on Linux; Apple binary linking, simulator tests and Xcode archives need macOS. Select test tasks from the configured project; `kmp-test-seams`, when installed, owns their placement and discovery. Keep the release job's required platform checks explicit.

Preparing artifacts, uploading to a test track and releasing publicly are different actions. Carry existing user authorization through the requested stage; a request to prepare a release does not authorize upload or publication. Before an authorized external action, name the exact version, artifact and destination. If upload status is ambiguous, inspect the remote deployment before retrying; never blindly repeat an immutable release.

Use existing secret stores and masked environment bindings. Keep private signing material out of the checkout and command arguments; do not print it. Provision new credentials only when the task needs them.

Report artifact paths, platform/variant, verification results and publication status separately. A successful build is not an uploaded or released artifact.
