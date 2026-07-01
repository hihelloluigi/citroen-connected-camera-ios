import Foundation
import Testing
@testable import VIRBKit

extension VIRBClientTests {
    // URLSessionTransport uses MockURLProtocol.handler — must run serially with other client suites.
    @Suite(.serialized)
    struct TransportTests {
        @Test func transportPostsBodyAndReturnsData() async throws {
            MockURLProtocol.handler = { request in
                #expect(request.url?.path == "/virb")
                #expect(request.httpMethod == "POST")
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, Data(#"{"result":1,"cmdRequestId":6}"#.utf8))
            }
            let config = VIRBConfiguration(baseURL: URL(string: "http://192.168.0.1")!, requestTimeout: 8)
            let transport = URLSessionTransport(configuration: config, session: MockURLProtocol.makeSession())

            let data = try await transport.post(path: "/virb", body: Data("{}".utf8))
            #expect(!data.isEmpty)
        }

        @Test func mapsCannotConnectToCameraUnreachable() async {
            MockURLProtocol.handler = { _ in throw URLError(.cannotConnectToHost) }
            let transport = URLSessionTransport(configuration: .init(), session: MockURLProtocol.makeSession())
            await #expect(throws: VIRBError.cameraUnreachable) {
                try await transport.post(path: "/virb", body: Data())
            }
        }

        @Test func mapsOtherURLErrorToTransportError() async {
            MockURLProtocol.handler = { _ in throw URLError(.networkConnectionLost) }
            let transport = URLSessionTransport(configuration: .init(), session: MockURLProtocol.makeSession())
            do {
                _ = try await transport.post(path: "/virb", body: Data())
                Issue.record("expected post to throw")
            } catch let error as VIRBError {
                guard case .transport = error else {
                    Issue.record("expected .transport, got \(error)"); return
                }
            } catch {
                Issue.record("expected VIRBError, got \(error)")
            }
        }
    }
}
