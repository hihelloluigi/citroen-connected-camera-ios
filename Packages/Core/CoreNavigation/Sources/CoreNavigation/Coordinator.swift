//
//  Coordinator.swift
//  CoreNavigation
//

/// Base protocol every SwiftUI coordinator conforms to.
///
/// Deliberately narrower than the UIKit `Coordinator` in beam-ios and syncsulin, which also
/// require `childCoordinators: [any Coordinator]` and `start()`. Both solve UIKit problems that
/// don't exist here. `childCoordinators` is there because ARC would deallocate a child coordinator
/// nobody retains — SwiftUI's view tree already retains one through `@State`. `start()` is there
/// because UIKit navigation is imperative (`setViewControllers`); in SwiftUI the container's `body`
/// is what starts a flow, so there'd be nothing to call.
///
/// What's left is small but not empty: `AnyObject` rejects a value-type coordinator, whose route
/// mutations would be lost at the next `body` evaluation, and `@MainActor` is what lets a
/// coordinator drive route state from `async` methods. Both are enforced by the compiler rather
/// than by convention.
@MainActor
public protocol Coordinator: AnyObject {}
