import CoreLocalization
import CoreUI
import SwiftUI

struct ConnectWiFiView: View {
	let model: ConnectWiFiViewModel

	var body: some View {
		VStack(spacing: AppSpacing.lg) {
			Spacer()
			Image(systemName: "wifi.router")
				.font(.system(size: AppIconSize.large))
				.foregroundStyle(AppColor.accentEmphasis)
			Text(OnboardingStrings.connectTitle)
				.font(AppFont.title).foregroundStyle(AppColor.textPrimary)
				.multilineTextAlignment(.center)
			Text(networkLine)
				.font(AppFont.body).foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			Text(OnboardingStrings.connectBody)
				.font(AppFont.body).foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			Text(OnboardingStrings.connectResetHint)
				.font(AppFont.callout).foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			ProgressView().tint(AppColor.accentEmphasis)
			Text(OnboardingStrings.waitingForCamera)
				.font(AppFont.callout).foregroundStyle(AppColor.textSecondary)
			Spacer()
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
		.task { await model.monitor() }
	}

	private var networkLine: String {
		if let ssid = model.ssid { return OnboardingStrings.connectOnNetwork(ssid: ssid) }
		return OnboardingStrings.connectJoinPrompt
	}
}
