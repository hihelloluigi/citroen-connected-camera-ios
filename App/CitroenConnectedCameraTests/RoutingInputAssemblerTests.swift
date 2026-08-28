import CoreConnectivity
import CoreDomain
import FeatureOnboarding
import Testing
@testable import CitroenConnectedCamera

private let resolve = ResolveOnboardingStepUseCase()

@Test func assemblesFirstLaunchToWelcome() {
	let input = RoutingInputAssembler.assemble(
		flags: OnboardingFlags(), locationStatus: .notDetermined, connectivity: ConnectivitySnapshot())
	#expect(resolve(input) == .welcome)
}

@Test func locationDecisionResolvesLocationStep() {
	// A denied Location decision still counts as "resolved" — Location is optional.
	let input = RoutingInputAssembler.assemble(
		flags: OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true),
		locationStatus: .denied, connectivity: ConnectivitySnapshot())
	#expect(input.locationResolved == true)
	#expect(resolve(input) == .connectWiFi)
}

@Test func passesThroughReachabilityAndSetup() {
	let input = RoutingInputAssembler.assemble(
		flags: OnboardingFlags(hasCompletedOnboarding: true),
		locationStatus: .granted,
		connectivity: ConnectivitySnapshot(isReachable: true, setupComplete: true))
	#expect(resolve(input) == nil)
}
