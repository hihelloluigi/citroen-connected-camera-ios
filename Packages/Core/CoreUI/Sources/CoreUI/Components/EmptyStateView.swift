import SwiftUI

/// A centered empty state — an invitation to act, not a dead end. Used for an empty gallery, etc.
public struct EmptyStateView: View {
	private let title: String
	private let message: String
	private let systemImage: String

	public init(_ title: String, message: String, systemImage: String = "tray") {
		self.title = title
		self.message = message
		self.systemImage = systemImage
	}

	public var body: some View {
		VStack(spacing: AppSpacing.sm) {
			Image(systemName: systemImage)
				.font(.system(size: AppIconSize.large))
				.foregroundStyle(AppColor.textSecondary)
			Text(title).font(AppFont.headline).foregroundStyle(AppColor.textPrimary)
			Text(message)
				.font(AppFont.callout)
				.foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
	}
}

#Preview {
	EmptyStateView("No recordings yet", message: "Clips you capture on the camera will show up here.")
}
