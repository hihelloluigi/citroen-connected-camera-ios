import AppCore
import Observation

@MainActor
@Observable
final class ConnectWiFiViewModel {
    private let wifiInfo: any WiFiInfoService
    private let connectivity: ConnectivityMonitor
    private let actions: OnboardingActions
    /// The joined network name, or `nil` when Location is denied (degrade to "Camera detected").
    private(set) var ssid: String?

    init(wifiInfo: any WiFiInfoService, connectivity: ConnectivityMonitor, actions: OnboardingActions) {
        self.wifiInfo = wifiInfo
        self.connectivity = connectivity
        self.actions = actions
    }

    /// Reads the network name once, then polls the camera every 2s. Each probe is fed into routing; the
    /// router leaves this screen as soon as the camera is reachable. Runs until the enclosing `.task` is
    /// cancelled (SwiftUI cancels it when the view leaves the hierarchy on the route change).
    func monitor() async {
        ssid = await wifiInfo.currentSSID()
        while !Task.isCancelled {
            await connectivity.refresh()
            await actions.applyConnectivity(connectivity.snapshot)
            try? await Task.sleep(for: .seconds(2))
        }
    }
}
