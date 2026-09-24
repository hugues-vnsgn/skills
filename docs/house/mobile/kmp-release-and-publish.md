## What it does

`kmp-release-and-publish` prepares and verifies Android/iOS release artifacts and KMP library publications. It distinguishes preparation, upload and public release, carrying the user's authorization through the requested stage.

## When to reach for it

Type `/kmp-release-and-publish`, or the agent reaches for it automatically for release builds, signing, archives, publication and release CI.

| Work | Skill |
|---|---|
| Minified release checks, Apple archives, signing or publication | This skill |
| Individual test placement and task selection | [kmp-test-seams](kmp-test-seams.md) |
| Framework production or Android plugin configuration | [kmp-module-setup](kmp-module-setup.md) |

## Match evidence to the artifact

Test the minified Android artifact and inspect the actual Apple archive. For libraries, verify target publications, coordinates, signing and API compatibility. A build result establishes neither an upload nor a public release.

## Common questions

**Does using Ktor or serialization mean I should keep the whole shared package from shrinking?**

No. Inspect supplied consumer rules, the failing path and R8 diagnostics before adding targeted rules. A release-only failure needs investigation, not blanket retention.

**Can testers consume snapshots through Central Portal?**

Yes, through its separate snapshot repository after enabling snapshots for the namespace. Immutable Central releases and snapshots have different endpoints and consumer configuration.

**The upload timed out. Should I run it again?**

First check the destination for the deployment/version. An ambiguous result can mean the upload succeeded. Resume a known deployment where supported instead of blindly repeating publication.

**Does every Apple-related job need macOS?**

Apple binary linking, simulator tests and app archiving do. Pure klib publication has different host constraints. Choose from the actual targets and cinterop requirements, and coordinate publication to avoid duplicate root artifacts.

## It's working if

- The report names the artifact, platform/variant and validation results.
- A preparation request stops before an unauthorized upload.
- Signing material stays outside source control and logs.
- Upload status and public-release status are reported separately.

## Where it fits

A release-stage reference. [kmp-test-seams](kmp-test-seams.md) owns test selection; [kmp-ios-integration](kmp-ios-integration.md) owns the framework's Xcode integration. [ask-matt](https://aihero.dev/skills-ask-matt) places it in the wider workflow.
