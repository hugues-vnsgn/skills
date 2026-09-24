# Authenticated client factory

Ktor 3.x example, checked against official [custom plugins](https://ktor.io/docs/client-custom-plugins.html), [bearer auth](https://ktor.io/docs/client-bearer-auth.html) and [retry](https://ktor.io/docs/client-request-retry.html) docs on 2026-09-24. Adapt the token DTOs and refresh rejection statuses to the server contract. The caller supplies a protected, concurrency-safe token store and owns the engine.

This client accepts only its API origin. Use an unauthenticated client for third-party downloads. Redirects are disabled because an origin predicate for preemptive bearer auth alone does not secure every redirect or challenge path.

```kotlin
import io.ktor.client.HttpClient
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.plugins.HttpRequestRetry
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.api.createClientPlugin
import io.ktor.client.plugins.api.SendingRequest
import io.ktor.client.plugins.auth.Auth
import io.ktor.client.plugins.auth.providers.BearerTokens
import io.ktor.client.plugins.auth.providers.bearer
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.call.body
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.json
import kotlinx.io.IOException
import kotlinx.coroutines.CancellationException
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

@Serializable
data class SessionTokens(val accessToken: String, val refreshToken: String)
@Serializable
data class RefreshBody(val refreshToken: String)

interface TokenStore {
    suspend fun load(): SessionTokens?
    suspend fun save(tokens: SessionTokens)
    suspend fun clear()
}

fun createApiClient(
    engine: HttpClientEngine,
    apiOrigin: String,
    tokenStore: TokenStore,
    wireJson: Json,
): HttpClient {
    val origin = Url(apiOrigin)
    require(origin.protocol == URLProtocol.HTTPS)
    require(origin.encodedPath in setOf("", "/") && origin.parameters.isEmpty())
    require(origin.user.isNullOrEmpty() && origin.password.isNullOrEmpty() && origin.fragment.isEmpty())
    fun trusted(url: Url) = url.protocol == origin.protocol &&
        url.host == origin.host && url.port == origin.port

    val originGuard = createClientPlugin("ApiOriginGuard") {
        on(SendingRequest) { request, _ ->
            require(trusted(request.url.build())) { "Request outside configured API origin" }
        }
    }
    return HttpClient(engine) {
        followRedirects = false
        expectSuccess = false
        install(originGuard)
        install(ContentNegotiation) { json(wireJson) }
        install(HttpRequestRetry) {
            maxRetries = 2
            retryIf { request, response ->
                request.method in setOf(HttpMethod.Get, HttpMethod.Head) &&
                    response.status.value in 500..599
            }
            retryOnExceptionIf { _, _ -> false }
            exponentialDelay()
        }
        install(HttpTimeout) { requestTimeoutMillis = 30_000 }
        install(Auth) {
            bearer {
                loadTokens { tokenStore.load()?.let { BearerTokens(it.accessToken, it.refreshToken) } }
                sendWithoutRequest { trusted(it.url.build()) }
                refreshTokens {
                    val refresh = oldTokens?.refreshToken ?: return@refreshTokens null
                    try {
                        val response = client.post(URLBuilder(origin).apply { encodedPath = "/auth/refresh" }.build()) {
                            markAsRefreshTokenRequest()
                            contentType(ContentType.Application.Json)
                            setBody(RefreshBody(refresh))
                        }
                        when {
                            response.status.isSuccess() -> {
                                val tokens = response.body<SessionTokens>()
                                tokenStore.save(tokens)
                                BearerTokens(tokens.accessToken, tokens.refreshToken)
                            }
                            response.status.value in setOf(400, 401) -> {
                                tokenStore.clear()
                                null
                            }
                            else -> null
                        }
                    } catch (cancelled: CancellationException) {
                        throw cancelled
                    } catch (_: IOException) {
                        null
                    } catch (_: SerializationException) {
                        null
                    }
                }
            }
        }
    }
}
```

On explicit logout or account replacement, clear the bearer provider's cached token as well as persistent storage, or replace the session-owned client. Coordinate logout with an in-flight refresh so a late response cannot restore a logged-out session. Ktor's [token caching guidance](https://ktor.io/docs/client-auth.html#token-caching) describes the provider API for the installed version.

Callers use absolute URLs on the configured origin. A base path can be configured separately; it is not an authorization boundary. The refresh path and 400/401 terminal behavior above are example API contracts, not universal OAuth rules.

## Engine bindings and tests

Construct the factory with `OkHttp.create()` on Android and `Darwin.create()` on iOS, importing the matching engine dependency in each platform source set. Preserve an existing supported engine unless the task needs different capabilities. Close both client and caller-owned engine at their chosen lifetime.

For common tests, construct `MockEngine` and call this factory with an in-memory store. Assert requests and results, including that foreign-origin requests never reach the engine, a rejected refresh terminates, and a POST receiving 5xx is sent only once. For retry tests inject or control the delay rather than waiting through production backoff. See [MockEngine](https://ktor.io/docs/client-testing.html).
