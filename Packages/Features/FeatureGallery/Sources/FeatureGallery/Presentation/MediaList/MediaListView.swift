import CoreLocalization
import CoreUI
import SwiftUI

struct MediaListView: View {
	@Bindable var model: MediaListViewModel
	let loadDevice: () async -> DeviceInfoEntity?

	private let columns = [GridItem(.adaptive(minimum: AppSize.gridCellMin), spacing: AppSpacing.xs)]

	var body: some View {
		content
			.navigationTitle(GalleryStrings.title)
			.toolbar { toolbarContent }
			.task { await model.load() }
			.refreshable { await model.refresh() }
			.safeAreaInset(edge: .bottom) { if model.isSelecting { selectionBar } }
			.alert(CommonStrings.actionFailedTitle, isPresented: actionErrorBinding) {
				Button(CommonStrings.openSettings) { AppSettings.open() }
				Button(CommonStrings.ok, role: .cancel) { model.clearActionError() }
			} message: {
				Text(model.actionError?.message ?? "")
			}
	}

	@ViewBuilder private var content: some View {
		switch model.state {
		case .idle, .loading:
			ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(AppColor.background)
		case .failed(let error):
			ErrorStateView(error.message) { Task { await model.load() } }
		case .loaded(let items) where items.isEmpty:
			EmptyStateView(GalleryStrings.emptyTitle,
						   message: GalleryStrings.emptyBody,
						   systemImage: "camera")
		case .loaded:
			grid
		}
	}

	private var grid: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: AppSpacing.md) {
				if let status = model.status {
					StatusHeaderView(status: status, loadDevice: loadDevice)
				}
				ForEach(MediaGrouping.sections(from: model.items)) { section in
					Text(section.title).font(AppFont.headline).foregroundStyle(AppColor.textPrimary)
						.padding(.top, AppSpacing.sm)
					LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
						ForEach(section.items) { item in cell(item) }
					}
				}
			}
			.padding(AppSpacing.md)
		}
		.background(AppColor.background)
	}

	@ViewBuilder private func cell(_ item: MediaEntity) -> some View {
		let thumb = MediaThumbnailView(item: item, isSelecting: model.isSelecting,
									   isSelected: model.selection.contains(item.id),
									   isDownloading: model.downloadingIDs.contains(item.id))
		if model.isSelecting {
			Button { model.toggle(item.id) } label: { thumb }.buttonStyle(.plain)
		} else {
			Button { model.select(item) } label: { thumb }.buttonStyle(.plain)
		}
	}

	@ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
		ToolbarItemGroup(placement: .primaryAction) {
			if model.isSelecting {
				Button(CommonStrings.done) { model.setSelecting(false) }
			} else {
				Button { Task { await model.snapshot() } } label: { Image(systemName: "camera.fill") }
					.accessibilityLabel(GalleryStrings.takePhoto)
				Button(CommonStrings.select) { model.setSelecting(true) }
			}
		}
	}

	private var selectionBar: some View {
		HStack(spacing: AppSpacing.md) {
			SecondaryButton(CommonStrings.download) { Task { await model.downloadSelected() } }
			PrimaryButton(CommonStrings.delete, isLoading: isDeleting) { showDeleteConfirm = true }
		}
		.padding(AppSpacing.md)
		.background(.ultraThinMaterial)
		.disabled(model.selection.isEmpty)
		.confirmationDialog(GalleryStrings.deleteConfirm(count: model.selection.count),
							isPresented: $showDeleteConfirm, titleVisibility: .visible) {
			Button(CommonStrings.delete, role: .destructive) {
				Task { isDeleting = true; await model.deleteSelected(); isDeleting = false }
			}
			Button(CommonStrings.cancel, role: .cancel) {}
		}
	}

	@State private var showDeleteConfirm = false
	@State private var isDeleting = false

	private var actionErrorBinding: Binding<Bool> {
		Binding(get: { model.actionError != nil }, set: { if !$0 { model.clearActionError() } })
	}
}
