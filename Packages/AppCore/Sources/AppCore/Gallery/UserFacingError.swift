import VIRBKit

/// A camera failure reduced to one human-voiced line for the UI. Known `VIRBError`s carry their own
/// message; anything else collapses to a generic, recover-by-retry line — no raw `URLError`/decoding
/// noise reaches a screen.
public struct UserFacingError: Equatable, Sendable {
	public let message: String

	public init(message: String) { self.message = message }

	public init(_ error: any Error) {
		if let virb = error as? VIRBError {
			self.message = virb.userMessage
		} else {
			self.message = "Something went wrong talking to the camera. Please try again."
		}
	}
}
