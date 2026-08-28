import CoreLocalization
import CoreUI
import SwiftUI

struct WelcomeView: View {
	let model: WelcomeViewModel

	var body: some View {
		ScrollableScreen {
			VStack(spacing: AppSpacing.lg) {
				Spacer()
				HeroIcon("camera.fill")
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
		}
		.background(AppColor.background)
		.accessibilityElement(children: .contain)
		.accessibilityIdentifier(AccessibilityID.Onboarding.welcome)
	}
}
