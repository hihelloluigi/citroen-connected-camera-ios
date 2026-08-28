import Foundation

/// Minimal key/value secret storage. The app backs this with the Keychain; tests use a fake.
public protocol SecureStore: Sendable {
	func data(forKey key: String) -> Data?
	func set(_ data: Data, forKey key: String) throws
}
