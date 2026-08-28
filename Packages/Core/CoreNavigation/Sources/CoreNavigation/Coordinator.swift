/// Base protocol every SwiftUI coordinator conforms to. `AnyObject` rejects a value-type
/// coordinator, whose route mutations would be lost at the next `body` evaluation; `@MainActor`
/// lets one drive route state from `async` methods. See the module README for why it is this
/// narrow.
@MainActor
public protocol Coordinator: AnyObject {}
