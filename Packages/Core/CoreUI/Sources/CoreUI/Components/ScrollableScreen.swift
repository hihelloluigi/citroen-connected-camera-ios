import SwiftUI

/// A full-screen container that centres its content when it fits and scrolls when it does not.
///
/// `minHeight: proxy.size.height` is what keeps the small-text layout identical — the content still
/// fills the screen, so any `Spacer()`s inside still distribute, and the `ScrollView` only engages
/// once the content outgrows the viewport.
public struct ScrollableScreen<Content: View>: View {
	private let content: Content

	public init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	public var body: some View {
		GeometryReader { proxy in
			ScrollView {
				content.frame(minHeight: proxy.size.height)
			}
			.scrollBounceBehavior(.basedOnSize)
		}
	}
}
