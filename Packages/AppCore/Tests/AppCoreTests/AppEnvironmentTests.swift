import Testing
@testable import AppCore

@MainActor
@Test func environmentHoldsInjectedDependencies() {
	let env = AppEnvironment(
		camera: MockVIRBClient(), phoneId: "ABC-123",
		flagsStore: InMemoryFlagsStore(), permissions: MockPermissionsService(),
		wifiInfo: MockWiFiInfoService(), galleryService: MockGalleryService(),
		photoSaver: MockPhotoLibrarySaver(),
		connectivity: ConnectivityMonitor(probe: StubReachabilityProbe()),
		coordinator: AppCoordinator())
	#expect(env.phoneId == "ABC-123")
}
