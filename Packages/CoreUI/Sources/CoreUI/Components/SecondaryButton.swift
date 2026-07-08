import SwiftUI

/// A lower-emphasis action: outlined, accent-tinted label. Pairs with `PrimaryButton`.
public struct SecondaryButton: View {
	@Environment(\.isEnabled) private var isEnabled
	private let title: String
	private let action: () -> Void

	public init(_ title: String, action: @escaping () -> Void) {
		self.title = title
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			Text(title)
				.font(AppFont.headline)
				.foregroundStyle(AppColor.accent)
				.frame(maxWidth: .infinity)
				.padding(.vertical, AppSpacing.md)
				.overlay(
					RoundedRectangle(cornerRadius: AppRadius.md).strokeBorder(AppColor.accent, lineWidth: 1)
				)
				.opacity(isEnabled ? 1 : AppOpacity.disabled)
		}
		.buttonStyle(PressableButtonStyle())
	}
}

#Preview {
	VStack(spacing: AppSpacing.lg) {
		SecondaryButton("Not now") {}
		SecondaryButton("Disabled") {}.disabled(true)
	}
	.padding()
	.background(AppColor.background)
}
