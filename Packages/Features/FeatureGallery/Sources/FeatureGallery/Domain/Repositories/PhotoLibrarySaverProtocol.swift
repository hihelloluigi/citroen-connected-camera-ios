//
//  PhotoLibrarySaverProtocol.swift
//  FeatureGallery
//

import Foundation

/// Saves a downloaded camera file into the user's photo library. The implementation in `Data/`
/// backs this with `PHPhotoLibrary` (which needs `NSPhotoLibraryAddUsageDescription`); tests use a
/// recording fake. Kept behind a protocol so the download orchestration is unit-testable without
/// touching Photos.
public protocol PhotoLibrarySaverProtocol: Sendable {
	func save(fileAt url: URL, kind: MediaEntity.Kind) async throws
}
