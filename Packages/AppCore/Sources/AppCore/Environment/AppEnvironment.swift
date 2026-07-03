import VIRBKit

/// The app's composition root: dependencies are built once and passed down. No global singletons.
/// Plan 2 holds the camera client and phone id; services (permissions, connectivity, Wi-Fi) are added
/// by later plans.
public final class AppEnvironment: Sendable {
    public let camera: any VIRBClientProtocol
    public let phoneId: String

    public init(camera: any VIRBClientProtocol, phoneId: String) {
        self.camera = camera
        self.phoneId = phoneId
    }
}
