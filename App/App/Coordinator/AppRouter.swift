import FeatureOnboarding

/// Maps the app's live routing input to a root destination — onboarding or gallery. Which
/// onboarding step is `ResolveOnboardingStepUseCase`'s call, and a `nil` from it means the flow is
/// done.

enum AppRouter {
	static func destination(
		for input: OnboardingRoutingInput,
		resolveStep: any ResolveOnboardingStepUseCaseProtocol
	) -> AppDestination {
		guard let step = resolveStep(input) else { return .gallery }

		return .onboarding(step)
	}
}
