import Testing
@testable import AppCore

@Test func defaultFlagsAreAllFalse() {
	let flags = OnboardingFlags()
	#expect(flags == OnboardingFlags(hasTappedGetStarted: false, localNetworkResolved: false,
									 locationResolved: false, hasCompletedOnboarding: false))
}

@Test func storeRoundTripsFlags() {
	let store = InMemoryFlagsStore()
	var flags = store.load()
	flags.hasTappedGetStarted = true
	flags.locationResolved = true
	store.save(flags)
	#expect(store.load().hasTappedGetStarted)
	#expect(store.load().locationResolved)
	#expect(store.load().hasCompletedOnboarding == false)
}
