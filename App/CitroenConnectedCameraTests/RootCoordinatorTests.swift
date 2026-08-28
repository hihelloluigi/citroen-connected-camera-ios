import FeatureOnboarding
import Testing
@testable import CitroenConnectedCamera

@MainActor
@Test func coordinatorStartsInOnboardingAtWelcome() {
	let coordinator = RootCoordinator()
	#expect(coordinator.destination == .onboarding(.welcome))
}

@MainActor
@Test func coordinatorUpdatesDestinationFromInput() {
	let coordinator = RootCoordinator()
	coordinator.update(
		with: OnboardingRoutingInput(
			hasCompletedOnboarding: true,
			isReachable: true,
			setupComplete: true
		)
	)
	#expect(coordinator.destination == .gallery)
}

@MainActor
@Test func coordinatorHonorsInitialInput() {
	let coordinator = RootCoordinator(initial: OnboardingRoutingInput(hasTappedGetStarted: true))
	#expect(coordinator.destination == .onboarding(.localNetworkPermission))
}
