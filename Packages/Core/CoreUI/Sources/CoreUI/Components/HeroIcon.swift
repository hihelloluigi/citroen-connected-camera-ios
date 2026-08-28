import SwiftUI

/// The large SF Symbol that heads an onboarding screen or an empty state.
///
/// Exists to own one `@ScaledMetric`: a symbol sized with `.font(.system(size:))` does not scale
/// with Dynamic Type, and `@ScaledMetric` needs a `View` to live in.
public struct HeroIcon: View {
	@ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = AppIconSize.large
	private let systemName: String

	public init(_ systemName: String) {
		self.systemName = systemName
	}

	public var body: some View {
		Image(systemName: systemName)
			.font(.system(size: size))
	}
}

#Preview {
	VStack(spacing: AppSpacing.lg) {
		HeroIcon("camera.fill").foregroundStyle(AppColor.accentEmphasis)
		HeroIcon("wifi").foregroundStyle(AppColor.accentEmphasis)
	}
	.padding()
	.background(AppColor.background)
}
