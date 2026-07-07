import SwiftUI
import CoreUI

struct ConnectWiFiView: View {
    let model: ConnectWiFiViewModel

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: "wifi.router")
                .font(.system(size: AppIconSize.large))
                .foregroundStyle(AppColor.accent)
            Text("Connect to the camera's Wi‑Fi")
                .font(AppFont.title).foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(networkLine)
                .font(AppFont.body).foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Text("In Settings › Wi‑Fi, join the camera's network using the password " +
                 "\u{201C}ConnectedCam\u{201D}, then come back here.")
                .font(AppFont.body).foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Text("New camera? Hold both buttons for 2 seconds until it beeps to factory reset. " +
                 "This erases all recordings on the camera.")
                .font(AppFont.callout).foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            ProgressView().tint(AppColor.accent)
            Text("Waiting for the camera…")
                .font(AppFont.callout).foregroundStyle(AppColor.textSecondary)
            Spacer()
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .task { await model.monitor() }
    }

    private var networkLine: String {
        if let ssid = model.ssid { return "You're on \(ssid). Join the camera's network (ConnectedCAM…) if you haven't." }
        return "Join the camera's network — it's named ConnectedCAM followed by four digits."
    }
}
