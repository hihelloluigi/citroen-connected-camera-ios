//
//  UserFacingError.swift
//  CoreDomain
//

import CoreCamera

/// A camera failure reduced to the one fact a screen needs: which kind it was.
///
/// Deliberately carries no copy. CoreDomain is UI-agnostic and buildable for macOS, and a type
/// holding user-facing sentences would have to be localized, which would drag the whole domain
/// layer behind an iOS-only string catalog. `CoreLocalization` supplies the wording through
/// `UserFacingError.message`; everything below that boundary only ever names the case.
public enum UserFacingError: Equatable, Sendable {
	case notActivePhone
	case denied
	case passwordRejected
	case cameraUnreachable
	case transport
	case decoding
	case unexpected(result: Int)
	/// Anything that isn't a `VIRBError` — no raw `URLError` or decoding noise reaches a screen.
	case unknown

	public init(_ error: any Error) {
		guard let virb = error as? VIRBError else {
			self = .unknown
			return
		}
		switch virb {
		case .notActivePhone: self = .notActivePhone
		case .denied: self = .denied
		case .passwordRejected: self = .passwordRejected
		case .cameraUnreachable: self = .cameraUnreachable
		case .transport: self = .transport
		case .decoding: self = .decoding
		case .unexpected(let result): self = .unexpected(result: result)
		}
	}
}
