/// Folds the app's live inputs — persisted onboarding flags, the Location decision, and the latest
/// connectivity snapshot — into a `RoutingInput`. Pure, so routing is fully unit-testable end to end.
public enum RoutingInputAssembler {
    public static func assemble(flags: OnboardingFlags, locationStatus: PermissionStatus,
                                connectivity: ConnectivitySnapshot,
                                didJustChangePassword: Bool = false) -> RoutingInput {
        RoutingInput(
            hasCompletedOnboarding: flags.hasCompletedOnboarding,
            hasTappedGetStarted: flags.hasTappedGetStarted,
            localNetworkResolved: flags.localNetworkResolved,
            // Location is optional: any answered decision (granted OR denied) resolves the step.
            locationResolved: flags.locationResolved || locationStatus != .notDetermined,
            isReachable: connectivity.isReachable,
            setupComplete: connectivity.setupComplete,
            didJustChangePassword: didJustChangePassword
        )
    }
}
