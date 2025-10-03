// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "MySwiftProject",
    platforms: [
        .macOS(.v13), // Adjust for macOS/iOS deployment if needed
    ],
    products: [
        // This defines the executable your package builds
        .executable(
            name: "MySwiftProject",
            targets: ["MySwiftProject"]
        ),
    ],
    dependencies: [
        // Example dependency: Swifter (HTTP server)
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.4.0"),
        // You can add more dependencies here as needed
    ],
    targets: [
        .executableTarget(
            name: "MySwiftProject",
            dependencies: [
                "Swifter"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "MySwiftProjectTests",
            dependencies: ["MySwiftProject"],
            path: "Tests"
        ),
    ]
)
