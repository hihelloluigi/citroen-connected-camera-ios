// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "FeatureGallery",
	platforms: [
		.iOS(.v17)
	],
	products: [
		.library(
			name: "FeatureGallery",
			targets: ["FeatureGallery"]
		)
	],
	dependencies: [
		// Internal dependencies
		.package(name: "CoreCamera", path: "../../Core/CoreCamera"),
		.package(name: "CoreDomain", path: "../../Core/CoreDomain"),
		.package(name: "CoreNavigation", path: "../../Core/CoreNavigation"),
		.package(name: "CoreUI", path: "../../Core/CoreUI"),
		.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.0")
	],
	targets: [
		.target(
			name: "FeatureGallery",
			dependencies: [
				.product(name: "CoreCamera", package: "CoreCamera"),
				.product(name: "CoreDomain", package: "CoreDomain"),
				.product(name: "CoreNavigation", package: "CoreNavigation"),
				.product(name: "CoreUI", package: "CoreUI")
			],
			path: "Sources/FeatureGallery",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		),
		.testTarget(
			name: "FeatureGalleryTests",
			dependencies: ["FeatureGallery"],
			path: "Tests/FeatureGalleryTests",
			plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
		)
	]
)
