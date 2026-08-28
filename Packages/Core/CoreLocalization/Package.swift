// swift-tools-version: 6.0

import PackageDescription

// CoreDomain is the one internal dependency, and the direction matters: CoreLocalization knows
// about the domain's cases so it can word them, never the reverse. That is what keeps CoreDomain
// copy-free and buildable for macOS while this module stays iOS-only.
let package = Package(
	name: "CoreLocalization",
	defaultLocalization: "en",
	// iOS only, like the rest of the fleet's CoreLocalization. SwiftPM's own build copies an
	// .xcstrings rather than compiling it, so `String(localized:)` would return the raw key under
	// `swift test` on macOS; only Xcode runs xcstringstool over it. Keeping the module iOS-only is
	// what makes the test plan the single place these strings are ever resolved.
	platforms: [
		.iOS(.v17)
	],
	products: [
		.library(
			name: "CoreLocalization",
			targets: ["CoreLocalization"]
		)
	],
	dependencies: [
		// Internal dependencies
		.package(name: "CoreDomain", path: "../CoreDomain"),
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreLocalization",
			dependencies: [
				.product(name: "CoreDomain", package: "CoreDomain")
			],
			path: "Sources/CoreLocalization",
			resources: [.process("Resources")],
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "CoreLocalizationTests",
			dependencies: ["CoreLocalization"],
			path: "Tests/CoreLocalizationTests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
