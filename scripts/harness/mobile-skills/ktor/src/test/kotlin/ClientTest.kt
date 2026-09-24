import io.ktor.client.*
import io.ktor.client.engine.mock.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.coroutines.*
import kotlinx.serialization.json.Json
import kotlin.test.*

class Store : TokenStore {
 var tokens: SessionTokens? = SessionTokens("expired", "refresh")
 var saves = 0
 var clears = 0
 override suspend fun load() = tokens
 override suspend fun save(tokens: SessionTokens) { this.tokens = tokens; saves++ }
 override suspend fun clear() { tokens = null; clears++ }
}
class ClientTest {
 private val origin = "https://api.example.com"
 @Test fun expiredCredentialsRefreshAndReplay() = runBlocking {
  val store = Store(); val seen = mutableListOf<String>()
  val engine = MockEngine { request ->
   seen += "${request.method.value} ${request.url.encodedPath} ${request.headers[HttpHeaders.Authorization]}"
   when {
    request.url.encodedPath == "/auth/refresh" -> respond("""{"accessToken":"fresh","refreshToken":"new-refresh"}""", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
    request.headers[HttpHeaders.Authorization] == "Bearer fresh" -> respond("ok")
    else -> respond("expired", HttpStatusCode.Unauthorized, headersOf(HttpHeaders.WWWAuthenticate, "Bearer"))
   }
  }
  val client = createApiClient(engine, origin, store, Json)
  try {
   assertEquals("ok", client.get("$origin/orders").bodyAsText())
   assertEquals(3, seen.size); assertEquals(1, store.saves)
   assertEquals("fresh", store.tokens?.accessToken); println("refresh sequence: $seen")
  } finally { client.close(); engine.close() }
 }
 @Test fun failedCreateOrderIsNotRetried() = runBlocking {
  var calls = 0; val engine = MockEngine { calls++; respond("unavailable", HttpStatusCode.ServiceUnavailable) }
  val client = createApiClient(engine, origin, Store(), Json)
  try { assertEquals(HttpStatusCode.ServiceUnavailable, client.post("$origin/orders") { setBody("order") }.status); assertEquals(1,calls) }
  finally { client.close(); engine.close() }
 }
 @Test fun cancellationDuringRefreshPreservesCredentials() = runBlocking {
  val store = Store(); val refreshing = CompletableDeferred<Unit>()
  val engine = MockEngine { request ->
   if (request.url.encodedPath == "/auth/refresh") { refreshing.complete(Unit); awaitCancellation() }
   else respond("expired", HttpStatusCode.Unauthorized, headersOf(HttpHeaders.WWWAuthenticate, "Bearer"))
  }
  val client = createApiClient(engine, origin, store, Json)
  try {
   val request = async { client.get("$origin/orders") }
   withTimeout(5_000) { refreshing.await() }; request.cancel()
   assertFailsWith<CancellationException> { request.await() }
   assertEquals("expired",store.tokens?.accessToken); assertEquals(0,store.clears); assertEquals(0,store.saves)
  } finally { client.close(); engine.close() }
 }
 @Test fun rejectedRefreshClearsStoreAndTerminates() = runBlocking {
  var calls = 0; val store = Store()
  val engine = MockEngine { request -> calls++; println("rejection request: ${request.method} ${request.url} ${request.headers[HttpHeaders.Authorization]}"); respond("rejected", HttpStatusCode.Unauthorized, headersOf(HttpHeaders.WWWAuthenticate, "Bearer")) }
  val client = createApiClient(engine, origin, store, Json)
  try { assertEquals(HttpStatusCode.Unauthorized,client.get("$origin/orders").status); assertEquals(3,calls); assertNull(store.tokens); assertEquals(1,store.clears) }
  finally { client.close(); engine.close() }
 }
 @Test fun foreignOriginBlockedBeforeEngine() = runBlocking {
  var calls = 0; val engine = MockEngine { calls++; respond("unexpected") }
  val client = createApiClient(engine, origin, Store(), Json)
  try { assertFailsWith<IllegalArgumentException> { client.get("https://files.example.net/file?signature=abc") }; assertEquals(0,calls) }
  finally { client.close(); engine.close() }
 }
 @Test fun downloadUsesSeparateUnauthenticatedClient() = runBlocking {
  val engine = MockEngine { request ->
   assertEquals("files.example.net",request.url.host); assertNull(request.headers[HttpHeaders.Authorization]); assertEquals("abc",request.url.parameters["signature"]); respond("file bytes")
  }
  val client = createDownloadClient(engine)
  try { assertEquals("file bytes",client.get("https://files.example.net/file?signature=abc").bodyAsText()) }
  finally { client.close(); engine.close() }
 }
 @Test fun foreignSchemeAndPortBlocked() = runBlocking {
  var calls = 0; val engine = MockEngine { calls++; respond("unexpected") }
  val client = createApiClient(engine, origin, Store(), Json)
  try {
   for (url in listOf("http://api.example.com/orders", "https://api.example.com:444/orders")) {
    assertFailsWith<IllegalArgumentException> { client.get(url) }
   }
   assertEquals(0,calls)
  } finally { client.close(); engine.close() }
 }
 @Test fun redirectIsNotFollowed() = runBlocking {
  var calls = 0; val engine = MockEngine { calls++; respond("redirect", HttpStatusCode.Found, headersOf(HttpHeaders.Location,"https://files.example.net/file")) }
  val client = createApiClient(engine, origin, Store(), Json)
  try { assertEquals(HttpStatusCode.Found, client.get("$origin/orders").status); assertEquals(1,calls) }
  finally { client.close(); engine.close() }
 }

 @Test fun readServerErrorsHaveBoundedRetries() = runBlocking {
  var calls = 0
  val engine = MockEngine { calls++; respond("unavailable", HttpStatusCode.ServiceUnavailable) }
  val client = createApiClient(engine, origin, Store(), Json)
  try {
   withTimeout(20_000) { assertEquals(HttpStatusCode.ServiceUnavailable, client.get("$origin/orders").status) }
   assertEquals(3, calls)
  } finally { client.close(); engine.close() }
 }

}
