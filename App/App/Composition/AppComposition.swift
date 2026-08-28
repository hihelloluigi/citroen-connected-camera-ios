//
//  AppComposition.swift
//  CitroenConnectedCamera
//

import CoreCamera
import CoreConnectivity
import CoreDomain
import CoreStorage
import FeatureGallery
import FeatureOnboarding
import Foundation
import os

/// The app's composition root: every dependency built once, in one place, and handed to the
/// builders that need it.
///
/// This is the only type that names a concrete implementation. Each module vends its own live type
/// — `KeychainSecureStore`, `GalleryRepository`, `LiveWiFiInfo` — and nothing below this file knows
/// which one it got.
@MainActor
final class AppComposition {
	let camera: any VIRBClientProtocol
	let phoneId: String
	let flagsStore: any OnboardingFlagsStore
	let permissions: any PermissionsService
	let wifiInfo: any WiFiInfoService
	let galleryRepository: any GalleryRepositoryProtocol
	let photoSaver: any PhotoLibrarySaverProtocol
	let connectivity: ConnectivityMonitor
	let coordinator: RootCoordinator
	let routing: RoutingController

	init(camera: any VIRBClientProtocol, phoneId: String,
		 flagsStore: any OnboardingFlagsStore, permissions: any PermissionsService,
		 wifiInfo: any WiFiInfoService, galleryRepository: any GalleryRepositoryProtocol,
		 photoSaver: any PhotoLibrarySaverProtocol,
		 connectivity: ConnectivityMonitor, coordinator: RootCoordinator) {
		self.camera = camera
		self.phoneId = phoneId
		self.flagsStore = flagsStore
		self.permissions = permissions
		self.wifiInfo = wifiInfo
		self.galleryRepository = galleryRepository
		self.photoSaver = photoSaver
		self.connectivity = connectivity
		self.coordinator = coordinator
		self.routing = RoutingController(coordinator: coordinator, flags: flagsStore.load())
	}

	/// What the onboarding builders need, gathered once.
	var onboardingDependencies: OnboardingDependencies {
		OnboardingDependencies(flagsStore: flagsStore, camera: camera, permissions: permissions,
							   wifiInfo: wifiInfo, connectivity: connectivity)
	}

	/// Builds the production graph: Keychain phone id, live camera client, live services, and a
	/// connectivity monitor probing that same camera.
	static func live() -> AppComposition {
		let store = KeychainSecureStore()
		// Log a Keychain failure before falling back to a non-persisted id, instead of a silent
		// `try?` that would hide phone-id instability.
		let phoneId: String
		do {
			phoneId = try PhoneIdStore(store: store).currentPhoneId()
		} catch {
			Logger(subsystem: Bundle.main.bundleIdentifier ?? "me.luigiaiello.ccam", category: "phone-id")
				.error("Keychain unavailable for phone id; using a non-persisted fallback: \(error.localizedDescription, privacy: .public)")
			phoneId = UUID().uuidString
		}
		let camera = VIRBClient(phoneId: phoneId)
		return AppComposition(
			camera: camera, phoneId: phoneId,
			flagsStore: UserDefaultsFlagsStore(),
			permissions: LiveLocationPermissions(),
			wifiInfo: LiveWiFiInfo(),
			galleryRepository: GalleryRepository(client: camera),
			photoSaver: PhotoLibrarySaver(),
			connectivity: ConnectivityMonitor(probe: CameraSessionProbe(client: camera)),
			coordinator: RootCoordinator())
	}
}
