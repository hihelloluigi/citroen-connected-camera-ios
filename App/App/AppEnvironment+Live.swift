import Foundation
import AppCore
import VIRBKit

extension AppEnvironment {
    /// Builds the production environment: a Keychain-persisted phone id and a live camera client.
    static func live() -> AppEnvironment {
        let store = KeychainSecureStore()
        let phoneId = (try? PhoneIdStore(store: store).currentPhoneId()) ?? UUID().uuidString
        return AppEnvironment(camera: VIRBClient(phoneId: phoneId), phoneId: phoneId)
    }
}
