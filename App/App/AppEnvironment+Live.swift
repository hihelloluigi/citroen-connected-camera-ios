import Foundation
import AppCore
import VIRBKit
import os

extension AppEnvironment {
    /// Builds the production environment: a Keychain-persisted phone id and a live camera client.
    static func live() -> AppEnvironment {
        let store = KeychainSecureStore()
        // Keep this non-throwing: a keychain failure shouldn't crash launch. But silently swallowing it
        // would mean a fresh, unpersisted phone id every launch, which is worth logging so it's diagnosable.
        let phoneId: String
        do {
            phoneId = try PhoneIdStore(store: store).currentPhoneId()
        } catch {
            Logger(subsystem: "com.example.citroenconnectedcamera", category: "phone-id")
                .error("Keychain unavailable for phone id; using a non-persisted fallback: \(error.localizedDescription, privacy: .public)")
            phoneId = UUID().uuidString
        }
        return AppEnvironment(camera: VIRBClient(phoneId: phoneId), phoneId: phoneId)
    }
}
