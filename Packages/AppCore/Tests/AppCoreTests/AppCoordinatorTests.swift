import Testing
@testable import AppCore

@MainActor
@Test func coordinatorStartsAtWelcomeByDefault() {
	let coordinator = AppCoordinator()
	#expect(coordinator.destination == .welcome)
}

@MainActor
@Test func coordinatorUpdatesDestinationFromInput() {
	let coordinator = AppCoordinator()
	coordinator.update(with: RoutingInput(hasCompletedOnboarding: true, isReachable: true, setupComplete: true))
	#expect(coordinator.destination == .gallery)
}

@MainActor
@Test func coordinatorHonorsInitialInput() {
	let coordinator = AppCoordinator(initial: RoutingInput(hasTappedGetStarted: true))
	#expect(coordinator.destination == .localNetworkPermission)
}
