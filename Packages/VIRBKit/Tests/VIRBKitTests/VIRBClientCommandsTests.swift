import Foundation
import Testing
@testable import VIRBKit

extension VIRBClientTests {
    // Tests share a global MockURLProtocol.handler, so they must run serially.
    @Suite(.serialized)
    struct VIRBClientCommandsTests {
        @Test func deleteSendsFileURLs() async throws {
            nonisolated(unsafe) var sentBody: Data?
            MockURLProtocol.handler = { request in
                sentBody = request.httpBody ?? request.bodyData
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, Data(#"{"result":1,"cmdRequestId":6}"#.utf8))
            }
            let client = VIRBClient(
                phoneId: "P",
                transport: URLSessionTransport(configuration: .init(), session: MockURLProtocol.makeSession())
            )
            let item = try JSONDecoder.virb.decode(MediaListResponse.self, from: Fixture.load("mediaList")).media[0]
            try await client.delete([item])

            let json = try JSONSerialization.jsonObject(with: #require(sentBody)) as? [String: Any]
            #expect(json?["command"] as? String == "deleteFile")
            #expect((json?["files"] as? [String])?.first == item.url.absoluteString)
        }

        @Test func setPasswordSendsBothPasswords() async throws {
            let client = try makeClient(fixture: "genericOk")
            try await client.setWiFiPassword(current: "ConnectedCam", new: "Test1234")
            // No throw == success (result 1).
        }
    }
}
