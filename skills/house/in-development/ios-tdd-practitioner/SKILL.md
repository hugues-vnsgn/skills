---
name: ios-tdd-practitioner
description: Implement Swift/iOS behavior with test-driven development, reproduce bugs with XCTest, and refactor legacy code under characterization tests. Use for feature changes, testable SDK or network integrations, and test-quality reviews; skip prose-only edits and generated declarations without behavior.
---

# iOS TDD Practitioner

Drive behavior changes through small, deterministic XCTest tests. Preserve the user's architecture, deployment targets, concurrency mode, and existing test conventions. Apply the workflow to the requested change; introducing this skill does not require a framework migration or authorize commits.

## Select the path

- **New or changed behavior:** follow the TDD loop below.
- **Bug fix:** start with the smallest regression that reproduces the reported defect.
- **Legacy refactor:** read [legacy-and-ui.md](references/legacy-and-ui.md#legacy-seams) and characterize the affected behavior before moving it.
- **Test review only:** apply [quality-audit.md](references/quality-audit.md), report actionable findings, and honor the requested review scope.

For SwiftUI/UIKit changes, read [legacy-and-ui.md](references/legacy-and-ui.md#ui-boundaries). For callbacks, Swift concurrency, Combine, timers, or networking, read [async-and-networking.md](references/async-and-networking.md) before choosing a test seam.

## TDD loop

### 1. Establish the contract and test target

Inspect the changed type, nearest tests, build scheme/package, CI commands, and project instructions. Locate the test target that owns the behavior; use the project's actual module and supported destination. Match XCTest where requested or established; preserve existing Swift Testing suites instead of converting them as incidental work.

Describe the input/action and observable outcome. Identify relevant distinctions: empty/one/many, below/at/above a threshold, valid/invalid, initial/next state, success/failure. For stateful or asynchronous work include repeated events and stale results when the contract permits them. Resolve materially ambiguous expected behavior from requirements or the user rather than encoding a guess as fact.

**Exit:** a concrete behavior, appropriate test layer, controllable dependencies, and runnable command are identified.

### 2. Write the smallest discriminating test

Arrange fresh data and collaborators, act on the real subject, then assert independent expected values or contractual side effects. Name the condition and expected result. One behavior may need several related assertions.

Use narrow protocols at uncontrolled boundaries such as networking, storage, hardware, clocks, and notifications. Prefer initializer injection; inject storyboard dependencies before lifecycle work begins. Choose a stub for inputs, spy for observations, mock for predeclared interactions, fake for simplified working state, or dummy for an unused dependency.

Read [scaffolds.md](references/scaffolds.md) when creating a test or double; adapt only the relevant templates. Keep test doubles out of production targets. Prefer visible output over private members, internal call order, or flags added solely for tests.

**Exit:** the test exercises production behavior and would distinguish at least one plausible incorrect implementation.

### 3. Observe red

Run the focused test before implementing the behavior. Confirm that the failure is the intended assertion. For a missing symbol, add only enough declaration to compile and observe behavioral red where feasible. Unrelated build failures, unavailable simulators, and missing dependencies are infrastructure failures, not TDD evidence.

If an extra boundary case already passes, retain it when valuable and record why existing behavior covers it. Do not alter correct code solely to manufacture red. For an unreproduced bug, investigate fixture and trigger differences before claiming a regression test.

**Exit:** record the meaningful failure, or the specific already-covered case. If execution is unavailable, state that red is unverified; continue useful authorized work without claiming the loop ran.

### 4. Implement green

Add the smallest implementation satisfying the selected behavior. Avoid speculative abstractions and future features. Generalize when the next distinguishing test requires it: one item may permit assignment; a second requires accumulation. Complete all accepted requirements before finishing the feature.

Run the focused test and relevant neighboring regressions. Preserve expected behavior when a test fails; change assertions only when requirements or a demonstrable test defect justify it.

**Exit:** the selected behavior and affected regressions pass, or an explicit execution blocker remains disclosed.

### 5. Refactor while green

Improve names, remove duplication, and clarify responsibility in production and tests. Share fixture setup only when all affected cases need it. Keep fixtures fresh and essential scenario fields visible. Keep expected results independent of the implementation being tested.

Make structural changes in small increments and rerun affected tests. Add the next behavioral case through steps 2–5; do not combine unrelated architecture changes with the feature.

**Exit:** behavior remains covered after refactoring, and every requested behavior has a test or a concrete justified exception.

### 6. Verify and report

Apply [quality-audit.md](references/quality-audit.md) before declaring the change ready and before any separately authorized commit. Run the affected suite and repository-required checks. Add adapter/UI checks where unit doubles leave a material wiring gap; do not repeat passing checks without a change or unresolved concern.

Report implemented behavior, test commands/destination and outcomes, meaningful red evidence or exceptions, and any remaining validation gaps. Distinguish compilation, test execution, and integration validation. Never report a passing suite from an empty test selection or silently skipped tests.

**Exit:** the requested behavior is implemented, relevant checks passed, and limitations are explicit. Unavailable execution is not a verified green result.

## Resources

- [scaffolds.md](references/scaffolds.md): selecting and adapting XCTest and five protocol-based double templates.
- [async-and-networking.md](references/async-and-networking.md): callback completion, actor isolation, Combine, clock control, URLSession, cancellation.
- [legacy-and-ui.md](references/legacy-and-ui.md): characterization seams, UIKit/SwiftUI boundaries, and a fixture-driven XCUITest sketch.
- [quality-audit.md](references/quality-audit.md): pre-commit checklist and smell-to-remedy audit.
- [sources.md](references/sources.md): provenance and version/coverage limitations; consult when attributing guidance or updating templates.
