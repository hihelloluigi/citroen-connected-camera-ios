import SwiftUI
import CoreUI
import VIRBKit

/// A compact camera-status strip above the grid: storage/format warning, GPS fix, active-phone note.
/// Tapping opens a details sheet with the camera's firmware, part number, and device id.
struct StatusHeaderView: View {
    let status: CameraStatus
    let loadDevice: () async -> DeviceInfo?

    @State private var showingDetails = false
    @State private var device: DeviceInfo?

    var body: some View {
        Button {
            showingDetails = true
        } label: {
            HStack(spacing: AppSpacing.md) {
                chip(status.needsFormat ? "SD needs formatting" : "SD ready",
                     systemImage: status.needsFormat ? "exclamationmark.triangle.fill" : "sdcard.fill")
                chip(status.gpsLatitude != nil ? "GPS fix" : "No GPS",
                     systemImage: "location.fill")
                Spacer()
                Image(systemName: "info.circle").foregroundStyle(AppColor.textSecondary)
            }
            .padding(AppSpacing.md)
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Camera status")
        .accessibilityHint("Shows camera details")
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
            Text("Camera details").font(AppFont.title).foregroundStyle(AppColor.textPrimary)
            if let device {
                row("Firmware", "\(device.firmware)")
                row("Part number", device.partNumber)
                row("Device ID", "\(device.deviceId)")
            } else {
                Text("Reading camera details…").font(AppFont.body).foregroundStyle(AppColor.textSecondary)
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
