import Foundation
import Testing
@testable import VIRBKit

/// Parent suite that serialises every VIRBClient integration suite.
///
/// `MockURLProtocol.handler` is a shared global, so any two suites that call
/// `makeClient` must never run concurrently. Nesting them inside this
/// `.serialized` parent guarantees serial execution across suite boundaries.
@Suite(.serialized)
struct VIRBClientTests {}
