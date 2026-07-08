import SwiftUI
import AVKit
import AppCore
import CoreUI
import VIRBKit

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
		.alert("Couldn't complete that", isPresented: actionErrorBinding) {
			Button("OK", role: .cancel) { model.clearActionError() }
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
		.accessibilityLabel(model.item.kind == .video ? "Video player" : "Photo")
	}

	private var actions: some View {
		HStack(spacing: AppSpacing.md) {
			SecondaryButton(model.didSaveToPhotos ? "Saved" : "Save") { Task { await model.saveToPhotos() } }
			SecondaryButton("Share") {
				Task { if let url = await model.prepareShareURL() { shareItem = ShareItem(url: url) } }
			}
			PrimaryButton("Delete", isLoading: isDeleting) { showDeleteConfirm = true }
		}
		.padding(AppSpacing.md)
		.background(AppColor.surface)
		.confirmationDialog("Delete this recording? This can't be undone.",
							isPresented: $showDeleteConfirm, titleVisibility: .visible) {
			Button("Delete", role: .destructive) {
				Task {
					isDeleting = true
					let deleted = await model.delete()
					isDeleting = false
					if deleted { onDelete?(); dismiss() }
				}
			}
			Button("Cancel", role: .cancel) {}
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
