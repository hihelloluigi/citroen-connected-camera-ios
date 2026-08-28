import Testing
@testable import CoreCamera

@Test func mapsResultCodesToErrors() {
	#expect(VIRBError.map(result: 1) == nil)
	#expect(VIRBError.map(result: 9) == .notActivePhone)
	#expect(VIRBError.map(result: 3) == .denied)
	#expect(VIRBError.map(result: 11) == .unexpected(result: 11))
}

@Test func transportAndDecodingCarryTheirUnderlyingDetail() {
	// The associated strings are diagnostics, not copy — CoreLocalization words these for the user.
	#expect(VIRBError.transport("timed out") == .transport("timed out"))
	#expect(VIRBError.decoding("missing deviceInfo") != .decoding("other"))
}
