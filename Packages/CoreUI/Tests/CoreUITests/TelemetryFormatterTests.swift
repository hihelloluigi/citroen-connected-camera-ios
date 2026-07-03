import Testing
@testable import CoreUI

@Test func formatsCoordinateToFourDecimals() {
    #expect(TelemetryFormatter.coordinate(lat: 45.708865, lon: 9.696590) == "45.7089, 9.6966")
}

@Test func formatsByteCountToHumanReadable() {
    // ByteCountFormatter uses non-breaking spaces; assert the digits and unit are present.
    let text = TelemetryFormatter.bytes(167_772_160)
    #expect(text.contains("MB"))
    #expect(text.contains("160") || text.contains("167"))
}
