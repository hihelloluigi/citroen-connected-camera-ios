// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "CoreUI",
	platforms: [.iOS(.v17), .macOS(.v14)],
	products: [
		.library(name: "CoreUI", targets: ["CoreUI"])
	],
	targets: [
		.target(name: "CoreUI"),
		.testTarget(name: "CoreUITests", dependencies: ["CoreUI"])
	]
)
