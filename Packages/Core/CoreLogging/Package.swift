// swift-tools-version: 6.0

import PackageDescription

// No internal dependencies: every module may log, so this one sits at the bottom of the graph.
let package = Package(
	name: "CoreLogging",
	platforms: [
		.iOS(.v17),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "CoreLogging",
			targets: ["CoreLogging"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreLogging",
			path: "Sources/CoreLogging",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "CoreLoggingTests",
			dependencies: ["CoreLogging"],
			path: "Tests/CoreLoggingTests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
