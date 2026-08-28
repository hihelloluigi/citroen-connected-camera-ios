# CoreDomain

The UI-agnostic shapes more than one layer needs.

## Invariants

**Nothing here holds a user-facing sentence.** `UserFacingError` is a case-carrying enum,
`PasswordRules` returns a `PasswordRuleViolation`. This is load-bearing, not stylistic: copy would
mean depending on `CoreLocalization`, which is iOS-only, which would make this module iOS-only and
take the whole logic suite off `swift test` with it. `CoreLocalization/Extensions/` does the
wording, in that direction only.

**The `CoreLocation` wrapper lives here as a file pair, not as its own module.** Nothing swaps
across it — one protocol, one implementation — and a module named `CoreLocation` would collide with
the framework it imports. Promote it if a second consumer ever appears, not in anticipation of one.

**`UserFacingError` collapses everything unrecognized to `.unknown`.** No raw `URLError` or decoding
detail reaches a screen; the camera's own result code is the one detail worth surfacing, so a bug
report can name it.
