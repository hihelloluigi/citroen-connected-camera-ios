//
//  CameraStatusEntity.swift
//  FeatureGallery
//

/// What the status strip above the grid needs to know about the camera.
///
/// `CameraStatusDTO` carries eleven fields; the header renders two. The other nine — connection
/// counts, clip duration, phone ids, fault text — are camera diagnostics no screen shows today, so
/// they stop at the repository.
public struct CameraStatusEntity: Sendable, Equatable {
	/// Whether the camera reports its SD card needs formatting.
	public let needsFormat: Bool
	/// Whether the camera currently has a GPS fix.
	public let hasGPSFix: Bool

	public init(needsFormat: Bool, hasGPSFix: Bool) {
		self.needsFormat = needsFormat
		self.hasGPSFix = hasGPSFix
	}
}

/// The camera's identity, as shown in the status details sheet.
public struct DeviceInfoEntity: Sendable, Equatable {
	/// Firmware version number.
	public let firmware: Int
	/// The camera's part/model number.
	public let partNumber: String
	/// Unique numeric identifier for this camera unit.
	public let deviceId: Int64

	public init(firmware: Int, partNumber: String, deviceId: Int64) {
		self.firmware = firmware
		self.partNumber = partNumber
		self.deviceId = deviceId
	}
}
