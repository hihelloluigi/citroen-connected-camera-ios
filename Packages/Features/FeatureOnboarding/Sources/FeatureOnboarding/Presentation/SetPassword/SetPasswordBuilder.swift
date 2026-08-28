//
//  SetPasswordBuilder.swift
//  FeatureOnboarding
//

import SwiftUI

/// Assembles the change-the-camera-password screen.
enum SetPasswordBuilder {
	@MainActor
	static func build(advance: any AdvanceOnboardingUseCaseProtocol) -> some View {
		SetPasswordView(model: SetPasswordViewModel(actions: advance))
	}
}
