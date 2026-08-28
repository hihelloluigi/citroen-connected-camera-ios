import CoreConnectivity
import CoreDomain
import FeatureOnboarding
import Observation

/// Owns the live routing inputs and recomputes the root destination whenever any of them changes.
///
/// This is also where `FeatureOnboarding`'s navigation actions land: the flow reports facts it has
/// established — flags persisted, password changed, camera back, a fresh reachability reading — and
/// this folds each one into the input that drives `RootCoordinator`. The feature never touches the
/// coordinator, and nothing below here makes a navigation decision.
@MainActor
@Observable
final class RoutingController {
	private let coordinator: RootCoordinator
	private(set) var flags: OnboardingFlags
	private var locationStatus: PermissionStatus = .notDetermined
	private var connectivity = ConnectivitySnapshot()
	private var didJustChangePassword = false

	init(coordinator: RootCoordinator, flags: OnboardingFlags) {
		self.coordinator = coordinator
		self.flags = flags
		recompute()
	}

	/// Handles one navigation action from the onboarding flow.
	func handle(_ action: OnboardingNavigationAction) {
		switch action {
		case .flagsUpdated(let flags):
			self.flags = flags
		case .passwordChanged:
			didJustChangePassword = true
		case .reconnectFinished:
			didJustChangePassword = false
		case .connectivityUpdated(let snapshot):
			connectivity = snapshot
		}
		recompute()
	}

	func update(locationStatus: PermissionStatus) {
		self.locationStatus = locationStatus
		recompute()
	}

	func ingest(_ connectivity: ConnectivitySnapshot) {
		self.connectivity = connectivity
		recompute()
	}

	private func recompute() {
		coordinator.update(with: RoutingInputAssembler.assemble(
			flags: flags, locationStatus: locationStatus,
			connectivity: connectivity, didJustChangePassword: didJustChangePassword))
	}
}
