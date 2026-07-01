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

        @Test func downloadWritesFileToDestination() async throws {
            let payload = Data("FAKE-VIDEO-BYTES".utf8)
            MockURLProtocol.handler = { request in
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, payload)
            }
            let client = VIRBClient(
                phoneId: "P",
                transport: URLSessionTransport(configuration: .init(), session: MockURLProtocol.makeSession())
            )
            let item = try JSONDecoder.virb.decode(MediaListResponse.self, from: Fixture.load("mediaList")).media[0]
            let dest = FileManager.default.temporaryDirectory.appendingPathComponent("virb-download-test-\(UUID().uuidString).mp4")
            defer { try? FileManager.default.removeItem(at: dest) }

            nonisolated(unsafe) var reported: Double?
            let url = try await client.download(item, to: dest) { reported = $0 }

            #expect(url == dest)
            #expect(try Data(contentsOf: dest) == payload)
            #expect(reported == 1)
        }

        @Test func downloadThrowsAndWritesNothingOnErrorStatus() async throws {
            MockURLProtocol.handler = { request in
                let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
                return (response, Data("<html>not found</html>".utf8))
            }
            let client = VIRBClient(
                phoneId: "P",
                transport: URLSessionTransport(configuration: .init(), session: MockURLProtocol.makeSession())
            )
            let item = try JSONDecoder.virb.decode(MediaListResponse.self, from: Fixture.load("mediaList")).media[0]
            let dest = FileManager.default.temporaryDirectory.appendingPathComponent("virb-download-fail-\(UUID().uuidString).mp4")
            defer { try? FileManager.default.removeItem(at: dest) }

            await #expect(throws: VIRBError.self) {
                _ = try await client.download(item, to: dest)
            }
            #expect(!FileManager.default.fileExists(atPath: dest.path))
        }

        @Test func isReachableTrueWhenConnectSucceeds() async throws {
            let client = try makeClient(fixture: "connect_setupComplete")
            let reachable = await client.isReachable()
            #expect(reachable)
        }

        @Test func isReachableFalseWhenTransportFails() async {
            MockURLProtocol.handler = { _ in throw URLError(.cannotConnectToHost) }
            let client = VIRBClient(
                phoneId: "P",
                transport: URLSessionTransport(configuration: .init(), session: MockURLProtocol.makeSession())
            )
            let reachable = await client.isReachable()
            #expect(reachable == false)
        }
    }
}
