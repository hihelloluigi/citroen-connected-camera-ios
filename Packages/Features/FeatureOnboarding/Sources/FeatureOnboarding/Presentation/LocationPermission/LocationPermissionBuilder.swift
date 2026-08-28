//
//  LocationPermissionBuilder.swift
//  FeatureOnboarding
//

import CoreDomain
import SwiftUI

/// Assembles the Location permission screen.
enum LocationPermissionBuilder {
	@MainActor
	static func build(advance: any AdvanceOnboardingUseCaseProtocol,
					  permissions: any PermissionsService) -> some View {
		LocationPermissionView(model: LocationPermissionViewModel(permissions: permissions, actions: advance))
	}
}
