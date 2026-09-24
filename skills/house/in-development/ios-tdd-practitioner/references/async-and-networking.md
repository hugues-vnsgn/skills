# Asynchronous and network contracts

## Select the waiting mechanism

| Subject API | Test structure |
|---|---|
| `async` / `async throws` | Await directly; assign result before XCTest assertions |
| Callback/delegate in an async test | Create expectation before triggering; `await fulfillment(of:timeout:)` |
| Callback in a synchronous test | `wait(for:timeout:)` with a bounded timeout |
| Notification/event stream | Filter relevant events; count and assert content/sequence |
| Timer/debounce/expiry | Inject clock/scheduler and advance logical time |

Use APIs available in the project's toolchain. Async expectation fulfillment requires a compatible XCTest SDK (introduced with Xcode 14.3); synchronous blocking waits inside concurrent functions can deadlock. Do not downgrade language or concurrency checks just to fit a template.

An expectation proves execution only. Assert payload, error, or state separately. Configure `expectedFulfillmentCount` when count matters and `assertForOverFulfill` for forbidden repeats; multiple identical expectations can all be fulfilled by one event. Keep observation active through the operation's defined completion/quiescence point before claiming exact cardinality. An inverted expectation proves absence only for its bounded observation window.

Use `@MainActor` for UI-bound tests/types as appropriate to the project's isolation model. A synchronous double does not establish correct delivery from a real background callback. Test any promised delivery/isolation contract on success and failure paths. Confine recorded mutable state or synchronize it explicitly.

Create dedicated notification centers where possible; filter sender/content and remove observers. Bound genuine waits using measured CI behavior. A timeout is a failure bound, not a substitute for controlling time. Cancellation is cooperative: a racing task-group timeout does not forcibly terminate a child ignoring cancellation. Use the test runner's timeout facilities for hangs.

## Network layers

1. **Domain unit tests:** inject the consumer's protocol, with local values/errors.
2. **Transport/decoder tests:** assert request method, URL/query, headers/body and parsing when owned by the subject. Cover relevant status, transport, malformed/empty payload, and domain validation cases with independent expected results.
3. **Adapter integration:** use an ephemeral URLSession configured with a custom URLProtocol before session creation. Return fixture responses; reject unexpected requests locally. Invalidate the session after the test.

For callback task adapters, verify start/resume where the adapter owns that responsibility. Async `data(for:)` does not require a manual resume call. Use explicit `Result`/throwing errors so unsuccessful responses are distinguishable from successful empty results. Determine success statuses and error precedence from the endpoint contract.

Prefer immutable URLProtocol fixtures. A static replaceable handler remains cross-test shared state even when access is locked. If configurable routing is necessary, use isolated scenario keys and synchronized storage with teardown; ensure every tested request stays inside the fixture transport. The bundled sample handles ordinary data tasks, not background sessions, streaming, or redirects.

For cancellation and reuse, drive a genuinely pending double. Test cancel-before-completion, allowed late callbacks, and an older request completing after a newer request. Assert that old results cannot overwrite current state. Model the real collaborator's cancellation contract; a fake that suppresses all late callbacks can conceal a production race. Cache-hit tests should prove correct data and no new transport request, using fresh observations for each call.

Keep optional live backend contract checks separate from deterministic unit/fixture integration suites. An intercepted request validates local wiring, not compatibility with today's remote service.

## Combine

Subscribe before sending through a test-controlled subject, retain the cancellable through the assertions, and cancel afterward. Assert values and terminal events separately when both are contractual. For fallible publishers, distinguish expected completion from unexpected failure.

Account for initial `@Published` emissions explicitly. Skip initial state only when the tested scenario excludes it. Avoid truncating a stream with `prefix(1)` if the behavior under test forbids later extra emissions. Inject controllable scheduling for debounce, delay, and retry; test ordering only when promised.

The examples in [IOSTDDScaffolds.swift](../assets/IOSTDDScaffolds.swift) show controlled callback, async transport, and publisher tests. Their one-second bounds are illustrative, not mandatory defaults.
