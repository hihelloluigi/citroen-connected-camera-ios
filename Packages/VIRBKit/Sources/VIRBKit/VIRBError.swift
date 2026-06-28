import Foundation

public enum VIRBError: Error, Equatable, Sendable {
    case notActivePhone
    case denied
    case passwordRejected
    case cameraUnreachable
    case transport(String)
    case decoding(String)
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
