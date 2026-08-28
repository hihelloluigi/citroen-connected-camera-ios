import Foundation

/// One human-voiced line per camera failure.
///
/// These live here rather than on `VIRBError` itself: CoreCamera is a transport module, and a
/// transport that ships user-facing copy is a transport that has to be localized. CoreDomain's
/// `UserFacingError` is what maps an error to one of these.
public enum CameraErrorStrings {
	public static let notActivePhone = String(localized: "camera_error.not_active_phone", bundle: .module)
	public static let denied = String(localized: "camera_error.denied", bundle: .module)
	public static let passwordRejected = String(localized: "camera_error.password_rejected", bundle: .module)
	public static let unreachable = String(localized: "camera_error.unreachable", bundle: .module)
	public static let transport = String(localized: "camera_error.transport", bundle: .module)
	public static let decoding = String(localized: "camera_error.decoding", bundle: .module)

	/// A camera result code with no known meaning, surfaced so a bug report can name it.
	public static func unexpected(result: Int) -> String {
		String(format: String(localized: "camera_error.unexpected", bundle: .module), result)
	}
}
