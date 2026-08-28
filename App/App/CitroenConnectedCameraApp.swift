import CoreConnectivity
import SwiftUI

@main
struct CitroenConnectedCameraApp: App {
	// MARK: - Wrapped Properties

	@State private var composition = AppComposition.live()

	// MARK: - Body

	var body: some Scene {
		WindowGroup {
			RootView(coordinator: composition.coordinator, composition: composition)
				.task {
					await composition.connectivity.refresh()
					composition.routing.ingest(composition.connectivity.snapshot)
				}
		}
	}
}
