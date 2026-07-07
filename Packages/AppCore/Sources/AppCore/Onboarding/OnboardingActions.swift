import VIRBKit

/// The onboarding flag mutations and camera-driven steps the screens trigger. Each persists the new
/// flags and/or pushes state into routing, so a tap both survives relaunch and moves the flow forward.
/// Pure of any UI.
@MainActor
public final class OnboardingActions {
    private let store: any OnboardingFlagsStore
    private let routing: RoutingController
    private let camera: any VIRBClientProtocol

    public init(store: any OnboardingFlagsStore, routing: RoutingController, camera: any VIRBClientProtocol) {
        self.store = store
        self.routing = routing
        self.camera = camera
    }

    // MARK: - Flag steps (states 0–2)

    public func markGetStarted() { mutate { $0.hasTappedGetStarted = true } }
    public func markLocalNetworkResolved() { mutate { $0.localNetworkResolved = true } }
    public func markLocationResolved() { mutate { $0.locationResolved = true } }

    // MARK: - Camera-driven steps (states 4–6)

    /// Changes the camera's Wi‑Fi password. On success the camera kicks clients, so we pin the route to
    /// Reconnect; on `.passwordRejected` (and any other camera error) we rethrow and leave the route put
    /// so the screen can show the current-password recovery field.
    public func changePassword(current: String, new: String) async throws {
        try await camera.setWiFiPassword(current: current, new: new)
        routing.markPasswordChanged()
    }

    /// The camera is reachable again after a password change; release the Reconnect pin so routing can
    /// move on from the fresh connectivity snapshot.
    public func finishReconnect() { routing.clearPasswordChanged() }

    /// Feeds a fresh connectivity snapshot into routing, and — when the camera is reachable with setup
    /// complete and onboarding hasn't been recorded yet — finalizes onboarding (claim active phone +
    /// persist the completion flag) so the flow lands in the Gallery and a relaunch skips onboarding.
    public func applyConnectivity(_ snapshot: ConnectivitySnapshot) async {
        routing.ingest(snapshot)
        if snapshot.isReachable, snapshot.setupComplete == true, store.load().hasCompletedOnboarding == false {
            await finishOnboarding()
        }
    }

    /// Claims the active-phone slot (best-effort — the Gallery re-attempts and surfaces active-phone
    /// errors) and persists `hasCompletedOnboarding`, pushing the updated flags into routing.
    public func finishOnboarding() async {
        try? await camera.activate()
        mutate { $0.hasCompletedOnboarding = true }
    }

    private func mutate(_ change: (inout OnboardingFlags) -> Void) {
        var flags = store.load()
        change(&flags)
        store.save(flags)
        routing.update(flags: flags)
    }
}
