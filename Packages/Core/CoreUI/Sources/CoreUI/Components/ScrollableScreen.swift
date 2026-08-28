//
//  ScrollableScreen.swift
//  CoreUI
//

import SwiftUI

/// A full-screen container that centres its content when it fits and scrolls when it does not.
///
/// The onboarding screens are built as a `VStack` with `Spacer()`s top and bottom, which distributes
/// the content beautifully at normal text sizes and truncates it at large ones — at AX5 the welcome
/// screen's body copy ended mid-word with an ellipsis and there was no way to read the rest. Making
/// the fonts scale is only half of Dynamic Type support; the layout has to have somewhere for the
/// extra height to go.
///
/// `minHeight: proxy.size.height` is what keeps the small-text layout identical: the content still
/// fills the screen, so the `Spacer()`s still distribute exactly as before, and the `ScrollView`
/// only ever engages once the content genuinely outgrows the viewport.
/// `.scrollBounceBehavior(.basedOnSize)` stops it bouncing when there is nothing to scroll.
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
