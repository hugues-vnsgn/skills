// Original teaching scaffolds. Add to an XCTest target; split production types
// into the app module and add @testable import YourModule in a real project.
import Foundation
import XCTest
import Combine

protocol NameStore {
    func read() throws -> String?
    func write(_ name: String) throws
}

struct DummyNameStore: NameStore {
    func read() throws -> String? { XCTFail("Unexpected dummy read"); return nil }
    func write(_ name: String) throws { XCTFail("Unexpected dummy write") }
}

struct NameStoreStub: NameStore {
    let result: Result<String?, Error>
    func read() throws -> String? { try result.get() }
    func write(_ name: String) throws { XCTFail("Unconfigured write") }
}

final class NameStoreSpy: NameStore {
    private(set) var writes: [String] = []
    func read() throws -> String? { nil }
    func write(_ name: String) throws { writes.append(name) }
}

final class NameStoreMock: NameStore {
    private let expected: [String]
    private var actual: [String] = []
    init(expectedWrites: [String]) { expected = expectedWrites }
    func read() throws -> String? { XCTFail("Unexpected read"); return nil }
    func write(_ name: String) throws { actual.append(name) }
    func verify(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual, expected, file: file, line: line)
    }
}

final class InMemoryNameStore: NameStore {
    private var name: String?
    func read() throws -> String? { name }
    func write(_ name: String) throws { self.name = name }
}

struct RenameProfile {
    let store: any NameStore
    func rename(to name: String) throws {
        try store.write(name.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

final class RenameProfileTests: XCTestCase {
    func testRename_trimsWhitespaceBeforeSaving() throws {
        let store = NameStoreSpy() // Fresh dependencies for each test.
        let sut = RenameProfile(store: store)
        try sut.rename(to: "  Ada  ")
        XCTAssertEqual(store.writes, ["Ada"])
    }

    func testRename_satisfiesConfiguredInteraction() throws {
        let store = NameStoreMock(expectedWrites: ["Ada"])
        defer { store.verify() } // Missing calls must also fail verification.
        try RenameProfile(store: store).rename(to: "Ada")
    }

    func testRename_persistsValue() throws {
        let store = InMemoryNameStore()
        try RenameProfile(store: store).rename(to: "Ada")
        XCTAssertEqual(try store.read(), "Ada")
    }
}

// A controlled callback seam. Single-executor helper; not thread safe.
protocol CallbackLoader {
    func load(_ completion: @escaping (Result<String, Error>) -> Void)
}
final class ControlledLoader: CallbackLoader {
    private var completion: ((Result<String, Error>) -> Void)?
    func load(_ completion: @escaping (Result<String, Error>) -> Void) {
        precondition(self.completion == nil)
        self.completion = completion
    }
    func complete(with result: Result<String, Error>) {
        let callback = completion
        completion = nil
        precondition(callback != nil)
        callback?(result)
    }
}
struct GreetingService {
    let loader: any CallbackLoader
    func greeting(_ completion: @escaping (Result<String, Error>) -> Void) {
        loader.load { completion($0.map { "Hello, \($0)" }) }
    }
}
final class CallbackTests: XCTestCase {
    func testGreeting_mapsLoadedName() async {
        let loader = ControlledLoader()
        let sut = GreetingService(loader: loader)
        let completed = expectation(description: "Greeting delivered")
        completed.assertForOverFulfill = true
        sut.greeting { result in
            XCTAssertEqual(try? result.get(), "Hello, Ada")
            completed.fulfill()
        }
        loader.complete(with: .success("Ada"))
        await fulfillment(of: [completed], timeout: 1)
    }
}

protocol HTTPTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
struct SessionTransport: HTTPTransport {
    let session: URLSession
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, http)
    }
}
struct HTTPStub: HTTPTransport {
    let body: Data
    let status: Int
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: request.url!, statusCode: status,
                                       httpVersion: nil, headerFields: nil)!
        return (body, response)
    }
}
struct Profile: Decodable, Equatable { let name: String }
enum ProfileError: Error, Equatable { case status(Int) }
struct ProfileClient {
    let transport: any HTTPTransport
    let url: URL
    func load() async throws -> Profile {
        let (data, response) = try await transport.data(for: URLRequest(url: url))
        guard (200..<300).contains(response.statusCode) else {
            throw ProfileError.status(response.statusCode)
        }
        return try JSONDecoder().decode(Profile.self, from: data)
    }
}

// Immutable fixture routing avoids the common static mutable handler race.
// Synchronous startLoading only: this helper does NOT model cancellation.
final class FixtureURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let url = request.url,
              url.absoluteString == "https://fixture.invalid/profile",
              request.httpMethod == "GET" else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }
        let response = HTTPURLResponse(url: url, statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(#"{"name":"Ada"}"#.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() { }
}

final class ProfileClientTests: XCTestCase {
    func testLoad_decodesSuccessfulResponse() async throws {
        let sut = ProfileClient(
            transport: HTTPStub(body: Data(#"{"name":"Ada"}"#.utf8), status: 200),
            url: URL(string: "https://fixture.invalid/profile")!)
        let actual = try await sut.load()
        XCTAssertEqual(actual, Profile(name: "Ada"))
    }
    func testLoad_rejectsServerError() async throws {
        let sut = ProfileClient(transport: HTTPStub(body: Data(), status: 503),
                                url: URL(string: "https://fixture.invalid/profile")!)
        do {
            _ = try await sut.load()
            XCTFail("Expected HTTP failure")
        } catch let error as ProfileError {
            XCTAssertEqual(error, .status(503))
        }
    }
    func testLoad_integratesWithURLSessionWithoutNetwork() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [FixtureURLProtocol.self]
        let session = URLSession(configuration: config)
        defer { session.invalidateAndCancel() }
        let sut = ProfileClient(transport: SessionTransport(session: session),
                                url: URL(string: "https://fixture.invalid/profile")!)
        let actual = try await sut.load()
        XCTAssertEqual(actual, Profile(name: "Ada"))
    }
}

struct GreetingPublisher {
    func transform(_ names: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        names.map { "Hello, \($0)" }.eraseToAnyPublisher()
    }
}
final class PublisherTests: XCTestCase {
    func testGreeting_emitsMappedValueAndCompletes() async {
        let input = PassthroughSubject<String, Never>()
        let value = expectation(description: "Mapped value")
        let finished = expectation(description: "Publisher completed")
        value.assertForOverFulfill = true
        let token = GreetingPublisher().transform(input.eraseToAnyPublisher()).sink(
            receiveCompletion: { _ in finished.fulfill() },
            receiveValue: { actual in
                XCTAssertEqual(actual, "Hello, Ada")
                value.fulfill()
            })
        defer { token.cancel() }
        input.send("Ada")
        input.send(completion: .finished)
        await fulfillment(of: [value, finished], timeout: 1, enforceOrder: true)
    }
}
