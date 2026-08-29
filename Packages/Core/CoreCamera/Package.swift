// swift-tools-version: 6.0

import PackageDescription

// macOS is kept alongside iOS on the Core packages that carry no UIKit — it is what lets the whole
// logic suite run under `swift test` on the Mac without booting a simulator. The Feature packages
// are iOS-only.
let package = Package(
	name: "CoreCamera",
	platforms: [
		.iOS(.v17),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "CoreCamera",
			targets: ["CoreCamera"]
		)
	],
	dependencies: [
		// Internal dependencies
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreCamera",
			path: "Sources/CoreCamera",
			// .process, not .copy. `.copy` preserves the folder, so the generated resource bundle
			// gets its own `Resources/` subdirectory — and codesign then rejects the whole bundle
			// as "bundle format unrecognized, invalid, or unsuitable". `.process` flattens the
			// files to the bundle root, which is why the lookup below takes no `subdirectory:`.
			resources: [.process("Resources")],
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "CoreCameraTests",
			dependencies: ["CoreCamera"],
			path: "Tests/CoreCameraTests",
			resources: [.copy("Fixtures")],
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
