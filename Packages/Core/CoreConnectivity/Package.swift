// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "CoreConnectivity",
	platforms: [
		.iOS(.v17),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "CoreConnectivity",
			targets: ["CoreConnectivity"]
		)
	],
	dependencies: [
		// Internal dependencies
		.package(name: "CoreCamera", path: "../../Core/CoreCamera"),
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreConnectivity",
			dependencies: [
				.product(name: "CoreCamera", package: "CoreCamera")
			],
			path: "Sources/CoreConnectivity",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "CoreConnectivityTests",
			dependencies: ["CoreConnectivity"],
			path: "Tests/CoreConnectivityTests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
