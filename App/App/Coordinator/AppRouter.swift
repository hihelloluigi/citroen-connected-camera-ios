//
//  AppRouter.swift
//  CitroenConnectedCamera
//

import FeatureOnboarding

/// Maps the app's live routing input to a root destination.
///
/// The decision this makes is deliberately thin — onboarding or gallery. Which onboarding step is
/// `ResolveOnboardingStepUseCase`'s call to make, and a `nil` from it is what means "the flow is
/// done"; keeping that machine inside the feature is why this router is four lines.

enum AppRouter {
	static func destination(for input: OnboardingRoutingInput,
							resolveStep: any ResolveOnboardingStepUseCaseProtocol) -> AppDestination {
		guard let step = resolveStep(input) else { return .gallery }
		return .onboarding(step)
	}
}
