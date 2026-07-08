import SwiftUI
import CoreUI

struct WelcomeView: View {
	let model: WelcomeViewModel

	var body: some View {
		VStack(spacing: AppSpacing.lg) {
			Spacer()
			Image(systemName: "camera.fill")
				.font(.system(size: AppIconSize.large))
				.foregroundStyle(AppColor.accent)
			Text("Your dashcam, on your phone")
				.font(AppFont.displayLarge)
				.foregroundStyle(AppColor.textPrimary)
				.multilineTextAlignment(.center)
			Text("Browse, download, and manage recordings from your Citroën ConnectedCAM over its own Wi‑Fi.")
				.font(AppFont.body)
				.foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			Spacer()
			PrimaryButton("Get started") { model.getStarted() }
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
	}
}
