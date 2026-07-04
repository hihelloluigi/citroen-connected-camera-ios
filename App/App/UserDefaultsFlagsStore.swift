import Foundation
import AppCore

/// `UserDefaults`-backed onboarding flags. App-target only; the flag logic it feeds is unit-tested
/// in AppCore against a fake.
struct UserDefaultsFlagsStore: OnboardingFlagsStore {
    // nonisolated(unsafe): UserDefaults is documented as thread-safe, but the SDK doesn't mark it
    // Sendable, so strict concurrency needs this annotation to accept it in a Sendable-conforming type.
    nonisolated(unsafe) private let defaults: UserDefaults
    private enum Key {
        static let getStarted = "onboarding.hasTappedGetStarted"
        static let localNetwork = "onboarding.localNetworkResolved"
        static let location = "onboarding.locationResolved"
        static let completed = "onboarding.hasCompletedOnboarding"
    }

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func load() -> OnboardingFlags {
        OnboardingFlags(
            hasTappedGetStarted: defaults.bool(forKey: Key.getStarted),
            localNetworkResolved: defaults.bool(forKey: Key.localNetwork),
            locationResolved: defaults.bool(forKey: Key.location),
            hasCompletedOnboarding: defaults.bool(forKey: Key.completed)
        )
    }

    func save(_ flags: OnboardingFlags) {
        defaults.set(flags.hasTappedGetStarted, forKey: Key.getStarted)
        defaults.set(flags.localNetworkResolved, forKey: Key.localNetwork)
        defaults.set(flags.locationResolved, forKey: Key.location)
        defaults.set(flags.hasCompletedOnboarding, forKey: Key.completed)
    }
}
