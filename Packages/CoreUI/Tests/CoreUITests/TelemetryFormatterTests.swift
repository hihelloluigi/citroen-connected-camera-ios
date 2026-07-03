import Testing
@testable import CoreUI

@Test func formatsCoordinateToFourDecimals() {
    #expect(TelemetryFormatter.coordinate(lat: 45.464100, lon: 9.189550) == "45.4641, 9.1896")
}

@Test func formatsByteCountToHumanReadable() {
    // ByteCountFormatter uses non-breaking spaces; assert the digits and unit are present.
    let text = TelemetryFormatter.bytes(167_772_160)
    #expect(text.contains("MB"))
    #expect(text.contains("160") || text.contains("167"))
}
