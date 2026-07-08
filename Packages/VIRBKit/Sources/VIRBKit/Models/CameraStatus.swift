import Foundation

/// A point-in-time snapshot of the camera's state, as returned by `VIRBClient.status()`.
public struct CameraStatus: Sendable, Equatable {
	/// The phone ID the camera currently treats as active, if any phone is paired.
	public let activePhoneId: String?
	/// The phone ID the camera treats as its primary/owner phone, if set.
	public let primaryPhoneId: String?
	/// Number of phones/clients currently connected to the camera's Wi-Fi.
	public let numberOfConnections: Int
	/// Length, in seconds, of each saved video clip segment.
	public let saveVideoDuration: Int
	/// Whether the camera reports its SD card needs to be formatted.
	public let needsFormat: Bool
	/// Whether the camera has detected an incident (e.g. a crash event) since last checked.
	public let incidentDetected: Bool
	/// Human-readable fault text from the camera; `"No Fault"` when everything is normal.
	public let faultDescription: String
	/// Current GPS latitude, when the camera has a fix.
	public let gpsLatitude: Double?
	/// Current GPS longitude, when the camera has a fix.
	public let gpsLongitude: Double?

	public init(activePhoneId: String?, primaryPhoneId: String?, numberOfConnections: Int,
				saveVideoDuration: Int, needsFormat: Bool, incidentDetected: Bool,
				faultDescription: String, gpsLatitude: Double?, gpsLongitude: Double?) {
		self.activePhoneId = activePhoneId
		self.primaryPhoneId = primaryPhoneId
		self.numberOfConnections = numberOfConnections
		self.saveVideoDuration = saveVideoDuration
		self.needsFormat = needsFormat
		self.incidentDetected = incidentDetected
		self.faultDescription = faultDescription
		self.gpsLatitude = gpsLatitude
		self.gpsLongitude = gpsLongitude
	}
}

/// Raw `periodicUpdate` response.
struct StatusResponse: Decodable {
	let result: Int
	let activePhoneId: String?
	let primaryPhoneId: String?
	let numberOfConnections: Int
	let saveVideoDuration: Int
	let needFormat: Int
	let incidentDetected: Int
	let faultDescription: String
	let gpsLatitude: Double?
	let gpsLongitude: Double?

	static func decode(from data: Data) throws -> StatusResponse {
		try JSONDecoder.virb.decode(StatusResponse.self, from: data)
	}

	func status() -> CameraStatus {
		CameraStatus(
			activePhoneId: activePhoneId,
			primaryPhoneId: primaryPhoneId,
			numberOfConnections: numberOfConnections,
			saveVideoDuration: saveVideoDuration,
			needsFormat: needFormat == 1,
			incidentDetected: incidentDetected == 1,
			faultDescription: faultDescription,
			gpsLatitude: gpsLatitude,
			gpsLongitude: gpsLongitude
		)
	}
}
