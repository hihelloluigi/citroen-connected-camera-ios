import CoreDomain

/// Scriptable `PermissionsService` for view-model tests.
final class MockPermissionsService: PermissionsService, @unchecked Sendable {
	// MARK: - Stored Properties

	var status: PermissionStatus
	/// The status `requestLocation()` resolves to (defaults to the current `status`).
	var requestResult: PermissionStatus?
	private(set) var requestCount = 0

	// MARK: - Init

	init(status: PermissionStatus = .notDetermined) {
		self.status = status
	}

	// MARK: - PermissionsService

	func locationStatus() async -> PermissionStatus { status }

	func requestLocation() async -> PermissionStatus {
		requestCount += 1

		let result = requestResult ?? status
		status = result

		return result
	}
}
