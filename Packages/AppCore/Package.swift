// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AppCore", targets: ["AppCore"])
    ],
    dependencies: [
        .package(path: "../VIRBKit")
    ],
    targets: [
        .target(name: "AppCore", dependencies: ["VIRBKit"]),
        .testTarget(name: "AppCoreTests", dependencies: ["AppCore"])
    ]
)
