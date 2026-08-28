// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "CoreNavigation",
	platforms: [
		.iOS(.v17),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "CoreNavigation",
			targets: ["CoreNavigation"]
		)
	],
	dependencies: [
		// Internal dependencies

		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreNavigation",
			path: "Sources/CoreNavigation",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
