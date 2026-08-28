import CoreCamera
import CoreConnectivity
import CoreDomain
import CoreNavigation
import SwiftUI

/// What the onboarding screens need from the app shell, gathered so a builder takes one parameter
/// instead of six.
public struct OnboardingDependencies {
	let flagsStore: any OnboardingFlagsStore
	let camera: any VIRBClientProtocol
	let permissions: any PermissionsService
	let wifiInfo: any WiFiInfoService
	let connectivity: ConnectivityMonitor

	public init(flagsStore: any OnboardingFlagsStore,
				camera: any VIRBClientProtocol,
				permissions: any PermissionsService,
				wifiInfo: any WiFiInfoService,
				connectivity: ConnectivityMonitor) {
		self.flagsStore = flagsStore
		self.camera = camera
		self.permissions = permissions
		self.wifiInfo = wifiInfo
		self.connectivity = connectivity
	}
}

/// The feature's entry point: builds whichever onboarding screen `step` names.
///
/// Known variance — this feature has no `Coordinator/`, because its whole navigation state is one
/// `OnboardingStep` the shell already routes. See the module README.
public enum OnboardingBuilder {
	@MainActor
	public static func build(step: OnboardingStep,
							 dependencies: OnboardingDependencies,
							 onAction: @escaping NavigationActionHandler<OnboardingNavigationAction>) -> some View {
		let advance = AdvanceOnboardingUseCase(
			store: dependencies.flagsStore,
			camera: dependencies.camera,
			onAction: onAction
		)
		return Group {
			switch step {
			case .welcome:
				WelcomeBuilder.build(advance: advance)
			case .localNetworkPermission:
				LocalNetworkPermissionBuilder.build(advance: advance)
			case .locationPermission:
				LocationPermissionBuilder.build(advance: advance, permissions: dependencies.permissions)
			case .connectWiFi:
				ConnectWiFiBuilder.build(advance: advance,
										 wifiInfo: dependencies.wifiInfo,
										 connectivity: dependencies.connectivity)
			case .setPassword:
				SetPasswordBuilder.build(advance: advance)
			case .reconnect:
				ReconnectBuilder.build(advance: advance, connectivity: dependencies.connectivity)
			}
		}
	}
}
