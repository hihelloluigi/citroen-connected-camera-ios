//
//  ConnectWiFiBuilder.swift
//  FeatureOnboarding
//

import CoreConnectivity
import SwiftUI

/// Assembles the "join the camera's Wi-Fi" screen.
enum ConnectWiFiBuilder {
	@MainActor
	static func build(advance: any AdvanceOnboardingUseCaseProtocol,
					  wifiInfo: any WiFiInfoService,
					  connectivity: ConnectivityMonitor) -> some View {
		ConnectWiFiView(model: ConnectWiFiViewModel(
			wifiInfo: wifiInfo, connectivity: connectivity, actions: advance))
	}
}
