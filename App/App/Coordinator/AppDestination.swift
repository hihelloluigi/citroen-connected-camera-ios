//
//  AppDestination.swift
//  CitroenConnectedCamera
//

import FeatureOnboarding

/// The single root screen the app shows.
///
/// Two cases, not seven: the six onboarding screens are one linear flow whose step
/// `FeatureOnboarding` owns and resolves, so the shell only decides between that flow and the
/// gallery. Feature-internal navigation — the gallery's list-to-detail push — runs on the feature's
/// own `NavigationStack`, not here.

enum AppDestination: Equatable, Hashable, Sendable {
	case onboarding(OnboardingStep)
	case gallery
}
