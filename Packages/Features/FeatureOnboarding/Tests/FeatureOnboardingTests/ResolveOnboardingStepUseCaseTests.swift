import Testing
@testable import FeatureOnboarding

/// The onboarding state machine, exhaustively. A `nil` step means the flow is finished and the app
/// shell should show the gallery — these were `.gallery` assertions when the machine lived in the
/// app target's AppRouter.
private let resolve = ResolveOnboardingStepUseCase()

@Test func firstLaunchShowsWelcome() {
	#expect(resolve(OnboardingRoutingInput()) == .welcome)
}

@Test func afterGetStartedAsksLocalNetwork() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true)
	#expect(resolve(input) == .localNetworkPermission)
}

@Test func afterLocalNetworkAsksLocation() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true, localNetworkResolved: true)
	#expect(resolve(input) == .locationPermission)
}

@Test func afterPermissionsAsksToConnectWhenUnreachable() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true)
	#expect(resolve(input) == .connectWiFi)
}

@Test func reachableButNotYetConnectedStaysOnConnect() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
							 locationResolved: true, isReachable: true, setupComplete: nil)
	#expect(resolve(input) == .connectWiFi)
}

@Test func reachableAndSetupIncompleteAsksToSetPassword() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
							 locationResolved: true, isReachable: true, setupComplete: false)
	#expect(resolve(input) == .setPassword)
}

@Test func rightAfterPasswordChangeAsksToReconnect() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
							 locationResolved: true, isReachable: true, setupComplete: false,
							 didJustChangePassword: true)
	#expect(resolve(input) == .reconnect)
}

@Test func afterPasswordChangeWhileKickedOffAsksToReconnect() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
							 locationResolved: true, isReachable: false, setupComplete: false,
							 didJustChangePassword: true)
	#expect(resolve(input) == .reconnect)
}

@Test func firstTimeSetupCompleteGoesToGallery() {
	let input = OnboardingRoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
							 locationResolved: true, isReachable: true, setupComplete: true)
	#expect(resolve(input) == nil)
}

@Test func returningUserReachableAndReadyGoesToGallery() {
	let input = OnboardingRoutingInput(hasCompletedOnboarding: true, isReachable: true, setupComplete: true)
	#expect(resolve(input) == nil)
}

@Test func returningUserWithCameraDownGoesToReconnect() {
	let input = OnboardingRoutingInput(hasCompletedOnboarding: true, isReachable: false, setupComplete: nil)
	#expect(resolve(input) == .reconnect)
}
