# CoreStorage

Keychain and `UserDefaults`, behind protocols owned by `CoreDomain`.

## Invariants

**The Keychain service is scoped to the running bundle id.** Development, Staging and Production
installs each keep their own phone id rather than fighting over one item — which matters because the
camera pairs against that id, and two builds sharing one would take control from each other.

**The phone id is generated once and never regenerated.** `PhoneIdStore` writes on first use and
returns the same value forever after; the item is `ThisDeviceOnly` so it never syncs through iCloud
Keychain or restores onto another device. A rotating id would read to the camera as a different
phone every launch.

**`UserDefaultsFlagsStore.reset()` exists only for UI tests.** The flags survive between test runs in
a simulator, so a suite that passes in isolation can fail in a different order without it. Nothing in
the app calls it.
