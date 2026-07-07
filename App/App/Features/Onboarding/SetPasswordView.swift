import SwiftUI
import CoreUI

struct SetPasswordView: View {
    @Bindable var model: SetPasswordViewModel

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Text("Set a new camera password")
                .font(AppFont.title).foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            Text("Choose a new Wi‑Fi password for the camera. You'll reconnect with it in a moment.")
                .font(AppFont.body).foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            LabeledField("New password", text: $model.newPassword,
                         placeholder: "At least 8 characters", isSecure: true,
                         error: model.validationError)
            LabeledField("Confirm password", text: $model.confirmPassword, isSecure: true)
            if model.showCurrentPasswordField {
                LabeledField("Current password", text: $model.currentPassword, isSecure: true)
            }
            if let submissionError = model.submissionError {
                Text(submissionError).font(AppFont.callout).foregroundStyle(AppColor.danger)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            PrimaryButton("Set password", isLoading: model.isSubmitting) {
                Task { await model.submit() }
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
