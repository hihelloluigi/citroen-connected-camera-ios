# CoreNavigation

Two declarations, deliberately.

## Invariants

**`Coordinator` is narrower than the UIKit one in beam and syncsulin, on purpose.** Those require
`childCoordinators` and `start()`; both solve UIKit problems that do not exist here. SwiftUI's view
tree already retains a coordinator through `@State`, and a container's `body` is what starts a flow,
so there would be nothing to call. What remains is enforced by the compiler rather than by
convention: `AnyObject` rejects a value-type coordinator whose route mutations would be lost at the
next `body` evaluation, and `@MainActor` is what lets one drive route state from `async` methods.

**`NavigationActionHandler` imports nothing.** It is a plain closure typealias, so a ViewModel
calling it cannot tell which renderer is routing — which is the whole point of the seam.
