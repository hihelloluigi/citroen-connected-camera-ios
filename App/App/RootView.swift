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
            GalleryScreen(environment: environment)
        }
    }
}

/// Hosts the gallery. Owns `MediaListViewModel` in `@State` so it survives `RootView.body`
/// re-executions (the connectivity poll below reassigns `AppCoordinator.destination` every 5s, which
/// `@Observable` reports as a change even when the value is unchanged) — otherwise a fresh, unloaded
/// view model would be allocated every poll and the grid would spin forever.
private struct GalleryScreen: View {
    let environment: AppEnvironment
    @State private var listModel: MediaListViewModel

    init(environment: AppEnvironment) {
        self.environment = environment
        _listModel = State(wrappedValue: MediaListViewModel(
            service: environment.galleryService, photoSaver: environment.photoSaver))
    }

    var body: some View {
        NavigationStack {
            MediaListView(model: listModel,
                          loadDevice: { try? await environment.galleryService.device() })
                .navigationDestination(for: MediaItem.self) { item in
                    MediaDetailView(
                        model: MediaDetailViewModel(item: item, service: environment.galleryService,
                                                    photoSaver: environment.photoSaver),
                        onDelete: { listModel.remove(id: item.id) })
                }
        }
        .task {
            while !Task.isCancelled {
                if !listModel.isDownloading {
                    await environment.connectivity.refresh()
                    environment.routing.ingest(environment.connectivity.snapshot)
                }
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }
}
