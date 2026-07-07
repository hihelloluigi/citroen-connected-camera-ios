import Observation

/// Owns the live routing inputs and recomputes the coordinator's destination whenever any of them
/// changes. Screens and services mutate inputs through this; none of them touch `AppCoordinator`
/// directly, and none make navigation decisions themselves.
@MainActor
@Observable
public final class RoutingController {
    private let coordinator: AppCoordinator
    public private(set) var flags: OnboardingFlags
    private var locationStatus: PermissionStatus = .notDetermined
    private var connectivity = ConnectivitySnapshot()
    private var didJustChangePassword = false

    public init(coordinator: AppCoordinator, flags: OnboardingFlags) {
        self.coordinator = coordinator
        self.flags = flags
        recompute()
    }

    public func update(flags: OnboardingFlags) { self.flags = flags; recompute() }
    public func update(locationStatus: PermissionStatus) { self.locationStatus = locationStatus; recompute() }
    public func ingest(_ connectivity: ConnectivitySnapshot) { self.connectivity = connectivity; recompute() }
    public func markPasswordChanged() { didJustChangePassword = true; recompute() }
    public func clearPasswordChanged() { didJustChangePassword = false; recompute() }

    private func recompute() {
        coordinator.update(with: RoutingInputAssembler.assemble(
            flags: flags, locationStatus: locationStatus,
            connectivity: connectivity, didJustChangePassword: didJustChangePassword))
    }
}
