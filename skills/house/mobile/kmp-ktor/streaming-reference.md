# Streaming clients

Checked 2026-09-24: [Ktor WebSockets](https://ktor.io/docs/client-websockets.html), [Ktor SSE](https://ktor.io/docs/client-server-sent-events.html).

Choose the transport from the server contract. SSE is one-way event delivery; WebSockets support bidirectional messages. Verify engine support before configuration, especially Android engines' ping settings.

Use `KotlinxWebsocketSerializationConverter(wireJson)` with the same deliberate JSON policy used by HTTP. SSE delivers events whose data you decode according to the event schema; installing a WebSocket converter does not deserialize SSE automatically.

Run collection in the consumer's coroutine lifetime and let cancellation close the session. Configure finite reconnect/backoff behavior where needed; preserve event IDs or resume cursors if the protocol supports them. Reconnection does not prove exactly-once delivery, so define deduplication and outbound replay semantics before resending mutations.

Use a dedicated authenticated connection only for a trusted origin. Match schemes appropriately: HTTP uses HTTPS and a WebSocket handshake uses WSS. The HTTPS-only factory in `client-reference.md` deliberately rejects WSS, so create a transport-specific origin policy rather than weakening that factory to accept arbitrary schemes or hosts.

Verify disconnect, cancellation, malformed event and reconnect behavior with the actual selected engine. A mock of an HTTP response does not prove the streaming connection behaves correctly on iOS.
