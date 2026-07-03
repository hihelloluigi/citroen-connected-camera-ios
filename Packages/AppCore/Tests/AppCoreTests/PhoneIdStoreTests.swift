import Foundation
import Testing
@testable import AppCore

/// In-memory SecureStore for tests.
private final class FakeSecureStore: SecureStore, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    func data(forKey key: String) -> Data? { storage[key] }
    func set(_ data: Data, forKey key: String) throws { storage[key] = data }
}

@Test func generatesAndPersistsPhoneIdOnFirstUse() throws {
    let store = FakeSecureStore()
    let sut = PhoneIdStore(store: store, makeId: { "FIXED-ID" })
    #expect(try sut.currentPhoneId() == "FIXED-ID")
    // Persisted: the raw bytes are now in the store under the default key.
    #expect(store.data(forKey: "camera.phoneId") == Data("FIXED-ID".utf8))
}

@Test func returnsSamePhoneIdOnSubsequentUse() throws {
    let store = FakeSecureStore()
    // nonisolated(unsafe): the closure is @Sendable, but this counter is only touched
    // synchronously on the test's own thread — the same pattern the VIRBKit tests use.
    nonisolated(unsafe) var calls = 0
    let sut = PhoneIdStore(store: store, makeId: { calls += 1; return "ID-\(calls)" })
    let first = try sut.currentPhoneId()
    let second = try sut.currentPhoneId()
    #expect(first == second)
    #expect(calls == 1) // generated exactly once
}
