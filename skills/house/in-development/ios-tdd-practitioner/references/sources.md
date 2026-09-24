# Provenance and validation

Derived from the supplied research dossier for Joshua Greene and Michael Katz, *iOS Test-Driven Development by Tutorials*, second edition (2022). Book references below use printed pages, which match PDF pages in the supplied 332-page edition. The skill is a synthesis with original scaffolds, not a reproduction of tutorial source code.

| Guidance | Book basis |
|---|---|
| Incremental TDD and triangulation | Chapters 1–4, pp.21–84; one/two item example pp.33–38 |
| One coherent behavior, multiple related assertions | pp.58,102 |
| Isolation and order dependence | pp.74–76,97–108 |
| Expectations and event counts | Chapter 5, pp.85–111 |
| Protocol seams and doubles | Chapter 6, pp.112–136; pp.181–194 |
| Callback network/result delivery | Chapter 8, pp.148–175 |
| Image cache and prior-task cancellation | Chapter 10, pp.213–222 |
| Characterization and legacy seams | Chapters 11–15, pp.231–331 |

The book excludes UI automation (p.57), only briefly discusses SwiftUI and MVVM, and does not teach async/await, URLProtocol interception, MVP, or Combine testing. Its taxonomy lists stub/fake/mock/partial mock; dummy/spy distinctions are supplemental. Production guidance here refines temporary tutorial designs, including singleton resets, nil/nil errors, and sleeps.

## Supplemental primary sources

- [Fowler: Test Double](https://martinfowler.com/bliki/TestDouble.html): fuller taxonomy.
- [Apple: Asynchronous tests](https://developer.apple.com/documentation/xctest/asynchronous-tests-and-expectations): async XCTest and expectations.
- [Apple: Xcode 14.3 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-14_3-release-notes): concurrency-safe fulfillment instead of blocking async tests.
- [Apple: Testing Tips & Tricks](https://developer.apple.com/videos/play/wwdc2018/417/): URLProtocol integration and dependency isolation.
- [Apple: sink](https://developer.apple.com/documentation/combine/publisher/sink(receivecompletion:receivevalue:)): publisher subscription API.
- [Apple: UI automation with Xcode](https://developer.apple.com/videos/play/wwdc2025/344/): stable accessibility identifiers.
- [Apple: launchArguments](https://developer.apple.com/documentation/xcuiautomation/xcuiapplication/launcharguments): process launch configuration.
- [Apple: waitForExistence](https://developer.apple.com/documentation/xcuiautomation/xcuielement/waitforexistence%28timeout%3A%29): bounded UI existence waits.

These sources were researched on 2026-09-13. Confirm SDK availability against the consuming project when adapting APIs rather than requiring a toolchain upgrade.

## Scaffold validation boundary

`assets/IOSTDDScaffolds.swift` is unchanged from the research deliverable. It compiled in Swift 6 language mode with Apple Swift 6.3.1 and ran eight successful XCTest cases on arm64 macOS, including local URLSession interception. The SwiftPM invocation reported a build-database I/O error despite building/running tests; direct `xcrun xctest` execution then passed with exit code 0.

This is example validation, not evidence of an iOS app build or UI execution. The UIKit/SwiftUI guidance and XCUITest sketch need a consuming app target. The fixture URLProtocol does not model in-flight cancellation, redirects, streaming, or background sessions. Mutable store and callback doubles are single-executor examples.
