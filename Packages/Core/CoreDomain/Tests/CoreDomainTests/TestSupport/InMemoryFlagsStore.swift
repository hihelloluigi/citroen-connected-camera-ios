//
//  InMemoryFlagsStore.swift
//  CoreDomainTests
//

@testable import CoreDomain

/// In-memory `OnboardingFlagsStore` fake.
///
/// FeatureOnboardingTests carries its own copy of this. Test-only helpers can't cross a package
/// boundary without a shared test module, and one fake per protocol per package is what the fleet
/// does rather than introduce one.
final class InMemoryFlagsStore: OnboardingFlagsStore, @unchecked Sendable {
	private var flags: OnboardingFlags

	init(_ flags: OnboardingFlags = .init()) {
		self.flags = flags
	}

	func load() -> OnboardingFlags { flags }
	func save(_ flags: OnboardingFlags) { self.flags = flags }
}
