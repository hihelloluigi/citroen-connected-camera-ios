import AppCore
import Observation

@MainActor
@Observable
final class WelcomeViewModel {
    private let actions: OnboardingActions
    init(actions: OnboardingActions) { self.actions = actions }
    func getStarted() { actions.markGetStarted() }
}
