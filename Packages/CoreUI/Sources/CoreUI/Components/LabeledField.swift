import SwiftUI

/// A labeled input with optional secure entry and an inline error. Used for the onboarding password
/// fields. The border turns red and the error line appears when `error` is non-nil.
public struct LabeledField: View {
    private let label: String
    private let placeholder: String
    private let isSecure: Bool
    private let error: String?
    @Binding private var text: String

    public init(_ label: String, text: Binding<String>, placeholder: String = "",
                isSecure: Bool = false, error: String? = nil) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.error = error
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label).font(AppFont.caption).foregroundStyle(AppColor.textSecondary)
            field
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .padding(AppSpacing.md)
                .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .strokeBorder(error == nil ? AppColor.separator : AppColor.danger, lineWidth: 1)
                )
            if let error {
                Text(error).font(AppFont.caption).foregroundStyle(AppColor.danger)
            }
        }
    }

    @ViewBuilder private var field: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }
}

#Preview {
    struct Demo: View {
        @State private var pw = ""
        @State private var bad = "short"
        var body: some View {
            VStack(spacing: AppSpacing.lg) {
                LabeledField("New password", text: $pw, placeholder: "At least 8 characters", isSecure: true)
                LabeledField("Current password", text: $bad, isSecure: true,
                             error: "That password wasn't accepted. Try again.")
            }
            .padding()
            .background(AppColor.background)
        }
    }
    return Demo()
}
