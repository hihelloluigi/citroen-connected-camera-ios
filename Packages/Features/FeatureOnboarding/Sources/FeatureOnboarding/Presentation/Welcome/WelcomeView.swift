import CoreLocalization
import CoreUI
import SwiftUI

struct WelcomeView: View {
	let model: WelcomeViewModel

	var body: some View {
		VStack(spacing: AppSpacing.lg) {
			Spacer()
			Image(systemName: "camera.fill")
				.font(.system(size: AppIconSize.large))
				.foregroundStyle(AppColor.accentEmphasis)
			Text(OnboardingStrings.welcomeTitle)
				.font(AppFont.displayLarge)
				.foregroundStyle(AppColor.textPrimary)
				.multilineTextAlignment(.center)
			Text(OnboardingStrings.welcomeBody)
				.font(AppFont.body)
				.foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			Spacer()
			PrimaryButton(OnboardingStrings.getStarted) { model.getStarted() }
				.accessibilityIdentifier(AccessibilityID.Onboarding.getStarted)
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
		.accessibilityElement(children: .contain)
		.accessibilityIdentifier(AccessibilityID.Onboarding.welcome)
	}
}
