import SwiftUI
import CoreUI

struct LocationPermissionView: View {
	let model: LocationPermissionViewModel

	var body: some View {
		VStack(spacing: AppSpacing.lg) {
			Spacer()
			Image(systemName: "location")
				.font(.system(size: AppIconSize.large))
				.foregroundStyle(AppColor.accent)
			Text("Allow Location access")
				.font(AppFont.title).foregroundStyle(AppColor.textPrimary)
				.multilineTextAlignment(.center)
			Text(
				"Location lets the app show which Wi‑Fi network you're on, so it can confirm you're connected to the camera. "
					+ "You can skip this — the app still works without it."
			)
				.font(AppFont.body).foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			Spacer()
			if model.isDenied {
				PrimaryButton("Open Settings") { AppSettings.open() }
			} else {
				PrimaryButton("Allow access", isLoading: model.isRequesting) {
					Task { await model.request() }
				}
			}
			SecondaryButton("Not now") { model.skip() }
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
		.task { await model.onAppear() }
	}
}
