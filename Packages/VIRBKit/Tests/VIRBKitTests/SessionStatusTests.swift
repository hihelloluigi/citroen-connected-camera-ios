import Foundation
import Testing
@testable import VIRBKit

@Test func decodesCameraSessionWhenSetupComplete() throws {
    let data = try Fixture.load("connect_setupComplete")
    let session = try ConnectResponse.decode(from: data).session()
    #expect(session.isSetupComplete)
    #expect(session.device.wifiSSID == "ConnectedCAM0690")
    #expect(session.device.deviceId == 3939980690)
}

@Test func decodesSetupIncomplete() throws {
    let data = try Fixture.load("connect_setupIncomplete")
    let session = try ConnectResponse.decode(from: data).session()
    #expect(session.isSetupComplete == false)
    #expect(session.activePhoneId == nil)
}

@Test func sessionThrowsWhenDeviceInfoMissing() throws {
    let data = Data(#"{"result":1,"setupComplete":1,"activePhoneId":null,"deviceInfo":[]}"#.utf8)
    #expect(throws: VIRBError.decoding("missing deviceInfo")) {
        try ConnectResponse.decode(from: data).session()
    }
}

@Test func decodesCameraStatus() throws {
    let data = try Fixture.load("status")
    let status = try StatusResponse.decode(from: data).status()
    #expect(status.numberOfConnections == 1)
    #expect(status.saveVideoDuration == 20)
    #expect(status.needsFormat == false)
    #expect(status.faultDescription == "No Fault")
    #expect(status.gpsLatitude == 45.708865)
}
