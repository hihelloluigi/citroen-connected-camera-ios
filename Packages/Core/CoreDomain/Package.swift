// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "CoreDomain",
	platforms: [
		.iOS(.v17),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "CoreDomain",
			targets: ["CoreDomain"]
		)
	],
	dependencies: [
		// Internal dependencies
		.package(name: "CoreCamera", path: "../../Core/CoreCamera"),
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "CoreDomain",
			dependencies: [
				.product(name: "CoreCamera", package: "CoreCamera")
			],
			path: "Sources/CoreDomain",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "CoreDomainTests",
			dependencies: ["CoreDomain"],
			path: "Tests/CoreDomainTests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
