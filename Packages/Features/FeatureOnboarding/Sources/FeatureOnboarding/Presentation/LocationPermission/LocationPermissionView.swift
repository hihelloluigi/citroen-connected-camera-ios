import CoreLocalization
import CoreUI
import SwiftUI

struct LocationPermissionView: View {
	let model: LocationPermissionViewModel

	var body: some View {
		VStack(spacing: AppSpacing.lg) {
			Spacer()
			Image(systemName: "location")
				.font(.system(size: AppIconSize.large))
				.foregroundStyle(AppColor.accentEmphasis)
			Text(OnboardingStrings.locationTitle)
				.font(AppFont.title).foregroundStyle(AppColor.textPrimary)
				.multilineTextAlignment(.center)
			Text(OnboardingStrings.locationBody)
				.font(AppFont.body).foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			Spacer()
			if model.isDenied {
				PrimaryButton(CommonStrings.openSettings) { AppSettings.open() }
			} else {
				PrimaryButton(OnboardingStrings.locationAllow, isLoading: model.isRequesting) {
					Task { await model.request() }
				}
				.accessibilityIdentifier(AccessibilityID.Onboarding.locationAllow)
			}
			SecondaryButton(CommonStrings.notNow) { model.skip() }
				.accessibilityIdentifier(AccessibilityID.Onboarding.locationSkip)
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
		.accessibilityElement(children: .contain)
		.accessibilityIdentifier(AccessibilityID.Onboarding.location)
		.task { await model.onAppear() }
	}
}
