//
//  RoutingInputAssembler.swift
//  CitroenConnectedCamera
//

import CoreConnectivity
import CoreDomain
import FeatureOnboarding

/// Folds the app's live inputs — persisted onboarding flags, the Location decision, and the latest
/// connectivity snapshot — into an `OnboardingRoutingInput`. Pure, so routing is unit-testable end
/// to end.

enum RoutingInputAssembler {
	static func assemble(flags: OnboardingFlags, locationStatus: PermissionStatus,
						 connectivity: ConnectivitySnapshot,
						 didJustChangePassword: Bool = false) -> OnboardingRoutingInput {
		OnboardingRoutingInput(
			hasCompletedOnboarding: flags.hasCompletedOnboarding,
			hasTappedGetStarted: flags.hasTappedGetStarted,
			localNetworkResolved: flags.localNetworkResolved,
			// Location is optional: any answered decision (granted OR denied) resolves the step.
			locationResolved: flags.locationResolved || locationStatus != .notDetermined,
			isReachable: connectivity.isReachable,
			setupComplete: connectivity.setupComplete,
			didJustChangePassword: didJustChangePassword
		)
	}
}
