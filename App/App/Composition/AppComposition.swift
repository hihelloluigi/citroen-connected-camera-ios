import CoreCamera
import CoreConnectivity
import CoreDomain
import CoreLogging
import CoreStorage
import FeatureGallery
import FeatureOnboarding
import Foundation

/// The app's composition root: every dependency built once, in one place, and handed to the
/// builders that need it.
///
/// This is the only type that names a concrete implementation. Each module vends its own live type
/// — `KeychainSecureStore`, `GalleryRepository`, `LiveWiFiInfo` — and nothing below this file knows
/// which one it got.
@MainActor
final class AppComposition {
	// MARK: - Stored Properties

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

	// MARK: - Computed Properties

	/// What the onboarding builders need, gathered once.
	var onboardingDependencies: OnboardingDependencies {
		OnboardingDependencies(
			flagsStore: flagsStore,
			camera: camera,
			permissions: permissions,
			wifiInfo: wifiInfo,
			connectivity: connectivity
		)
	}

	// MARK: - Init

	init(
		camera: any VIRBClientProtocol,
		phoneId: String,
		flagsStore: any OnboardingFlagsStore,
		permissions: any PermissionsService,
		wifiInfo: any WiFiInfoService,
		galleryRepository: any GalleryRepositoryProtocol,
		photoSaver: any PhotoLibrarySaverProtocol,
		connectivity: ConnectivityMonitor,
		coordinator: RootCoordinator
	) {
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

	/// Builds the production graph: Keychain phone id, live camera client, live services, and a
	/// connectivity monitor probing that same camera.
	///
	/// Under `-uiTestMode` the camera is scripted instead. Nothing else changes — the same
	/// repositories, the same routing, the same screens — because the point is to exercise the real
	/// app against a camera that answers, not to run a different app.
	static func live() -> AppComposition {
		let store = KeychainSecureStore()
		// Log a Keychain failure before falling back to a non-persisted id, instead of a silent
		// `try?` that would hide phone-id instability.
		let phoneId: String
		do {
			phoneId = try PhoneIdStore(store: store).currentPhoneId()
		} catch {
			AppLogger(category: "phone-id")
				.error("Keychain unavailable for phone id; using a non-persisted fallback: \(error.localizedDescription)")
			phoneId = UUID().uuidString
		}

		let camera: any VIRBClientProtocol = UITestMode.scenario.map(ScriptedVIRBClient.init(scenario:))
			?? VIRBClient(phoneId: phoneId)

		if UITestMode.shouldResetState {
			UserDefaultsFlagsStore().reset()
		}

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

/// How a UI test asks for a scripted camera and a clean slate.
///
/// Reading the arguments in one place keeps the flags out of `live()`'s body and makes the whole
/// surface — two flags, no more — visible at a glance. A normal launch matches neither.
enum UITestMode {
	/// `-uiTestMode ready|fresh|absent` swaps the live camera client for a scripted one.
	static var scenario: ScriptedVIRBClient.Scenario? {
		guard
			let index = CommandLine.arguments.firstIndex(of: "-uiTestMode"),
			let raw = CommandLine.arguments[safe: index + 1]
		else {
			return nil
		}

		return ScriptedVIRBClient.Scenario(rawValue: raw)
	}

	/// `-uiTestResetState` clears the persisted onboarding flags, so a test that walks the flow
	/// starts at Welcome however the previous test left the simulator.
	static var shouldResetState: Bool {
		CommandLine.arguments.contains("-uiTestResetState")
	}
}

private extension Array {
	subscript(safe index: Int) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}
