import CoreConnectivity
import SwiftUI

@main
struct CitroenConnectedCameraApp: App {
	@State private var composition = AppComposition.live()

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
