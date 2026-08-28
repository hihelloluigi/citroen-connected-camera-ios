//
//  OnboardingStep.swift
//  FeatureOnboarding
//

/// One screen of the onboarding flow.
///
/// The flow is linear and root-replacing — there is no back navigation and no stack — so a step is
/// the whole of the flow's navigation state.
public enum OnboardingStep: Equatable, Hashable, Sendable, CaseIterable {
	case welcome
	case localNetworkPermission
	case locationPermission
	case connectWiFi
	case setPassword
	case reconnect
}
