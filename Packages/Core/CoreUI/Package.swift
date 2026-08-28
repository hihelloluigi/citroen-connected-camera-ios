// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "CoreUI",
	platforms: [
		.iOS(.v17),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "CoreUI",
			targets: ["CoreUI"]
		)
	],
	dependencies: [
		// Internal dependencies

		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreUI",
			path: "Sources/CoreUI",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "CoreUITests",
			dependencies: ["CoreUI"],
			path: "Tests/CoreUITests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
