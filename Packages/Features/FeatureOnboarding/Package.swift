// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "FeatureOnboarding",
	platforms: [
		.iOS(.v17)
	],
	products: [
		.library(
			name: "FeatureOnboarding",
			targets: ["FeatureOnboarding"]
		)
	],
	dependencies: [
		// Internal dependencies
		.package(name: "CoreCamera", path: "../../Core/CoreCamera"),
		.package(name: "CoreConnectivity", path: "../../Core/CoreConnectivity"),
		.package(name: "CoreDomain", path: "../../Core/CoreDomain"),
		.package(name: "CoreNavigation", path: "../../Core/CoreNavigation"),
		.package(name: "CoreUI", path: "../../Core/CoreUI"),
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "FeatureOnboarding",
			dependencies: [
				.product(name: "CoreCamera", package: "CoreCamera"),
				.product(name: "CoreConnectivity", package: "CoreConnectivity"),
				.product(name: "CoreDomain", package: "CoreDomain"),
				.product(name: "CoreNavigation", package: "CoreNavigation"),
				.product(name: "CoreUI", package: "CoreUI")
			],
			path: "Sources/FeatureOnboarding",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "FeatureOnboardingTests",
			dependencies: ["FeatureOnboarding"],
			path: "Tests/FeatureOnboardingTests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
