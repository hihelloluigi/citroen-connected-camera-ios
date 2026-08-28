//
//  OnboardingNavigationAction.swift
//  FeatureOnboarding
//

import CoreConnectivity
import CoreDomain

/// Navigation events emitted by the onboarding flow.
///
/// Each case is a fact the flow has established, not an instruction about where to go — the app
/// shell folds them into its routing input and the step machine decides the rest. This is what
/// replaced the flow reaching into the app's `RoutingController` directly: a feature that imports
/// the app shell isn't a layer boundary at all.

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
