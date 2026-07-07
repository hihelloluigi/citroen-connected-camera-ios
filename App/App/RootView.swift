import SwiftUI
import AppCore
import CoreUI

/// Renders the real onboarding screens for the `welcome`/permission destinations, and a placeholder
/// per remaining routing destination until Plan 5 replaces them.
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
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "camera.fill")
                .font(.system(size: AppIconSize.large))
                .foregroundStyle(AppColor.accent)
            Text(title).font(AppFont.title).foregroundStyle(AppColor.textPrimary)
            TelemetryText("READY · 0.0.0")
            Text("Screen coming soon").font(AppFont.callout).foregroundStyle(AppColor.textSecondary)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
