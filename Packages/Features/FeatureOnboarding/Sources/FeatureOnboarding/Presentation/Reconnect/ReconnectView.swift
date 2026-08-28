import CoreLocalization
import CoreUI
import SwiftUI

struct ReconnectView: View {
	let model: ReconnectViewModel

	var body: some View {
		VStack(spacing: AppSpacing.lg) {
			Spacer()
			Image(systemName: "arrow.triangle.2.circlepath")
				.font(.system(size: AppIconSize.large))
				.foregroundStyle(AppColor.accentEmphasis)
			Text(OnboardingStrings.reconnectTitle)
				.font(AppFont.title).foregroundStyle(AppColor.textPrimary)
				.multilineTextAlignment(.center)
			Text(OnboardingStrings.reconnectBody)
				.font(AppFont.body).foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			ProgressView().tint(AppColor.accentEmphasis)
			Text(OnboardingStrings.waitingForCamera)
				.font(AppFont.callout).foregroundStyle(AppColor.textSecondary)
			Spacer()
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
		.accessibilityElement(children: .contain)
		.accessibilityIdentifier(AccessibilityID.Onboarding.reconnect)
		.task { await model.monitor() }
	}
}
