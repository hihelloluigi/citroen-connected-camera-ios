import AppCore

/// Scriptable PermissionsService for view-model tests.
final class MockPermissionsService: PermissionsService, @unchecked Sendable {
	var status: PermissionStatus
	private(set) var requestCount = 0
	/// The status `requestLocation()` resolves to (defaults to the current `status`).
	var requestResult: PermissionStatus?

	init(status: PermissionStatus = .notDetermined) { self.status = status }

	func locationStatus() async -> PermissionStatus { status }
	func requestLocation() async -> PermissionStatus {
		requestCount += 1
		let result = requestResult ?? status
		status = result
		return result
	}
}
