import Foundation

/// Everything that can go wrong talking to the camera over its local Wi-Fi API.
public enum VIRBError: Error, Equatable, Sendable {
    /// The camera reported result code 9: another phone currently holds control.
    case notActivePhone
    /// The camera reported result code 3: it rejected the request.
    case denied
    /// The camera rejected the Wi-Fi password sent via `setWiFiPassword`.
    case passwordRejected
    /// The connection dropped or timed out (e.g. the phone left the camera's Wi-Fi range).
    case cameraUnreachable
    /// Any other networking failure; the associated string is the underlying error's description.
    case transport(String)
    /// The camera's response body couldn't be parsed into the expected shape.
    case decoding(String)
    /// The camera returned a result code with no known meaning.
    case unexpected(result: Int)

    /// Maps a camera `result` code to an error, or `nil` on success (1).
    static func map(result: Int) -> VIRBError? {
        switch result {
        case 1: return nil
        case 3: return .denied
        case 9: return .notActivePhone
        default: return .unexpected(result: result)
        }
    }

    public var userMessage: String {
        switch self {
        case .notActivePhone: return "Another phone is controlling the camera."
        case .denied: return "The camera refused the request."
        case .passwordRejected: return "The current Wi-Fi password was not accepted."
        case .cameraUnreachable: return "Lost connection to the camera. Check you're on its Wi-Fi."
        case .transport: return "A network error occurred talking to the camera."
        case .decoding: return "The camera sent an unexpected response."
        case .unexpected(let result): return "The camera returned an unexpected status (\(result))."
        }
    }
}
