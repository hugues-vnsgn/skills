# XCTest scaffold selection

Use [IOSTDDScaffolds.swift](../assets/IOSTDDScaffolds.swift) as an adaptation source, not a file to copy wholesale. It contains original, runnable examples with all definitions in one test target. In a real project, move subject and dependency contracts into the production module, keep doubles/tests in the test target, and add `@testable import` using the actual module name. This exposes internal declarations, not private declarations.

## Choose the smallest example

| Need | Types in the asset | Adaptation rule |
|---|---|---|
| Ordinary XCTest unit test | `RenameProfileTests` | Use fresh locals, one action, explicit expected output |
| Unused dependency | `DummyNameStore` | Unexpected use fails the test |
| Fixed value or error | `NameStoreStub` | Configure `Result`; fail unconfigured interactions |
| Observe calls after acting | `NameStoreSpy` | Inspect recorded arguments; count only contractual calls |
| Expected interaction sequence | `NameStoreMock` | Configure expectations first; always call `verify()` |
| Working in-memory state | `InMemoryNameStore` | Keep simplified semantics consistent with required store behavior |
| Controlled callback | `ControlledLoader`, `GreetingService`, `CallbackTests` | Release completion explicitly; assert mapped result and fulfillment |
| Async function | `HTTPTransport`, `ProfileClientTests` | Await into a local, then assert; unexpected thrown errors fail |
| Real URLSession adapter | `SessionTransport`, `FixtureURLProtocol` | Dedicated ephemeral session and immutable fixture response |
| Publisher | `GreetingPublisher`, `PublisherTests` | Subscribe before sending; retain subscription through completion |

For ordinary fixtures that need fallible setup, prefer `throws` plus `XCTUnwrap` to crashing force unwraps. Assertions in custom helpers should forward `file: StaticString = #filePath` and `line: UInt = #line` so failures identify the test call site. Use `defer` or `addTeardownBlock` for resource cleanup where local lifetime alone is insufficient.

The mock explicitly verifies missing calls as well as unexpected values. Register verification with `defer` or teardown; recording without checking proves nothing. A spy is usually enough when only an observable write matters. Avoid requiring implementation order that is not part of the contract.

The asset's mutable stores and callback loader are single-executor helpers. Do not mark them unchecked Sendable to share them across actors. Protect mutable recording with an actor/lock or keep calls on a declared actor. The network stub is immutable and conforms to a Sendable boundary.

## Scope of the examples

The profile example accepts 2xx responses and requires a JSON body containing `name`. Adapt that policy to the endpoint; a valid 204 response may need different behavior. Fixed fixture URLs use `.invalid`; unexpected routes fail inside the custom URLProtocol rather than reaching a server.

The controlled callback completes on the caller's executor. It tests transformation, not production scheduling. The URLProtocol returns synchronously and has no pending work to cancel; it cannot validate in-flight cancellation. Read [async-and-networking.md](async-and-networking.md) before extending either helper.

Eight example tests were compiled with Apple Swift 6.3.1 in Swift 6 language mode and passed on arm64 macOS. They validate the included examples, not a consumer's deployment target, UIKit integration, or every possible double behavior. Respect the consuming target's SDK availability, actor isolation, and Swift language mode; compile adapted templates there.
