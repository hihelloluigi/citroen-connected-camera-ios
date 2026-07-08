import Foundation

/// Provides the stable per-device phone id the camera uses to identify this client, generating one
/// on first use and persisting it so the same id is returned forever after.
public struct PhoneIdStore: Sendable {
	private let store: any SecureStore
	private let key: String
	private let makeId: @Sendable () -> String

	public init(store: any SecureStore, key: String = "camera.phoneId",
				makeId: @escaping @Sendable () -> String = { UUID().uuidString }) {
		self.store = store
		self.key = key
		self.makeId = makeId
	}

	public func currentPhoneId() throws -> String {
		if let data = store.data(forKey: key), let existing = String(data: data, encoding: .utf8), !existing.isEmpty {
			return existing
		}
		let generated = makeId()
		try store.set(Data(generated.utf8), forKey: key)
		return generated
	}
}
