# Mobile test doubles

Keep the real component whose behavior the test promises to verify.
Prefer small constructor-injected Kotlin fakes for unavailable or nondeterministic dependencies.
A ViewModel test may fake its repository; a repository test should exercise the real repository with controlled HTTP or storage.
Keep pure mapping and validation code real.

| Boundary | Default |
| --- | --- |
| Ktor HTTP | `MockEngine` with the real client configuration, serialization, and repository mapping |
| Repository feeding a ViewModel | A small fake exposing controlled success, failure, and suspension |
| SQLDelight queries or migrations | An isolated real database with a supported target driver; close it after the test |
| Clock, IDs, randomness, platform service | Inject a fixed or controllable implementation at the existing boundary |

Reuse the project's pinned test dependencies and verify their target support before adding libraries.
Keep JVM-only mocking libraries out of `commonTest`; a MockK test that runs on Android/JVM does not establish Native compatibility.
Instantiate the subject directly when possible; use an isolated container from the project's DI framework only when DI wiring is itself under test.
Dispose of clients, database drivers, scopes, and global overrides after each test.

For UI fixtures, render the production screen and keep its input, validation, and observation behavior real.
Prefer replacing dependencies at the repository/service boundary so the ViewModel and bridge remain exercised.
If the existing test setup intercepts events instead, enumerate lifecycle, initial loading, change, retry, and submission events before forwarding any event to production code.
Intercepting only the final submit action can leave startup or field-change network requests live.
Make unexpected external calls and unhandled events fail the test; a double that silently drops them hides the next leak.
Ensure test-only launch arguments or dependency overrides cannot enable the fixture in a release build, and check the built release rather than the build flags: fixture code compiled in with empty bodies is still shipped.

## Control completion, not elapsed wall time

A suspendable fake lets a test inspect loading state before allowing a response.
Adapt this illustrative interface to the feature's actual repository contract:

```kotlin
interface RateSource {
    suspend fun load(): List<String>
}

class PendingRates : RateSource {
    val response = kotlinx.coroutines.CompletableDeferred<List<String>>()
    override suspend fun load(): List<String> = response.await()
}
```

Complete `response` with a known fixture, or complete it exceptionally with the error the contract defines.
Use the test scheduler for delays and cancellation rather than sleeps.

## Assert the contract at the boundary

For HTTP tests, return explicit status, headers, and body fixtures from `MockEngine`.
Assert the request method, path, or body when that request is part of the behavior being tested.
Exercise decoding and error mapping through the real client/repository; returning a ready-made domain object bypasses those behaviors.
An interaction assertion is useful for an observable promise such as avoiding duplicate submissions, not for reproducing private call order.

An in-memory fake is suitable for consumers of storage, but cannot prove SQL queries, constraints, or migration data survival.
A migration test should open the previous schema with representative data, migrate, then check the resulting data through the database contract.

Reference: [Ktor client testing](https://ktor.io/docs/client-testing.html).
