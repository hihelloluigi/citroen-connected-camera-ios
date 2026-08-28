import SwiftUI

/// Lays its content out horizontally at normal text sizes and vertically at accessibility ones.
///
/// Switches on `dynamicTypeSize.isAccessibilitySize` rather than using `ViewThatFits`, because the
/// buttons and chips this wraps are `maxWidth: .infinity`-greedy — a horizontal layout always
/// reports that it fits, so `ViewThatFits` would never fall through.
public struct AdaptiveStack<Content: View>: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	private let horizontalAlignment: HorizontalAlignment
	private let spacing: CGFloat
	private let content: Content

	public init(alignment: HorizontalAlignment = .leading,
				spacing: CGFloat = AppSpacing.md,
				@ViewBuilder content: () -> Content) {
		self.horizontalAlignment = alignment
		self.spacing = spacing
		self.content = content()
	}

	public var body: some View {
		if dynamicTypeSize.isAccessibilitySize {
			VStack(alignment: horizontalAlignment, spacing: spacing) { content }
		} else {
			HStack(spacing: spacing) { content }
		}
	}
}
