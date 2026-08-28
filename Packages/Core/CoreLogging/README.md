# CoreLogging

One logger, one subsystem, one level gate.

## Invariants

**No call site names the bundle identifier.** `AppLogger.subsystem` resolves it once from
`Bundle.main`. Two call sites used to hardcode a `?? "me.luigiaiello.ccam"` fallback, which is
wrong twice over: Development and Staging have different bundle ids, so their lines filed
themselves under the Production subsystem and Console's subsystem filter stopped working for
exactly the builds you debug most.

**Everything is logged `.public`.** This app has no accounts, no tokens and no personal data. The
only things it logs are camera protocol failures and Keychain status codes — redacting those would
make the log useless for the one thing it exists for. If that ever stops being true, the privacy
argument changes with it.

**The level is a build-time floor, not a runtime switch.** `CCAMLogLevel` in Info.plist is read
once; an unrecognised value falls back to `.info` rather than to silence, so a typo makes a build
slightly chattier than intended rather than mute.

**A category is a concern, not a type.** `AppLogger(category: "phone-id")`, not
`AppLogger(category: "KeychainSecureStore")` — the point is to filter Console by what went wrong,
and a category per type produces a list nobody can navigate.
