import CoreNavigation
import FeatureOnboarding
import Observation

/// Owns the current root destination and recomputes it from the latest routing input.
/// `RootView` observes `destination`; it never makes a navigation decision itself.
@MainActor
@Observable
final class RootCoordinator: Coordinator {
	private(set) var destination: AppDestination
	private let resolveStep: any ResolveOnboardingStepUseCaseProtocol

	init(initial: OnboardingRoutingInput = OnboardingRoutingInput(),
		 resolveStep: any ResolveOnboardingStepUseCaseProtocol = ResolveOnboardingStepUseCase()) {
		self.resolveStep = resolveStep
		self.destination = AppRouter.destination(for: initial, resolveStep: resolveStep)
	}

	func update(with input: OnboardingRoutingInput) {
		let next = AppRouter.destination(for: input, resolveStep: resolveStep)
		guard next != destination else { return }
		destination = next
	}
}
