import SwiftUI
import AppCore
import CoreUI

/// Explains why the app needs Local Network access. iOS has no way to query or re-trigger this
/// permission, so "Continue" records that the user has acknowledged it; the system prompt itself
/// appears when the app first reaches the camera.
struct LocalNetworkPermissionView: View {
    let actions: OnboardingActions

    var body: some View {
        OnboardingExplainer(
            systemImage: "wifi",
            title: "Allow Local Network access",
            message: "The app talks to your camera directly over its Wi‑Fi. "
                + "iOS will ask for Local Network access the first time it connects — please allow it.",
            primaryTitle: "Continue",
            primaryAction: { actions.markLocalNetworkResolved() }
        )
    }
}

/// Shared layout for the onboarding explainer screens.
struct OnboardingExplainer: View {
    let systemImage: String
    let title: String
    let message: String
    let primaryTitle: String
    let primaryAction: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: AppIconSize.large))
                .foregroundStyle(AppColor.accent)
            Text(title).font(AppFont.title).foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(message).font(AppFont.body).foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButton(primaryTitle, action: primaryAction)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
