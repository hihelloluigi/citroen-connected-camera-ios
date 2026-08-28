import CoreCamera
import Testing
@testable import CoreDomain

@Test func mapsEveryKnownCameraErrorToItsOwnCase() {
	#expect(UserFacingError(VIRBError.notActivePhone) == .notActivePhone)
	#expect(UserFacingError(VIRBError.denied) == .denied)
	#expect(UserFacingError(VIRBError.passwordRejected) == .passwordRejected)
	#expect(UserFacingError(VIRBError.cameraUnreachable) == .cameraUnreachable)
	#expect(UserFacingError(VIRBError.transport("boom")) == .transport)
	#expect(UserFacingError(VIRBError.decoding("bad json")) == .decoding)
	#expect(UserFacingError(VIRBError.unexpected(result: 11)) == .unexpected(result: 11))
}

@Test func collapsesAnythingElseToUnknown() {
	struct Other: Error {}
	// No raw URLError or decoding noise reaches a screen — everything unrecognised is one case.
	#expect(UserFacingError(Other()) == .unknown)
}

@Test func carriesTheCameraResultCodeThrough() {
	// The code is the one detail worth surfacing on an unknown failure, so a bug report can name it.
	guard case .unexpected(let result) = UserFacingError(VIRBError.unexpected(result: 42)) else {
		Issue.record("expected .unexpected")
		return
	}
	#expect(result == 42)
}
