import FeatureOnboarding

/// The single root screen the app shows. Two cases, not seven: `FeatureOnboarding` owns its own
/// step, and the gallery's list-to-detail push runs on that feature's `NavigationStack`.

enum AppDestination: Equatable, Hashable, Sendable {
	case onboarding(OnboardingStep)
	case gallery
}
