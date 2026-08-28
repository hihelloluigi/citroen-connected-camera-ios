import CoreConnectivity
import SwiftUI

/// Assembles the rejoin-the-camera screen shown after a password change, and whenever a
/// finished-onboarding user loses the camera.
enum ReconnectBuilder {
	@MainActor
	static func build(advance: any AdvanceOnboardingUseCaseProtocol,
					  connectivity: ConnectivityMonitor) -> some View {
		ReconnectView(model: ReconnectViewModel(connectivity: connectivity, actions: advance))
	}
}
