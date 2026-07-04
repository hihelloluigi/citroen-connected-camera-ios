@testable import AppCore

/// In-memory `OnboardingFlagsStore` fake for tests. Reusable across Plan 4 test files, so it lives
/// in Support rather than being declared privately in a single test file.
final class InMemoryFlagsStore: OnboardingFlagsStore, @unchecked Sendable {
    private var flags: OnboardingFlags

    init(_ flags: OnboardingFlags = .init()) {
        self.flags = flags
    }

    func load() -> OnboardingFlags { flags }
    func save(_ flags: OnboardingFlags) { self.flags = flags }
}
