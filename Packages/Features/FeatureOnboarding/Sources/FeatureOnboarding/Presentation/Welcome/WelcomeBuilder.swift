import SwiftUI

/// Assembles the welcome screen.
enum WelcomeBuilder {
	@MainActor
	static func build(advance: any AdvanceOnboardingUseCaseProtocol) -> some View {
		WelcomeView(model: WelcomeViewModel(actions: advance))
	}
}
