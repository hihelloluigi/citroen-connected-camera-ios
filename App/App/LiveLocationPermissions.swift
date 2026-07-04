import CoreLocation
import AppCore

/// Live Location authorization via CoreLocation. `@MainActor` because `CLLocationManager` must be used
/// on the main thread; the async protocol lets callers await across the hop. Verified on device — the
/// authorization prompt and status changes don't occur in the CLI test environment.
@MainActor
final class LiveLocationPermissions: NSObject, PermissionsService, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var pending: CheckedContinuation<PermissionStatus, Never>?

    func locationStatus() async -> PermissionStatus { Self.map(manager.authorizationStatus) }

    func requestLocation() async -> PermissionStatus {
        let current = manager.authorizationStatus
        guard current == .notDetermined else { return Self.map(current) }
        manager.delegate = self
        return await withCheckedContinuation { continuation in
            pending = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        MainActor.assumeIsolated {
            let status = self.manager.authorizationStatus
            guard status != .notDetermined, let continuation = pending else { return }
            pending = nil
            continuation.resume(returning: Self.map(status))
        }
    }

    private static func map(_ status: CLAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorizedWhenInUse, .authorizedAlways: return .granted
        default: return .denied
        }
    }
}
