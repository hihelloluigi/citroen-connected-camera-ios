import AVKit
import CoreLocalization
import CoreUI
import SwiftUI

struct MediaDetailView: View {
	@Bindable var model: MediaDetailViewModel
	var onDelete: (() -> Void)?
	@Environment(\.dismiss) private var dismiss

	@State private var shareItem: ShareItem?
	@State private var showDeleteConfirm = false
	@State private var zoom: CGFloat = 1
	@State private var isDeleting = false

	var body: some View {
		VStack(spacing: 0) {
			viewer
			actions
		}
		.background(AppColor.background)
		.navigationTitle(model.item.name)
		.navigationBarTitleDisplayMode(.inline)
		.alert(CommonStrings.actionFailedTitle, isPresented: actionErrorBinding) {
			Button(CommonStrings.ok, role: .cancel) { model.clearActionError() }
		} message: {
			Text(model.actionError?.message ?? "")
		}
		.sheet(item: $shareItem) { item in ShareSheet(url: item.url) }
	}

	private var viewer: some View {
		Group {
			if model.item.kind == .video {
				VideoPlayer(player: AVPlayer(url: model.item.url))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				ScrollView([.horizontal, .vertical]) {
					AsyncImage(url: model.item.url) { image in
						image.resizable().aspectRatio(contentMode: .fit).scaleEffect(zoom)
					} placeholder: {
						ProgressView()
					}
					.gesture(MagnificationGesture().onChanged { zoom = $0 }.onEnded { _ in
						withAnimation { zoom = max(1, min(zoom, 4)) }
					})
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.accessibilityLabel(model.item.kind == .video ? GalleryStrings.videoPlayer : GalleryStrings.photo)
	}

	private var actions: some View {
		HStack(spacing: AppSpacing.md) {
			SecondaryButton(model.didSaveToPhotos ? CommonStrings.saved : CommonStrings.save) { Task { await model.saveToPhotos() } }
			SecondaryButton(CommonStrings.share) {
				Task { if let url = await model.prepareShareURL() { shareItem = ShareItem(url: url) } }
			}
			PrimaryButton(CommonStrings.delete, isLoading: isDeleting) { showDeleteConfirm = true }
		}
		.padding(AppSpacing.md)
		.background(AppColor.surface)
		.confirmationDialog(GalleryStrings.deleteOneConfirm,
							isPresented: $showDeleteConfirm, titleVisibility: .visible) {
			Button(CommonStrings.delete, role: .destructive) {
				Task {
					isDeleting = true
					let deleted = await model.delete()
					isDeleting = false
					if deleted { onDelete?(); dismiss() }
				}
			}
			Button(CommonStrings.cancel, role: .cancel) {}
		}
	}

	private var actionErrorBinding: Binding<Bool> {
		Binding(get: { model.actionError != nil }, set: { if !$0 { model.clearActionError() } })
	}
}

/// A downloaded file ready to share (wrapped so `.sheet(item:)` has a stable `Identifiable` without a
/// retroactive conformance on `URL`).
private struct ShareItem: Identifiable {
	let id = UUID()
	let url: URL
}

/// Wraps `UIActivityViewController` for the system share sheet.
private struct ShareSheet: UIViewControllerRepresentable {
	let url: URL
	func makeUIViewController(context: Context) -> UIActivityViewController {
		UIActivityViewController(activityItems: [url], applicationActivities: nil)
	}
	func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
