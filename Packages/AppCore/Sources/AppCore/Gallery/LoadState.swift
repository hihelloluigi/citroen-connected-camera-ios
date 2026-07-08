/// The lifecycle every gallery view model exposes: nothing yet, in flight, a value, or a handled
/// failure. Views switch on this to render content, a spinner, or `ErrorStateView`.
public enum LoadState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(UserFacingError)
}
