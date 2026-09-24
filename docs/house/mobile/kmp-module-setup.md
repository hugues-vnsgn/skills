## What it does

`kmp-module-setup` configures a shared module's Gradle plugins, targets, source sets and Apple framework. It starts from the installed toolchain, so a small build fix does not turn into an unsolicited plugin migration.

## When to reach for it

Type `/kmp-module-setup`, or the agent reaches for it automatically for shared-module creation, version changes and Android-KMP plugin migration.

| Question | Skill |
|---|---|
| Which plugin, source set or framework export configuration? | This skill |
| Interface or expect/actual for a platform capability? | [kmp-boundaries](../../../skills/house/mobile/kmp-boundaries/SKILL.md) |
| How does Xcode consume the framework? | [kmp-ios-integration](kmp-ios-integration.md) |

## Configuration follows the installed plugin

Legacy Android integration and the Android-KMP library plugin expose different DSLs and test components. The skill identifies the branch first, then uses the project's task list to verify it. Kotlin, Gradle, AGP, Xcode and CMP must be compatible; they do not all need to change together.

## Common questions

**Do I need manual `dependsOn` wiring?**

Standard iOS groupings use the default hierarchy. Manual wiring belongs to a custom target subset, such as shared JVM-only code for Android and Desktop. The skill checks the existing hierarchy before removing any configuration.

**Must an iOS extension use a dynamic Kotlin framework?**

An extension alone does not decide linkage. The skill checks the consuming targets and packaging requirements, preserving static linkage when it still fits.

**Swift shows an unfamiliar generated dependency type. Is `implementation` always the cause?**

No. Inspect the public Kotlin signature and generated header. Exporting dependency declarations requires `api(...)` plus framework `export(...)`; exporting every transitive dependency is not a general naming fix.

## It's working if

- The proposed configuration matches the installed Android plugin.
- Changed Android and Apple targets compile with the reported commands.
- Unsupported host/SDK checks are reported as unverified.

## Where it fits

A standalone build-configuration reference. [kmp-ios-integration](kmp-ios-integration.md) covers the consumer in Xcode; [kmp-test-seams](kmp-test-seams.md) selects tests from the configured targets. [ask-matt](https://aihero.dev/skills-ask-matt) carries the wider workflow map.
