//
//  AdaptiveStack.swift
//  CoreUI
//

import SwiftUI

/// Lays its content out horizontally at normal text sizes and vertically at accessibility ones.
///
/// A row of two or three labelled controls is fine until the text triples in size, at which point
/// each one gets a third of the width and starts hyphenating — the gallery's selection bar rendered
/// its Download button as "Down-load" across two lines, beside a Delete button of a different
/// height. Giving each item the full width instead is what Apple's own apps do at these sizes.
///
/// The switch is on `dynamicTypeSize.isAccessibilitySize` rather than `ViewThatFits`, because the
/// buttons and chips this wraps are `maxWidth: .infinity`-greedy: they accept whatever width they
/// are offered, so a horizontal layout always reports that it "fits" and `ViewThatFits` would never
/// fall through.
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
