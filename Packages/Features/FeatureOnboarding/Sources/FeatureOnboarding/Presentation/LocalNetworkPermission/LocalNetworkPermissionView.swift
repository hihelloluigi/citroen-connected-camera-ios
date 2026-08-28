import CoreLocalization
import CoreUI
import SwiftUI

/// Explains why the app needs Local Network access. iOS has no way to query or re-trigger this
/// permission, so "Continue" records that the user has acknowledged it; the system prompt itself
/// appears when the app first reaches the camera.
struct LocalNetworkPermissionView: View {
	let actions: any AdvanceOnboardingUseCaseProtocol

	var body: some View {
		OnboardingExplainer(
			systemImage: "wifi",
			title: OnboardingStrings.localNetworkTitle,
			message: OnboardingStrings.localNetworkBody,
			primaryTitle: CommonStrings.continue,
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
				.foregroundStyle(AppColor.accentEmphasis)
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
