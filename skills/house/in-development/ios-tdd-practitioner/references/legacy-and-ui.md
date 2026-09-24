# Legacy and UI test boundaries

## Legacy seams

1. Identify the behavior to change and a stable point where it is observable. Map only dependencies that block this change.
2. Create the smallest controllable seam: separate loading from lifecycle work, inject configuration instead of looking through AppDelegate, or replace a global collaborator lookup.
3. Keep any initially untested seam extraction mechanical and behavior-preserving, then characterize immediately with frozen fixtures. Capture relevant success, failure, and boundary behavior.
4. Treat characterization as observed history, not automatic correctness. Record discovered defects; use a separate requirement-based regression test when fixing one.
5. Add the new behavior through the normal TDD loop. Extract a cohesive model/service where it reduces the blocked dependency.
6. Refactor one edge at a time. Replace transitional subclass mocks with narrow protocols when practical. Move modules only when the change benefits, accounting for imports, target membership, resource bundles, and intended public API.

A partial mock is a temporary seam: inherited behavior can still invoke real services. Audit those paths and identify remaining coupling. A sprout method/type can contain a bounded new feature without redesigning a large legacy class; keep follow-up debt explicit. Preserve user edits and separate structural changes from semantic changes in the reviewable diff.

## UI boundaries

Keep business rules and state transitions testable independently of views. Preserve the existing architecture—MVVM, MVP, reducer, or controller—unless the requested change requires otherwise.

- **UIKit:** instantiate the actual storyboard/nib when validating its wiring; inject collaborators before `loadViewIfNeeded()`. Assert owned presentation state or action effects. A plain initializer cannot validate storyboard outlets.
- **SwiftUI:** unit-test feature state, intents, and decisions. Add a focused rendering/navigation check when binding correctness matters. Model tests alone do not prove `body` is wired correctly; avoid asserting private hierarchy details.
- **Snapshots:** use when appearance is the requirement; control size, locale, appearance, and relevant platform baselines.
- **XCUITest:** use a small number of critical user journeys, stable accessibility identifiers, and bounded condition waits. Use domain identifiers for list items instead of indices or localized labels.

## XCUITest sketch

This app-specific template must be adapted and executed against a real UI test target. The field starts empty in the proposed fixture; the confirmation identifier appears only on successful saving.

```swift
import XCTest

final class ProfileUITests: XCTestCase {
    @MainActor
    func testSavingName_displaysConfirmation() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-test-state"]
        app.launchEnvironment["UITEST_SCENARIO"] = "profile-empty"
        app.launch()
        defer { app.terminate() }

        let field = app.textFields["profile.name"]
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("Ada")
        app.buttons["profile.save"].tap()
        XCTAssertTrue(app.staticTexts["profile.saved"].waitForExistence(timeout: 3))
    }
}
```

The arguments/environment key are an app contract you implement, not built-in reset or mocking behavior. The composition root must read them before creating services and select dedicated test storage and fixtures. The UI runner is a separate process; setting a mock in the runner does not replace the app's dependency. Keep fixture controls confined to the intended testing configuration.

Existence does not guarantee hittability. If asynchronous transitions obscure a control, wait for the required interaction state using supported predicates/APIs rather than inserting sleeps. Adjust bounds to measured execution, and seed state directly when onboarding/login are not the behavior under test. Keep each test independent; reducing repeated launches must not create dependencies between tests.
