@testable import CoreDomain

/// In-memory `OnboardingFlagsStore` fake. Duplicated per package — test helpers can't cross a
/// package boundary.
final class InMemoryFlagsStore: OnboardingFlagsStore, @unchecked Sendable {
	// MARK: - Stored Properties

	private var flags: OnboardingFlags

	// MARK: - Init

	init(_ flags: OnboardingFlags = .init()) {
		self.flags = flags
	}

	// MARK: - OnboardingFlagsStore

	func load() -> OnboardingFlags { flags }

	func save(_ flags: OnboardingFlags) {
		self.flags = flags
	}
}
