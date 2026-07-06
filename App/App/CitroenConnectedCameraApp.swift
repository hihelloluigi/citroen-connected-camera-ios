import SwiftUI
import AppCore

@main
struct CitroenConnectedCameraApp: App {
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView(coordinator: environment.coordinator, environment: environment)
                .task {
                    await environment.connectivity.refresh()
                    environment.routing.ingest(environment.connectivity.snapshot)
                }
        }
    }
}
