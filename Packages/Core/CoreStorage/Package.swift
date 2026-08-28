// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "CoreStorage",
	platforms: [
		.iOS(.v17),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "CoreStorage",
			targets: ["CoreStorage"]
		)
	],
	dependencies: [
		// Internal dependencies
		.package(name: "CoreDomain", path: "../../Core/CoreDomain"),
		.package(name: "CoreLogging", path: "../../Core/CoreLogging"),
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreStorage",
			dependencies: [
				.product(name: "CoreDomain", package: "CoreDomain"),
				.product(name: "CoreLogging", package: "CoreLogging")
			],
			path: "Sources/CoreStorage",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "CoreStorageTests",
			dependencies: ["CoreStorage"],
			path: "Tests/CoreStorageTests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
