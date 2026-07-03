import SwiftUI
import AppCore

@main
struct CitroenConnectedCameraApp: App {
    @State private var coordinator = AppCoordinator()
    private let environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator, environment: environment)
        }
    }
}
