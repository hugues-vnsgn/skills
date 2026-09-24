# Mobile skill verification

This directory retains the questions, fixtures and evidence for the `skills-2zv` upgrade. Skill packages stay independently installable; none depends on this harness at runtime.

## What was exercised

| Check | Result | Scope |
|---|---|---|
| Independent description selection | 24/24 expected owners | Seven skills plus unrelated requests; one evaluator pass |
| Standalone retrieval | Four task questions per skill for six skills; Ktor exercised through an implementation task | Answers and consulted file hashes retained |
| Ktor factory | Nine MockEngine tests pass | Kotlin 2.3.21, Ktor 3.1.3, Gradle 8.14.4, JVM 21 |
| Android-KMP plugin | Android compile, iOS simulator framework link, AAR packaging, two common tests on each platform | Kotlin 2.3.21, AGP 9.0.1, Gradle 9.1.0, SDK 36 |
| Legacy Android plugin | Android compile and two common tests via `testDebugUnitTest` | Kotlin 2.3.21, AGP 8.7.3, Gradle 8.13, SDK 35 |

Read `evidence/2026-09-24/summary.json` for the final package hashes and limitations. Original retrieval answers describe the exact earlier hashes they read; final follow-up evidence records revisions where applicable. Raw compiler/test output and failed draft observations are retained, not discarded in favor of the passing run.

These results establish the listed scenarios. They do not prove automatic skill invocation in every host, improvement against an unassisted model baseline, or runtime behavior of an application using these skills. Exact evaluator model variants were not exposed; the records say so. This is not a `regression_verified` skill benchmark.

## Run the Ktor behavior fixture

From the repository root, with JDK 21 and a compatible Gradle executable:

```bash
python3 scripts/harness/mobile-skills/run-ktor-fixture.py --gradle /path/to/gradle-8.14.4/bin/gradle
```

The runner copies fixture inputs to a temporary directory, extracts the factory from the current `client-reference.md`, compiles it and runs the tests. It prints the retained workspace path. Package hashes, logs and JUnit results stay there; no product source copy is maintained in the fixture.

Tests cover credential refresh/replay, rejected refresh, cancellation, foreign origins/schemes/ports, disabled redirects, a separate unauthenticated download, bounded GET retries and an unretried failed POST. The Ktor 3.1.3 rejection path resends the original request once after a rejected refresh before returning 401; the test records that bounded behavior. Native engines, protected token storage and refresh/logout races are outside this fixture.

## Run the build fixtures

Copy `build-fixtures/modern` or `build-fixtures/legacy` into a temporary workspace before running Gradle. Configure the Android SDK through the usual environment or that temporary workspace's `local.properties`; it is not committed here. The modern fixture also needs macOS, compatible Xcode and an installed iOS simulator runtime.

First discover tasks with the fixture's pinned Gradle version:

```bash
gradle :shared:tasks --all
```

Modern fixture commands (Gradle 9.1.0):

```bash
gradle :shared:compileAndroidMain :shared:linkDebugFrameworkIosSimulatorArm64 :shared:testAndroidHostTest :shared:iosSimulatorArm64Test :shared:bundleAndroidMainAar
```

Legacy fixture command (Gradle 8.13):

```bash
gradle :shared:testDebugUnitTest
```

Inspect XML reports to confirm execution. The modern AAR should include the fixture resource and consumer keep rule. That checks rule packaging, not an R8 consumer app. These small builds do not verify device signing, all AGP compatibility ranges, custom Desktop hierarchies or Swift coroutine/UI behavior.

## Repeat the selection and retrieval exercises

Give an independent evaluator only each query and the current candidate descriptions. Keep `expected_primary` from `routing-cases.json` out of its input. Save its chosen owner and rationale, then compare by case ID. The retained results used this procedure.

For retrieval, give only the named skill directory and the original task questions from the evidence records. Require answers without sibling packages or outside documentation, retaining consulted hashes and raw outputs. Run platform behavior separately where the task's result depends on a compiler, OS or external service. Never interpret a plausible answer as a successful build or publication.
