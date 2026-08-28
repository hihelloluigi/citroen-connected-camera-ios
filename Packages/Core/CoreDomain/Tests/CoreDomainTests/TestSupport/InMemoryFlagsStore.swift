@testable import CoreDomain

/// In-memory `OnboardingFlagsStore` fake. Duplicated per package — test helpers can't cross a
/// package boundary.
final class InMemoryFlagsStore: OnboardingFlagsStore, @unchecked Sendable {
	private var flags: OnboardingFlags

	init(_ flags: OnboardingFlags = .init()) {
		self.flags = flags
	}

	func load() -> OnboardingFlags { flags }
	func save(_ flags: OnboardingFlags) { self.flags = flags }
}
