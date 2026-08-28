import CoreDomain

public extension UserFacingError {
	/// The one human-voiced line a screen shows for this failure.
	///
	/// The mapping lives here rather than on the error so CoreDomain stays free of copy — see that
	/// type's own note. This is the direction the dependency has to run: CoreLocalization knows
	/// about the domain, never the other way round.
	var message: String {
		switch self {
		case .notActivePhone: CameraErrorStrings.notActivePhone
		case .denied: CameraErrorStrings.denied
		case .passwordRejected: CameraErrorStrings.passwordRejected
		case .cameraUnreachable: CameraErrorStrings.unreachable
		case .transport: CameraErrorStrings.transport
		case .decoding: CameraErrorStrings.decoding
		case .unexpected(let result): CameraErrorStrings.unexpected(result: result)
		case .unknown: CommonStrings.genericCameraError
		}
	}
}
