import Testing
@testable import VIRBKit

@Test func mapsResultCodesToErrors() {
    #expect(VIRBError.map(result: 1) == nil)
    #expect(VIRBError.map(result: 9) == .notActivePhone)
    #expect(VIRBError.map(result: 3) == .denied)
    #expect(VIRBError.map(result: 11) == .unexpected(result: 11))
}

@Test func errorsHaveUserMessages() {
    #expect(!VIRBError.cameraUnreachable.userMessage.isEmpty)
}
