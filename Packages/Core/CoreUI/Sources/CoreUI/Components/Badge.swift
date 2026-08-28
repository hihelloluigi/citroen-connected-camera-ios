import SwiftUI

/// A small pill label with an optional SF Symbol — e.g. a VIDEO/PHOTO tag on a gallery cell, or a
/// status chip. Uppercased, tight, on a subtle surface.
public struct Badge: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	private let text: String
	private let systemImage: String?

	public init(_ text: String, systemImage: String? = nil) {
		self.text = text
		self.systemImage = systemImage
	}

	public var body: some View {
		HStack(spacing: AppSpacing.xs) {
			if let systemImage { Image(systemName: systemImage) }
			// At accessibility sizes the label cannot fit the surface a badge sits on — over a
			// gallery cell it truncated to "V…". The symbol carries the same meaning, and the
			// cell's own accessibility label still speaks the full word.
			if !(dynamicTypeSize.isAccessibilitySize && systemImage != nil) {
				Text(text.uppercased())
			}
		}
		.font(AppFont.caption.weight(.semibold))
		.foregroundStyle(AppColor.textPrimary)
		.padding(.horizontal, AppSpacing.sm)
		.padding(.vertical, AppSpacing.xxs)
		.background(AppColor.surfaceElevated, in: Capsule())
		.overlay(Capsule().strokeBorder(AppColor.separator, lineWidth: 1))
	}
}

#Preview {
	HStack(spacing: AppSpacing.sm) {
		Badge("Video", systemImage: "video.fill")
		Badge("Photo", systemImage: "photo.fill")
		Badge("Incident", systemImage: "exclamationmark.triangle.fill")
	}
	.padding()
	.background(AppColor.background)
}
