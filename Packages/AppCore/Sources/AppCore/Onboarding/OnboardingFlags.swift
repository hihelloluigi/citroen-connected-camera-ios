/// The small set of locally-persisted onboarding facts. The camera is the source of truth for setup
/// status; these flags only record how far the user has walked the flow on this device.
public struct OnboardingFlags: Sendable, Equatable {
    public var hasTappedGetStarted: Bool
    public var localNetworkResolved: Bool
    public var locationResolved: Bool
    public var hasCompletedOnboarding: Bool

    public init(hasTappedGetStarted: Bool = false, localNetworkResolved: Bool = false,
                locationResolved: Bool = false, hasCompletedOnboarding: Bool = false) {
        self.hasTappedGetStarted = hasTappedGetStarted
        self.localNetworkResolved = localNetworkResolved
        self.locationResolved = locationResolved
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}

/// Persists onboarding flags. The app backs this with `UserDefaults`; tests use an in-memory fake.
public protocol OnboardingFlagsStore: Sendable {
    func load() -> OnboardingFlags
    func save(_ flags: OnboardingFlags)
}
