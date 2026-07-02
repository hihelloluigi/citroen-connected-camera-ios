import Testing
@testable import AppCore

@Test func firstLaunchShowsWelcome() {
    #expect(AppRouter.destination(for: RoutingInput()) == .welcome)
}

@Test func afterGetStartedAsksLocalNetwork() {
    let input = RoutingInput(hasTappedGetStarted: true)
    #expect(AppRouter.destination(for: input) == .localNetworkPermission)
}

@Test func afterLocalNetworkAsksLocation() {
    let input = RoutingInput(hasTappedGetStarted: true, localNetworkResolved: true)
    #expect(AppRouter.destination(for: input) == .locationPermission)
}

@Test func afterPermissionsAsksToConnectWhenUnreachable() {
    let input = RoutingInput(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true)
    #expect(AppRouter.destination(for: input) == .connectWiFi)
}

@Test func reachableButNotYetConnectedStaysOnConnect() {
    let input = RoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
                             locationResolved: true, isReachable: true, setupComplete: nil)
    #expect(AppRouter.destination(for: input) == .connectWiFi)
}

@Test func reachableAndSetupIncompleteAsksToSetPassword() {
    let input = RoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
                             locationResolved: true, isReachable: true, setupComplete: false)
    #expect(AppRouter.destination(for: input) == .setPassword)
}

@Test func rightAfterPasswordChangeAsksToReconnect() {
    let input = RoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
                             locationResolved: true, isReachable: true, setupComplete: false,
                             didJustChangePassword: true)
    #expect(AppRouter.destination(for: input) == .reconnect)
}

@Test func firstTimeSetupCompleteGoesToGallery() {
    let input = RoutingInput(hasTappedGetStarted: true, localNetworkResolved: true,
                             locationResolved: true, isReachable: true, setupComplete: true)
    #expect(AppRouter.destination(for: input) == .gallery)
}

@Test func returningUserReachableAndReadyGoesToGallery() {
    let input = RoutingInput(hasCompletedOnboarding: true, isReachable: true, setupComplete: true)
    #expect(AppRouter.destination(for: input) == .gallery)
}

@Test func returningUserWithCameraDownGoesToReconnect() {
    let input = RoutingInput(hasCompletedOnboarding: true, isReachable: false, setupComplete: nil)
    #expect(AppRouter.destination(for: input) == .reconnect)
}
