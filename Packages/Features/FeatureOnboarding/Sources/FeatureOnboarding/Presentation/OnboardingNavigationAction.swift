import CoreConnectivity
import CoreDomain

/// Navigation events emitted by the onboarding flow. Each case is a fact the flow established, not
/// an instruction about where to go — the app shell folds them into its routing input.

public enum OnboardingNavigationAction: Sendable, Equatable {
	/// The persisted onboarding flags changed.
	case flagsUpdated(OnboardingFlags)
	/// The camera accepted a new Wi-Fi password and will now kick every client off.
	case passwordChanged
	/// The camera is back after a password change; the Reconnect pin can be released.
	case reconnectFinished
	/// A fresh reachability reading.
	case connectivityUpdated(ConnectivitySnapshot)
}
