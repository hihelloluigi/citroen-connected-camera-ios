import AppCore
import Observation

@MainActor
@Observable
final class ReconnectViewModel {
	private let connectivity: ConnectivityMonitor
	private let actions: OnboardingActions

	init(connectivity: ConnectivityMonitor, actions: OnboardingActions) {
		self.connectivity = connectivity
		self.actions = actions
	}

	/// Polls every 2s. Releases the Reconnect pin only once the camera is back AND reads setup-complete
	/// (a password change completes setup, so the returning camera reports `setupComplete == 1`); gating
	/// on that avoids a transient bounce to Set-password. Then applies the snapshot, which finalizes
	/// onboarding and routes to the Gallery. Runs until SwiftUI cancels the enclosing `.task` on the
	/// route change.
	func monitor() async {
		while !Task.isCancelled {
			await connectivity.refresh()
			let snapshot = connectivity.snapshot
			if snapshot.isReachable, snapshot.setupComplete == true { actions.finishReconnect() }
			await actions.applyConnectivity(snapshot)
			try? await Task.sleep(for: .seconds(2))
		}
	}
}
