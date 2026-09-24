import io.ktor.client.HttpClient
import io.ktor.client.engine.HttpClientEngine

fun createDownloadClient(engine: HttpClientEngine): HttpClient = HttpClient(engine) {
    followRedirects = false
    expectSuccess = true
}
