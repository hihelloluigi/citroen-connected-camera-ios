import VIRBKit

/// The app's composition root: dependencies built once and passed down. Holds the camera client, the
/// services, the persisted onboarding flags, the connectivity monitor, and the routing controller that
/// ties live state to navigation.
@MainActor
public final class AppEnvironment {
    public let camera: any VIRBClientProtocol
    public let phoneId: String
    public let flagsStore: any OnboardingFlagsStore
    public let permissions: any PermissionsService
    public let wifiInfo: any WiFiInfoService
    public let galleryService: any GalleryService
    public let photoSaver: any PhotoLibrarySaver
    public let connectivity: ConnectivityMonitor
    public let coordinator: AppCoordinator
    public let routing: RoutingController

    public init(camera: any VIRBClientProtocol, phoneId: String,
                flagsStore: any OnboardingFlagsStore, permissions: any PermissionsService,
                wifiInfo: any WiFiInfoService, galleryService: any GalleryService,
                photoSaver: any PhotoLibrarySaver,
                connectivity: ConnectivityMonitor, coordinator: AppCoordinator) {
        self.camera = camera
        self.phoneId = phoneId
        self.flagsStore = flagsStore
        self.permissions = permissions
        self.wifiInfo = wifiInfo
        self.galleryService = galleryService
        self.photoSaver = photoSaver
        self.connectivity = connectivity
        self.coordinator = coordinator
        self.routing = RoutingController(coordinator: coordinator, flags: flagsStore.load())
    }
}
