/// One screen of the onboarding flow. The flow is linear and root-replacing, so a step is the
/// whole of its navigation state.
public enum OnboardingStep: Equatable, Hashable, Sendable, CaseIterable {
	case welcome
	case localNetworkPermission
	case locationPermission
	case connectWiFi
	case setPassword
	case reconnect
}
