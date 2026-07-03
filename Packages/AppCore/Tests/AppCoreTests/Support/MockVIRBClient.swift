import Foundation
import VIRBKit

/// Minimal VIRBClientProtocol stub for wiring tests. No Plan 2 test invokes these methods, so they
/// only need to compile: return empty/echoed values or throw. Deliberately constructs no VIRBKit
/// model — those structs' memberwise initializers are internal to VIRBKit and unavailable here.
struct MockVIRBClient: VIRBClientProtocol {
    func connect() async throws -> CameraSession { throw VIRBError.cameraUnreachable }
    func status() async throws -> CameraStatus { throw VIRBError.cameraUnreachable }
    func mediaList() async throws -> [MediaItem] { [] }
    func snapPicture() async throws -> MediaItem { throw VIRBError.cameraUnreachable }
    func delete(_ items: [MediaItem]) async throws {}
    func setWiFiPassword(current: String, new: String) async throws {}
    func download(_ item: MediaItem, to destination: URL,
                  progress: (@Sendable (Double) -> Void)?) async throws -> URL { destination }
    func isReachable() async -> Bool { true }
}
