import SwiftUI
import AppCore
import CoreUI
import VIRBKit

/// One grid cell: the camera's thumbnail (async, URL-cached), a video/photo badge, and a GPS pin when
/// the item is geotagged. In select mode a checkmark overlays the corner.
struct MediaThumbnailView: View {
    let item: MediaItem
    let isSelecting: Bool
    let isSelected: Bool
    var isDownloading: Bool = false

    var body: some View {
        AsyncImage(url: item.thumbURL) { phase in
            switch phase {
            case .success(let image): image.resizable().aspectRatio(contentMode: .fill)
            case .failure: placeholder(systemImage: "photo")
            default: placeholder(systemImage: "arrow.down.circle")
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
        .overlay(alignment: .bottomLeading) {
            Badge(item.kind == .video ? "Video" : "Photo",
                  systemImage: item.kind == .video ? "video.fill" : "photo.fill")
                .padding(AppSpacing.xs)
        }
        .overlay(alignment: .topTrailing) {
            if item.gpsLatitude != nil {
                Image(systemName: "location.fill")
                    .font(AppFont.caption).foregroundStyle(AppColor.onAccent)
                    .padding(AppSpacing.xxs).background(AppColor.accent, in: Circle())
                    .padding(AppSpacing.xs)
            }
        }
        .overlay(alignment: .topLeading) {
            if isSelecting {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(AppFont.title).foregroundStyle(isSelected ? AppColor.accent : AppColor.textSecondary)
                    .padding(AppSpacing.xs)
            }
        }
        .overlay {
            if isDownloading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(AppColor.accent)
                    .padding(AppSpacing.sm)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.sm))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(GalleryAccessibility.label(for: item))
        .accessibilityAddTraits(isSelecting ? (isSelected ? [.isButton, .isSelected] : .isButton) : .isImage)
        .accessibilityValue(isDownloading ? "Downloading" : "")
    }

    private func placeholder(systemImage: String) -> some View {
        ZStack {
            AppColor.surfaceElevated
            Image(systemName: systemImage).foregroundStyle(AppColor.textSecondary)
        }
    }
}
