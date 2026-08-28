//
//  LocalNetworkPermissionBuilder.swift
//  FeatureOnboarding
//

import SwiftUI

/// Assembles the Local Network explainer. The screen has no ViewModel: iOS exposes no way to query
/// or pre-request Local Network access, so there is no state to hold — the single button records the
/// step and moves on.
enum LocalNetworkPermissionBuilder {
	@MainActor
	static func build(advance: any AdvanceOnboardingUseCaseProtocol) -> some View {
		LocalNetworkPermissionView(actions: advance)
	}
}
