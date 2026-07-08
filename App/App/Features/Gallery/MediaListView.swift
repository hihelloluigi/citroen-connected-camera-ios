import SwiftUI
import AppCore
import CoreUI
import VIRBKit

struct MediaListView: View {
    @Bindable var model: MediaListViewModel
    let loadDevice: () async -> DeviceInfo?

    private let columns = [GridItem(.adaptive(minimum: AppSize.gridCellMin), spacing: AppSpacing.xs)]

    var body: some View {
        content
            .navigationTitle("Recordings")
            .toolbar { toolbarContent }
            .task { await model.load() }
            .refreshable { await model.refresh() }
            .safeAreaInset(edge: .bottom) { if model.isSelecting { selectionBar } }
            .alert("Couldn't complete that", isPresented: actionErrorBinding) {
                Button("Open Settings") { AppSettings.open() }
                Button("OK", role: .cancel) { model.clearActionError() }
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
            EmptyStateView("No recordings yet",
                           message: "Recordings from your camera show up here. Tap the shutter to take a photo.",
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

    @ViewBuilder private func cell(_ item: MediaItem) -> some View {
        let thumb = MediaThumbnailView(item: item, isSelecting: model.isSelecting,
                                       isSelected: model.selection.contains(item.id),
                                       progress: model.downloadProgress[item.id])
        if model.isSelecting {
            Button { model.toggle(item.id) } label: { thumb }.buttonStyle(.plain)
        } else {
            NavigationLink(value: item) { thumb }.buttonStyle(.plain)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if model.isSelecting {
                Button("Done") { model.setSelecting(false) }
            } else {
                Button { Task { await model.snapshot() } } label: { Image(systemName: "camera.fill") }
                Button("Select") { model.setSelecting(true) }
            }
        }
    }

    private var selectionBar: some View {
        HStack(spacing: AppSpacing.md) {
            SecondaryButton("Download") { Task { await model.downloadSelected() } }
            PrimaryButton("Delete", isLoading: isDeleting) { showDeleteConfirm = true }
        }
        .padding(AppSpacing.md)
        .background(.ultraThinMaterial)
        .disabled(model.selection.isEmpty)
        .confirmationDialog("Delete \(model.selection.count) item(s)? This can't be undone.",
                            isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task { isDeleting = true; await model.deleteSelected(); isDeleting = false }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @State private var showDeleteConfirm = false
    @State private var isDeleting = false

    private var actionErrorBinding: Binding<Bool> {
        Binding(get: { model.actionError != nil }, set: { if !$0 { model.clearActionError() } })
    }
}
