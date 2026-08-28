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
			HStack(spacing: AppSpacing.md) {
				chip(status.needsFormat ? GalleryStrings.statusSDNeedsFormat : GalleryStrings.statusSDReady,
					 systemImage: status.needsFormat ? "exclamationmark.triangle.fill" : "sdcard.fill")
				chip(status.hasGPSFix ? GalleryStrings.statusGPSFix : GalleryStrings.statusNoGPS,
					 systemImage: "location.fill")
				Spacer()
				Image(systemName: "info.circle").foregroundStyle(AppColor.textSecondary)
			}
			.padding(AppSpacing.md)
			.background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
		}
		.buttonStyle(.plain)
		.accessibilityLabel(GalleryStrings.statusAccessibilityLabel)
		.accessibilityHint(GalleryStrings.statusAccessibilityHint)
		.task { device = await loadDevice() }
		.sheet(isPresented: $showingDetails) {
			detailsSheet
		}
	}

	private func chip(_ text: String, systemImage: String) -> some View {
		Label(text, systemImage: systemImage)
			.font(AppFont.caption).foregroundStyle(AppColor.textSecondary)
	}

	private var detailsSheet: some View {
		VStack(alignment: .leading, spacing: AppSpacing.md) {
			Text(GalleryStrings.cameraDetails).font(AppFont.title).foregroundStyle(AppColor.textPrimary)
			if let device {
				row(GalleryStrings.firmware, "\(device.firmware)")
				row(GalleryStrings.partNumber, device.partNumber)
				row(GalleryStrings.deviceID, "\(device.deviceId)")
			} else {
				Text(GalleryStrings.readingDetails).font(AppFont.body).foregroundStyle(AppColor.textSecondary)
			}
			Spacer()
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(AppColor.background)
		.presentationDetents([.medium])
	}

	private func row(_ label: String, _ value: String) -> some View {
		HStack {
			Text(label).font(AppFont.body).foregroundStyle(AppColor.textSecondary)
			Spacer()
			Text(value).font(AppFont.body).foregroundStyle(AppColor.textPrimary)
		}
	}
}
