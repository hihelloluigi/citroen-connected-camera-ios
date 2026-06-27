import Foundation

extension JSONDecoder {
    /// Decoder configured for the camera's JSON. Dates are handled per-field (Unix epoch).
    static var virb: JSONDecoder { JSONDecoder() }
}
