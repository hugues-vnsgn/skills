---
name: kmp-ktor
description: Use when configuring or debugging a Ktor client in KMP or Android, including platform engines, serialization, bearer refresh, retries, streaming, and repository tests with MockEngine. General test-task selection belongs to kmp-test-seams.
---

# Ktor Client for KMP and Android

Inspect the installed Ktor version, API origins, token storage, client ownership and server contract before changing configuration. Preserve the project's response/error convention. For a concrete factory and auth example, read [client-reference.md](client-reference.md); for WebSocket/SSE work, read [streaming-reference.md](streaming-reference.md).

## Engine and lifetime

Put `ktor-client-core`, content negotiation and serialization dependencies in `commonMain`; keep their versions aligned with the project's Ktor version. Put `ktor-client-okhttp` or the chosen Android engine in `androidMain`, `ktor-client-darwin` in `iosMain`, and `ktor-client-mock` in the test source set. Inject an `HttpClientEngine` into the shared factory so tests run the production plugin configuration.

Create a client at the application's or feature's intended lifetime, reuse it, and close it when its owner ends. An injected engine is caller-owned and must also be closed by its owner. Avoid constructing a client per request. Read the chosen engine's timeout/streaming support before assuming every knob behaves identically.

## Credentials and refresh

Use a dedicated authenticated client restricted to the trusted HTTPS origin, including its port. `sendWithoutRequest` controls preemptive authentication; it does not alone prevent authentication after a foreign server's challenge. Reject requests outside the allowed origin and disable automatic redirects unless a reviewed redirect policy enforces the same boundary. Use a separate unauthenticated client for public or presigned URLs.

Refresh through `markAsRefreshTokenRequest()` inside the request builder, or a dedicated unauthenticated refresh client. Handle refresh rejection without recursively refreshing. Clear stored credentials only on a terminal rejection according to the server contract; preserve cancellation and avoid treating a transient outage as logout. Store tokens using the project's protected credential facility, and redact auth headers and token bodies from logs.

## Serialization and response handling

Choose `encodeDefaults` from the wire contract. For a required constant field, use a targeted `@EncodeDefault` or configure the API's `Json` instance; optional fields may need omission. `ignoreUnknownKeys` and `coerceInputValues` change validation semantics too, so preserve deliberate strictness.

With `expectSuccess = true`, non-2xx responses throw before a later manual error-status branch; successful response checks still run. With `false`, inspect status before decoding a success DTO. Map transport, HTTP and decoding failures at the repository boundary, preserving `CancellationException`. A domain error can retain diagnostic causes internally, but callers should not need Ktor types to select UI behavior.

## Retries

Install `HttpRequestRetry` before `HttpTimeout`. Installation order alone does not enable timeout retries: configure the intended exception/status conditions. Bound attempts and allow automatic replay only for operations whose contract permits it. The reference defaults to GET/HEAD 5xx retries; a POST needs explicit idempotency semantics and a replayable body before opting in. Keep auth refresh separate from the transient failure policy.

## Verify

Use the same factory with `MockEngine` to exercise success, non-2xx, malformed payloads, rejected refresh, cancellation, untrusted origins and replay behavior. Verify native engine behavior on Android/iOS where the change depends on it; a mock cannot prove TLS, OS networking or streaming support. Report the configured origin, client owner, error/retry choices and actual tests run.

Checked 2026-09-24 against Ktor 3.x documentation: [engines](https://ktor.io/docs/client-engines.html), [bearer auth](https://ktor.io/docs/client-bearer-auth.html), [retries](https://ktor.io/docs/client-request-retry.html), [response validation](https://ktor.io/docs/client-response-validation.html), [serialization defaults](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/-json-builder/encode-defaults.html).
