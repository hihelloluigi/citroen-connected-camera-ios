import Foundation
import Testing
@testable import VIRBKit

extension VIRBClientTests {
    // Tests share a global MockURLProtocol.handler, so they must run serially.
    @Suite(.serialized)
    struct VIRBClientConnectTests {
        @Test func connectReturnsSession() async throws {
            let client = try makeClient(fixture: "connect_setupComplete")
            let session = try await client.connect()
            #expect(session.isSetupComplete)
            #expect(session.device.wifiSSID == "ConnectedCAM0690")
        }

        @Test func statusReturnsCameraStatus() async throws {
            let client = try makeClient(fixture: "status")
            let status = try await client.status()
            #expect(status.saveVideoDuration == 20)
        }

        @Test func connectDoesNotThrowWhenSetupIncomplete() async throws {
            let client = try makeClient(fixture: "connect_setupIncomplete")
            let session = try await client.connect()
            #expect(!session.isSetupComplete)
        }
    }
}
