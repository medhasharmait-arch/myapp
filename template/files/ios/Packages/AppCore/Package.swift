// swift-tools-version:5.9
// Platform-neutral core: Foundation only, so `swift test` runs on Linux (see AGENTS.md rule 2).
import PackageDescription

let package = Package(
    name: "AppCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AppCore", targets: ["AppCore"]),
    ],
    targets: [
        .target(name: "AppCore"),
        .testTarget(name: "AppCoreTests", dependencies: ["AppCore"]),
    ]
)
