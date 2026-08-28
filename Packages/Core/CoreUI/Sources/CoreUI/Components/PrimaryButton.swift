import SwiftUI

/// The main call-to-action: a full-width filled brand button. Shows a spinner and blocks taps while
/// `isLoading` (e.g. during a password change), and dims when disabled via the environment.
public struct PrimaryButton: View {
	@Environment(\.isEnabled) private var isEnabled
	private let title: String
	private let isLoading: Bool
	private let action: () -> Void

	public init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
		self.title = title
		self.isLoading = isLoading
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			ZStack {
				Text(title).opacity(isLoading ? 0 : 1)
				if isLoading { ProgressView().tint(AppColor.onAccent) }
			}
			.font(AppFont.headline)
			.foregroundStyle(AppColor.onAccent)
			.frame(maxWidth: .infinity)
			.padding(.vertical, AppSpacing.md)
			.background(AppColor.accent, in: RoundedRectangle(cornerRadius: AppRadius.md))
			// The brand fill is a pale periwinkle that barely separates from the light background;
			// this hairline gives the CTA an edge. In dark mode `accentEmphasis` *is* the fill, so it
			// disappears there — where the fill already contrasts with the background on its own.
			.overlay(RoundedRectangle(cornerRadius: AppRadius.md)
				.strokeBorder(AppColor.accentEmphasis, lineWidth: 1))
			.opacity(isEnabled ? 1 : AppOpacity.disabled)
		}
		.buttonStyle(PressableButtonStyle())
		.disabled(isLoading || !isEnabled)
	}
}

#Preview {
	VStack(spacing: AppSpacing.lg) {
		PrimaryButton("Get started") {}
		PrimaryButton("Saving…", isLoading: true) {}
		PrimaryButton("Disabled") {}.disabled(true)
	}
	.padding()
	.background(AppColor.background)
}
