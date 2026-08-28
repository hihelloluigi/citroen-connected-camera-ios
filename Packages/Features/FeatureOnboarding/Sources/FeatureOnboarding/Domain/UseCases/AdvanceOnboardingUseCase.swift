import CoreCamera
import CoreConnectivity
import CoreDomain
import CoreNavigation

/// Every way the onboarding flow moves forward: the flag mutations a tap records, the camera-driven
/// password change, and the connectivity readings that finish the flow.
///
/// A protocol rather than a concrete type because the screens' ViewModels depend on it, and a
/// ViewModel's dependencies are always protocols — that is what lets each screen be tested without
/// a camera, a Keychain or a `UserDefaults`.

@MainActor
public protocol AdvanceOnboardingUseCaseProtocol {
	func markGetStarted()
	func markLocalNetworkResolved()
	func markLocationResolved()
	func changePassword(current: String, new: String) async throws
	func finishReconnect()
	func applyConnectivity(_ snapshot: ConnectivitySnapshot) async
	func finishOnboarding() async
}

/// The live `AdvanceOnboardingUseCaseProtocol`.
///
/// Persists each step's flags so a tap survives relaunch, and reports what changed through
/// `onAction`. It deliberately knows nothing about where any of that routes: the app shell holds
/// the handler and folds these facts back into the routing input.
@MainActor
public final class AdvanceOnboardingUseCase: AdvanceOnboardingUseCaseProtocol {
	private let store: any OnboardingFlagsStore
	private let camera: any VIRBClientProtocol
	private let onAction: NavigationActionHandler<OnboardingNavigationAction>

	public init(store: any OnboardingFlagsStore,
				camera: any VIRBClientProtocol,
				onAction: @escaping NavigationActionHandler<OnboardingNavigationAction>) {
		self.store = store
		self.camera = camera
		self.onAction = onAction
	}

	// MARK: - Flag steps

	public func markGetStarted() { mutate { $0.hasTappedGetStarted = true } }
	public func markLocalNetworkResolved() { mutate { $0.localNetworkResolved = true } }
	public func markLocationResolved() { mutate { $0.locationResolved = true } }

	// MARK: - Camera-driven steps

	/// Changes the camera's Wi-Fi password. On success the camera kicks clients off, so the flow
	/// pins to Reconnect; on `.passwordRejected` (and any other camera error) this rethrows and
	/// leaves the step put, so the screen can show the current-password recovery field.
	public func changePassword(current: String, new: String) async throws {
		try await camera.setWiFiPassword(current: current, new: new)
		onAction(.passwordChanged)
	}

	/// The camera is reachable again after a password change; release the Reconnect pin so the flow
	/// can move on from the next connectivity reading.
	public func finishReconnect() { onAction(.reconnectFinished) }

	/// Reports a fresh connectivity reading and — when the camera is reachable with setup complete
	/// and onboarding hasn't been recorded yet — finalizes onboarding, so the flow lands in the
	/// gallery and a relaunch skips straight past it.
	public func applyConnectivity(_ snapshot: ConnectivitySnapshot) async {
		onAction(.connectivityUpdated(snapshot))
		if snapshot.isReachable, snapshot.setupComplete == true, store.load().hasCompletedOnboarding == false {
			await finishOnboarding()
		}
	}

	/// Claims the active-phone slot — best-effort, since the gallery re-attempts and surfaces
	/// active-phone errors itself — and persists `hasCompletedOnboarding`.
	public func finishOnboarding() async {
		try? await camera.activate()
		mutate { $0.hasCompletedOnboarding = true }
	}

	private func mutate(_ change: (inout OnboardingFlags) -> Void) {
		var flags = store.load()
		change(&flags)
		store.save(flags)
		onAction(.flagsUpdated(flags))
	}
}
