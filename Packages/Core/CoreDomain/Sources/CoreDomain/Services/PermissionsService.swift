/// Where a permission stands. `notDetermined` means the OS prompt hasn't been answered yet.
public enum PermissionStatus: Sendable, Equatable {
	case notDetermined, granted, denied
}

/// Location authorization (needed later to read the Wi-Fi network name). Local Network has no query
/// API on iOS, so it is not modeled here — it's inferred from reachability and the onboarding flag.
public protocol PermissionsService: Sendable {
	func locationStatus() async -> PermissionStatus
	func requestLocation() async -> PermissionStatus
}
