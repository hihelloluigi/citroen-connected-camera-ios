import CoreLocalization
import CoreUI
import SwiftUI

/// A compact camera-status strip above the grid: storage/format warning, GPS fix, active-phone note.
/// Tapping opens a details sheet with the camera's firmware, part number, and device id.
struct StatusHeaderView: View {
	let status: CameraStatusEntity
	let loadDevice: () async -> DeviceInfoEntity?

	@State private var showingDetails = false
	@State private var device: DeviceInfoEntity?

	var body: some View {
		Button {
			showingDetails = true
		} label: {
			HStack(alignment: .top, spacing: AppSpacing.md) {
				AdaptiveStack(spacing: AppSpacing.md) {
					chip(status.needsFormat ? GalleryStrings.statusSDNeedsFormat : GalleryStrings.statusSDReady,
						 systemImage: status.needsFormat ? "exclamationmark.triangle.fill" : "sdcard.fill")
					chip(status.hasGPSFix ? GalleryStrings.statusGPSFix : GalleryStrings.statusNoGPS,
						 systemImage: "location.fill")
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				// Outside the AdaptiveStack on purpose: the glyph is an affordance for the whole
				// row, so it stays pinned top-trailing rather than becoming a third stacked item.
				Image(systemName: "info.circle").foregroundStyle(AppColor.textSecondary)
			}
			.padding(AppSpacing.md)
			.background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
		}
		.buttonStyle(.plain)
		.accessibilityLabel(GalleryStrings.statusAccessibilityLabel)
		.accessibilityHint(GalleryStrings.statusAccessibilityHint)
		.sheet(isPresented: $showingDetails) {
			// The load lives on the sheet, not on the header. The gallery's 3s poll reassigns
			// `model.status`, which rebuilds this header and resets `device` to nil — so a task
			// attached up here raced the poll and the sheet showed "Reading camera details…"
			// indefinitely. The sheet is also the only thing that reads the value.
			detailsSheet.task { device = await loadDevice() }
		}
	}

	private func chip(_ text: String, systemImage: String) -> some View {
		Label(text, systemImage: systemImage)
			.font(AppFont.caption).foregroundStyle(AppColor.textSecondary)
			.fixedSize(horizontal: false, vertical: true)
	}

	private var detailsSheet: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: AppSpacing.md) {
				Text(GalleryStrings.cameraDetails).font(AppFont.title).foregroundStyle(AppColor.textPrimary)
				if let device {
					row(GalleryStrings.firmware, "\(device.firmware)")
					row(GalleryStrings.partNumber, device.partNumber)
					row(GalleryStrings.deviceID, "\(device.deviceId)")
				} else {
					Text(GalleryStrings.readingDetails).font(AppFont.body).foregroundStyle(AppColor.textSecondary)
				}
			}
			.padding(AppSpacing.xl)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.scrollBounceBehavior(.basedOnSize)
		.background(AppColor.background)
		// Both detents, not just .medium: at accessibility sizes three labelled rows do not fit a
		// half sheet, and a fixed .medium clipped the title. The user can still start at half
		// height and drag up.
		.presentationDetents([.medium, .large])
	}

	private func row(_ label: String, _ value: String) -> some View {
		AdaptiveStack(spacing: AppSpacing.xxs) {
			Text(label).font(AppFont.body).foregroundStyle(AppColor.textSecondary)
			Spacer(minLength: 0)
			Text(value).font(AppFont.body).foregroundStyle(AppColor.textPrimary)
				.fixedSize(horizontal: false, vertical: true)
		}
	}
}
