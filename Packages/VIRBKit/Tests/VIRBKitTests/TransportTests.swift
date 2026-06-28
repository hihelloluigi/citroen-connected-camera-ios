import Foundation
import Testing
@testable import VIRBKit

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
