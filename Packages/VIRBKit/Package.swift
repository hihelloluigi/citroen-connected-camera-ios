// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "VIRBKit",
	platforms: [.iOS(.v17), .macOS(.v14)],
	products: [
		.library(name: "VIRBKit", targets: ["VIRBKit"])
	],
	targets: [
		.target(name: "VIRBKit"),
		.testTarget(name: "VIRBKitTests", dependencies: ["VIRBKit"], resources: [.copy("Fixtures")])
	]
)
