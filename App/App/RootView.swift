import SwiftUI
import AppCore
import CoreUI
import VIRBKit

/// Renders the real onboarding screens for every destination through `.reconnect`, and the gallery
/// for `.gallery`.
struct RootView: View {
    let coordinator: AppCoordinator
    let environment: AppEnvironment

    private var actions: OnboardingActions {
        OnboardingActions(store: environment.flagsStore, routing: environment.routing, camera: environment.camera)
    }

    var body: some View {
        switch coordinator.destination {
        case .welcome:
            WelcomeView(model: WelcomeViewModel(actions: actions))
        case .localNetworkPermission:
            LocalNetworkPermissionView(actions: actions)
        case .locationPermission:
            LocationPermissionView(model: LocationPermissionViewModel(permissions: environment.permissions, actions: actions))
        case .connectWiFi:
            ConnectWiFiView(model: ConnectWiFiViewModel(
                wifiInfo: environment.wifiInfo, connectivity: environment.connectivity, actions: actions))
        case .setPassword:
            SetPasswordView(model: SetPasswordViewModel(actions: actions))
        case .reconnect:
            ReconnectView(model: ReconnectViewModel(connectivity: environment.connectivity, actions: actions))
        case .gallery:
            NavigationStack {
                MediaListView(
                    model: MediaListViewModel(service: environment.galleryService, photoSaver: environment.photoSaver),
                    loadDevice: { try? await environment.galleryService.device() }
                )
                .navigationDestination(for: MediaItem.self) { item in
                    MediaDetailView(model: MediaDetailViewModel(
                        item: item, service: environment.galleryService, photoSaver: environment.photoSaver))
                }
            }
            .task {
                while !Task.isCancelled {
                    await environment.connectivity.refresh()
                    environment.routing.ingest(environment.connectivity.snapshot)
                    try? await Task.sleep(for: .seconds(5))
                }
            }
        }
    }
}
