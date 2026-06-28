import Foundation
import Testing
@testable import VIRBKit

private func makeClient(fixture: String) throws -> VIRBClient {
    let data = try Fixture.load(fixture)
    MockURLProtocol.handler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, data)
    }
    let transport = URLSessionTransport(
        configuration: .init(),
        session: MockURLProtocol.makeSession()
    )
    return VIRBClient(phoneId: "TEST-PHONE", transport: transport)
}

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
}
