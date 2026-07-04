import Testing
@testable import AppCore

@Test func assemblesFirstLaunchToWelcome() {
    let input = RoutingInputAssembler.assemble(
        flags: OnboardingFlags(), locationStatus: .notDetermined, connectivity: ConnectivitySnapshot())
    #expect(AppRouter.destination(for: input) == .welcome)
}

@Test func locationDecisionResolvesLocationStep() {
    // A denied Location decision still counts as "resolved" — Location is optional.
    let input = RoutingInputAssembler.assemble(
        flags: OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true),
        locationStatus: .denied, connectivity: ConnectivitySnapshot())
    #expect(input.locationResolved == true)
    #expect(AppRouter.destination(for: input) == .connectWiFi)
}

@Test func passesThroughReachabilityAndSetup() {
    let input = RoutingInputAssembler.assemble(
        flags: OnboardingFlags(hasCompletedOnboarding: true),
        locationStatus: .granted,
        connectivity: ConnectivitySnapshot(isReachable: true, setupComplete: true))
    #expect(AppRouter.destination(for: input) == .gallery)
}
