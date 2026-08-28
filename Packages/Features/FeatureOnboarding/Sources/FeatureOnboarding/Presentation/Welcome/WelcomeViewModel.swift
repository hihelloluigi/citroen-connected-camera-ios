import Observation

@MainActor
@Observable
final class WelcomeViewModel {
	private let actions: any AdvanceOnboardingUseCaseProtocol
	init(actions: any AdvanceOnboardingUseCaseProtocol) { self.actions = actions }
	func getStarted() { actions.markGetStarted() }
}
