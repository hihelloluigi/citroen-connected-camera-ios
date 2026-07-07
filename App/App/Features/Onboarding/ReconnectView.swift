import SwiftUI
import CoreUI

struct ReconnectView: View {
    let model: ReconnectViewModel

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: AppIconSize.large))
                .foregroundStyle(AppColor.accent)
            Text("Reconnect to the camera")
                .font(AppFont.title).foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            Text("The camera restarted its Wi‑Fi with the new password. In Settings › Wi‑Fi, rejoin the " +
                 "camera's network using the password you just set.")
                .font(AppFont.body).foregroundStyle(AppColor.textSecondary)
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
}
