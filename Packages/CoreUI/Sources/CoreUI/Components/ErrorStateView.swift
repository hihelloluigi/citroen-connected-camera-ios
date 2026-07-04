import SwiftUI

/// A centered error state with an optional retry. The message says what happened and how to recover;
/// it speaks in the interface's voice, not an apology. Used wherever a load or command fails.
public struct ErrorStateView: View {
    private let message: String
    private let systemImage: String
    private let retryTitle: String
    private let retry: (() -> Void)?

    public init(_ message: String, systemImage: String = "exclamationmark.triangle",
                retryTitle: String = "Try again", retry: (() -> Void)? = nil) {
        self.message = message
        self.systemImage = systemImage
        self.retryTitle = retryTitle
        self.retry = retry
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: systemImage)
                .font(.system(size: AppIconSize.large))
                .foregroundStyle(AppColor.danger)
            Text(message)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            if let retry {
                PrimaryButton(retryTitle, action: retry).fixedSize()
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}

#Preview {
    ErrorStateView("Lost connection to the camera. Check you're on its Wi‑Fi.") {}
}
