import Foundation
import AppCore
import VIRBKit

extension AppEnvironment {
    /// Builds the production environment: Keychain phone id, live camera client, live services, and a
    /// connectivity monitor that probes that camera.
    @MainActor
    static func live() -> AppEnvironment {
        let store = KeychainSecureStore()
        let phoneId = (try? PhoneIdStore(store: store).currentPhoneId()) ?? UUID().uuidString
        let camera = VIRBClient(phoneId: phoneId)
        return AppEnvironment(
            camera: camera, phoneId: phoneId,
            flagsStore: UserDefaultsFlagsStore(),
            permissions: LiveLocationPermissions(),
            connectivity: ConnectivityMonitor(probe: CameraReachabilityProbe(client: camera)),
            coordinator: AppCoordinator())
    }
}
