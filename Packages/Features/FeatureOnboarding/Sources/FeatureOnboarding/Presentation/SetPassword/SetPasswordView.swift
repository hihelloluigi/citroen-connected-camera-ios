import CoreLocalization
import CoreUI
import SwiftUI

struct SetPasswordView: View {
	@Bindable var model: SetPasswordViewModel

	var body: some View {
		VStack(spacing: AppSpacing.lg) {
			Spacer()
			Text(OnboardingStrings.setPasswordTitle)
				.font(AppFont.title).foregroundStyle(AppColor.textPrimary)
				.multilineTextAlignment(.center)
			Text(OnboardingStrings.setPasswordBody)
				.font(AppFont.body).foregroundStyle(AppColor.textSecondary)
				.multilineTextAlignment(.center)
			LabeledField(OnboardingStrings.newPassword, text: $model.newPassword,
						 placeholder: OnboardingStrings.newPasswordPlaceholder, isSecure: true,
						 error: model.validationError)
			LabeledField(OnboardingStrings.confirmPassword, text: $model.confirmPassword, isSecure: true)
			if model.showCurrentPasswordField {
				LabeledField(OnboardingStrings.currentPassword, text: $model.currentPassword, isSecure: true)
			}
			if let submissionError = model.submissionError {
				Text(submissionError).font(AppFont.callout).foregroundStyle(AppColor.danger)
					.multilineTextAlignment(.center)
			}
			Spacer()
			PrimaryButton(OnboardingStrings.setPasswordAction, isLoading: model.isSubmitting) {
				Task { await model.submit() }
			}
		}
		.padding(AppSpacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(AppColor.background)
		.accessibilityElement(children: .contain)
		.accessibilityIdentifier(AccessibilityID.Onboarding.setPassword)
	}
}
