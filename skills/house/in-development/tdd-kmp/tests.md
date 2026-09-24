# Writing mobile tests

## Shared behavior

Mirror the production package under `commonTest` and import annotations/assertions from `kotlin.test`.
Start each test with fresh state, using `@BeforeTest` / `@AfterTest` only when shared setup or cleanup helps.
Name tests after outcomes and use inputs and expected values derived from the requirement.
Keep related assertions together when they describe one behavior.

For example, given a fee rule of 10% of a 12,500-minor-unit charge, assert the independently calculated result:

```kotlin
import kotlin.test.Test
import kotlin.test.assertEquals

class FeeTest {
    @Test
    fun appliesTenPercentFee() {
        assertEquals(1_250L, calculateFeeMinorUnits(12_500L, 10))
    }
}
```

Treat this API as illustrative; use the feature's existing money representation and rounding rules.
Avoid copying production arithmetic into the expected value or widening private visibility just to inspect internals.
For repository behavior, write through the repository and read back through its contract.

## Coroutines and Flow

Use `@Test fun behavior() = runTest { ... }` from `kotlinx.coroutines.test` for suspend code.
Inject test dispatchers/scopes where the subject permits it, with one `testScheduler` shared across dispatchers.
Use `runCurrent()` for queued work and `advanceTimeBy(...)` followed by `runCurrent()` for a time boundary.
Use `advanceUntilIdle()` only when draining pending work matches the scenario.
Real `Dispatchers.IO`/`Default` work does not acquire virtual time merely by running inside `runTest`.
If the subject requires `Dispatchers.Main`, install a test Main before constructing it and reset Main during teardown.
Cancel owned ViewModel scopes and put long-lived test collectors in `backgroundScope`.

For Flow, subscribe before triggering the action and consume the expected events.
Use Turbine when already available, or a bounded collector with equivalent assertions.
Hold a fake response pending when a loading transition matters, then release it to observe success or failure.
For `StateFlow`, prefer current-state assertions after controlled scheduling unless intermediate states are part of the contract; conflation may skip rapid updates.
Keep a collector active for `stateIn(SharingStarted.WhileSubscribed(...))`.
Bound collection and cancel it at the end; an infinite flow will not finish with `toList()`.

References: [coroutine test utilities](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-test/), [Turbine](https://github.com/cashapp/turbine).

## Native UI and bridge regressions

Test shared business rules in Kotlin, then cover the rendering and integration behavior that shared logic tests cannot observe.

- **Compose:** Drive actions and assertions through semantics and stable test tags where needed.
  Preserve meaningful accessibility descriptions rather than replacing them with machine identifiers.
  Use Compose synchronization and bounded condition waits for external work; its animation clock does not control every background operation.
- **Compose Multiplatform:** Use the configured common UI test API, such as `runComposeUiTest`, when supported by the project's pinned version.
  Mount the production composable with deterministic dependencies, not a miniature copy of the screen in the test.
  Check source-set wiring and target support before adding dependencies or copying imports from current documentation.
  Execute on the affected mobile target; cover native interop, keyboard, focus, and navigation in the app host when an isolated composable cannot reproduce them.
- **SwiftUI:** Use XCUITest accessibility identifiers, bounded existence/predicate waits, and assertions on the visible outcome after interaction.
  A SwiftUI view hosted inside a unit test exposes no controls to XCTest, so drive buttons and inputs through XCUITest and keep XCTest for Swift state logic.
  A custom input view such as an app keypad does not appear among `app.keyboards`; query its own element, and expect it to cover controls beneath it.
  When a control has no accessibility identifier, add one rather than driving it by screen coordinates.
- **Kotlin-to-Swift state:** For a field that appears only on a second visit, reproduce the first visit, edit, and immediate render before navigating away.
  Keep the production observation path in the regression test.
  An in-place mutation of a bridged Kotlin object may not notify SwiftUI; inspect the project's observable Swift state or Flow subscription rather than assuming the bridge publishes that mutation.
  A Kotlin state assertion alone cannot detect a stale SwiftUI render.

For layout regressions, assert relationships derived from the requirement: equal initial heights, shared edges, error alignment, or multiline growth without width growth.
Measure from the visible edge (border, background, or divider), not from a text node sitting inside its container's padding.
Use a tolerance appropriate to rendered units; subtracting the implementation's padding constants until red and green separate encodes the fix, not the requirement.
Size long-content fixtures so they stay long after font or style changes.
Exercise relevant normal, validation, long-content, and accessibility text-size states.
Pair geometry assertions with screenshots to inspect borders, clipping, wrapping, and readable labels, and look at the captured frame of a UI red: during animation a node reported as displayed may not be drawn.

For input/submission bugs, enter through the actual input control, verify the displayed value, and assert the value delivered to a controlled submission boundary.
Test submission while the input remains focused when that is the reported failure; dismissing the keyboard first may hide the bug.

Use deterministic fixtures and isolated test data; see [mocking.md](mocking.md) for lifecycle and submission isolation.
Treat recorded taps or screenshots as reproduction aids; add assertions for the outcome.
When no UI test target exists, add only the setup needed for the requested regression if feasible, or report manual verification separately when automation is blocked.

References: [Compose Multiplatform UI testing](https://kotlinlang.org/docs/multiplatform/compose-test.html), [Compose synchronization](https://developer.android.com/develop/ui/compose/testing/synchronization), [XCUIElement](https://developer.apple.com/documentation/xcuiautomation/xcuielement).

## Source notes

Verify APIs and source-set configuration against the project's pinned versions.
Consult [KMP test execution](https://kotlinlang.org/docs/multiplatform/multiplatform-run-tests.html) and [Android KMP test setup](https://developer.android.com/kotlin/multiplatform/plugin#configure-host-and-device-tests) when runner configuration needs changing.
