import CoreDomain
import Foundation

/// `UserDefaults`-backed `OnboardingFlagsStore`. The flag logic it feeds is unit-tested against an
/// in-memory fake in FeatureOnboardingTests.
public struct UserDefaultsFlagsStore: OnboardingFlagsStore {
	// nonisolated(unsafe): UserDefaults is documented as thread-safe, but the SDK doesn't mark it
	// Sendable, so strict concurrency needs this annotation to accept it in a Sendable-conforming type.
	nonisolated(unsafe) private let defaults: UserDefaults
	private enum Key {
		static let getStarted = "onboarding.hasTappedGetStarted"
		static let localNetwork = "onboarding.localNetworkResolved"
		static let location = "onboarding.locationResolved"
		static let completed = "onboarding.hasCompletedOnboarding"
	}

	public init(defaults: UserDefaults = .standard) { self.defaults = defaults }

	public func load() -> OnboardingFlags {
		OnboardingFlags(
			hasTappedGetStarted: defaults.bool(forKey: Key.getStarted),
			localNetworkResolved: defaults.bool(forKey: Key.localNetwork),
			locationResolved: defaults.bool(forKey: Key.location),
			hasCompletedOnboarding: defaults.bool(forKey: Key.completed)
		)
	}

	public func save(_ flags: OnboardingFlags) {
		defaults.set(flags.hasTappedGetStarted, forKey: Key.getStarted)
		defaults.set(flags.localNetworkResolved, forKey: Key.localNetwork)
		defaults.set(flags.locationResolved, forKey: Key.location)
		defaults.set(flags.hasCompletedOnboarding, forKey: Key.completed)
	}

	/// Clears every onboarding flag. Only the `-uiTestMode` launch path calls this — it is what
	/// lets a UI test start at Welcome regardless of how the previous run left the simulator.
	public func reset() {
		for key in [Key.getStarted, Key.localNetwork, Key.location, Key.completed] {
			defaults.removeObject(forKey: key)
		}
	}
}
