import SwiftUI

/// The main call-to-action: a full-width filled amber button. Shows a spinner and blocks taps while
/// `isLoading` (e.g. during a password change), and dims when disabled via the environment.
public struct PrimaryButton: View {
    @Environment(\.isEnabled) private var isEnabled
    private let title: String
    private let isLoading: Bool
    private let action: () -> Void

    public init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Text(title).opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView().tint(AppColor.onAccent) }
            }
            .font(AppFont.headline)
            .foregroundStyle(AppColor.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppColor.accent, in: RoundedRectangle(cornerRadius: AppRadius.md))
            .opacity(isEnabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(isLoading || !isEnabled)
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton("Get started") {}
        PrimaryButton("Saving…", isLoading: true) {}
        PrimaryButton("Disabled") {}.disabled(true)
    }
    .padding()
    .background(AppColor.background)
}
