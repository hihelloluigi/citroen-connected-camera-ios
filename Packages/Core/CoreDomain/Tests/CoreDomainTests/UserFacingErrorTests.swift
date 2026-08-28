import CoreCamera
import Testing
@testable import CoreDomain

@Test func mapsKnownCameraErrorToItsMessage() {
	#expect(UserFacingError(VIRBError.cameraUnreachable).message == VIRBError.cameraUnreachable.userMessage)
}

@Test func mapsUnknownErrorToGenericMessage() {
	struct Other: Error {}
	#expect(UserFacingError(Other()).message == "Something went wrong talking to the camera. Please try again.")
}
