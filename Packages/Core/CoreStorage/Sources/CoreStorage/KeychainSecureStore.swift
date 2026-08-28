import CoreLogging
import Foundation
import Security

/// Keychain-backed `SecureStore` for small secrets (the generated phone id). The generate-once
/// logic it feeds is unit-tested against an in-memory fake in CoreStorageTests.
public struct KeychainSecureStore: SecureStore {
	/// Scoped to the running bundle id, so the Development, Staging and Production installs
	/// each keep their own phone id instead of sharing one Keychain item.
	private let service = AppLogger.subsystem
	private let logger = AppLogger(category: "phone-id")

	public init() {}

	public func data(forKey key: String) -> Data? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		var result: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		if status == errSecItemNotFound { return nil }
		guard status == errSecSuccess else {
			// A real keychain error is not the same as "no value yet" — log it so it isn't mistaken for
			// a first launch, but still return nil since this protocol is non-throwing.
			logger.error("Keychain read failed (status \(status)); treating as missing.")
			return nil
		}
		return result as? Data
	}

	public func set(_ data: Data, forKey key: String) throws {
		let base: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key
		]
		SecItemDelete(base as CFDictionary)
		var attributes = base
		attributes[kSecValueData as String] = data
		// Device-only: the phone id should never sync via iCloud Keychain or restore onto another device.
		attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		let status = SecItemAdd(attributes as CFDictionary, nil)
		guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
	}

	enum KeychainError: Error { case unexpectedStatus(OSStatus) }
}
