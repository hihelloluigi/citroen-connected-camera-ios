import Foundation
import Testing
@testable import VIRBKit

/// Builds a `VIRBClient` whose transport is backed by a canned JSON fixture.
///
/// - Parameter fixture: The fixture file name, without the `.json` extension.
/// - Returns: A fully initialised `VIRBClient` that will replay the fixture for every request.
internal func makeClient(fixture: String) throws -> VIRBClient {
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
