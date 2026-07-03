import SwiftUI
import AppCore

/// Renders one placeholder screen per routing destination. Real screens replace these in later plans;
/// this establishes the composition-root → coordinator → view wiring.
struct RootView: View {
    let coordinator: AppCoordinator
    let environment: AppEnvironment

    var body: some View {
        switch coordinator.destination {
        case .welcome: PlaceholderScreen(title: "Welcome")
        case .localNetworkPermission: PlaceholderScreen(title: "Local Network Access")
        case .locationPermission: PlaceholderScreen(title: "Location Access")
        case .connectWiFi: PlaceholderScreen(title: "Connect to Camera Wi‑Fi")
        case .setPassword: PlaceholderScreen(title: "Set a New Password")
        case .reconnect: PlaceholderScreen(title: "Reconnect")
        case .gallery: PlaceholderScreen(title: "Gallery")
        }
    }
}

private struct PlaceholderScreen: View {
    let title: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill").font(.largeTitle)
            Text(title).font(.title2).bold()
            Text("Screen coming soon").foregroundStyle(.secondary)
        }
        .padding()
    }
}
