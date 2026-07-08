import Foundation
import VIRBKit
import AppCore

/// Scriptable GalleryService for view-model tests. Returns scripted values or throws scripted errors,
/// and records the mutations the view models perform.
final class MockGalleryService: GalleryService, @unchecked Sendable {
    var mediaResult: [MediaItem] = []
    var mediaError: (any Error)?
    var statusResult: CameraStatus?
    var statusError: (any Error)?
    var deviceResult: DeviceInfo?
    var snapshotResult: MediaItem?
    var snapshotError: (any Error)?
    var deleteError: (any Error)?
    var downloadError: (any Error)?
    private(set) var deletedBatches: [[MediaItem]] = []
    private(set) var downloadedNames: [String] = []

    func media() async throws -> [MediaItem] {
        if let mediaError { throw mediaError }
        return mediaResult
    }
    func status() async throws -> CameraStatus {
        if let statusError { throw statusError }
        return statusResult ?? CameraStatus(activePhoneId: nil, primaryPhoneId: nil,
            numberOfConnections: 1, saveVideoDuration: 60, needsFormat: false,
            incidentDetected: false, faultDescription: "No Fault", gpsLatitude: nil, gpsLongitude: nil)
    }
    func device() async throws -> DeviceInfo {
        deviceResult ?? DeviceInfo(wifiSSID: "ConnectedCAM0690", firmware: 200, vimVersion: 140,
                                   partNumber: "006-B2465-00", deviceId: 3_939_980_690)
    }
    func snapshot() async throws -> MediaItem {
        if let snapshotError { throw snapshotError }
        return snapshotResult ?? MediaFactory.item(name: "SNAP.JPG", kind: .photo)
    }
    func delete(_ items: [MediaItem]) async throws {
        if let deleteError { throw deleteError }
        deletedBatches.append(items)
    }
    func download(_ item: MediaItem, to destination: URL,
                  progress: @escaping @Sendable (Double) -> Void) async throws -> URL {
        if let downloadError { throw downloadError }
        progress(1)
        downloadedNames.append(item.name)
        return destination
    }
}
