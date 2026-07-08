import Foundation
import AppCore
import VIRBKit
import os

extension AppEnvironment {
	/// Builds the production environment: Keychain phone id, live camera client, live services, and a
	/// connectivity monitor that probes that camera.
	@MainActor
	static func live() -> AppEnvironment {
		let store = KeychainSecureStore()
		// Preserve the Plan 2 hardening: log a keychain failure before the non-persisted fallback,
		// instead of a silent `try?` that would hide phone-id instability.
		let phoneId: String
		do {
			phoneId = try PhoneIdStore(store: store).currentPhoneId()
		} catch {
			Logger(subsystem: "com.example.citroenconnectedcamera", category: "phone-id")
				.error("Keychain unavailable for phone id; using a non-persisted fallback: \(error.localizedDescription, privacy: .public)")
			phoneId = UUID().uuidString
		}
		let camera = VIRBClient(phoneId: phoneId)
		return AppEnvironment(
			camera: camera, phoneId: phoneId,
			flagsStore: UserDefaultsFlagsStore(),
			permissions: LiveLocationPermissions(),
			wifiInfo: LiveWiFiInfo(),
			galleryService: LiveGalleryService(client: camera),
			photoSaver: LivePhotoLibrarySaver(),
			connectivity: ConnectivityMonitor(probe: CameraReachabilityProbe(client: camera)),
			coordinator: AppCoordinator())
	}
}
