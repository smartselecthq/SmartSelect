// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SmartSelect",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SmartSelectCore", targets: ["SmartSelectCore"]),
        .executable(name: "smartselect", targets: ["SmartSelectApp"]),
    ],
    targets: [
        // Pure, dependency-free entity-boundary engine. Cross-platform (macOS + Linux CI).
        .target(
            name: "SmartSelectCore",
            swiftSettings: [.unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug))]
        ),
        // macOS menu-bar agent: CGEventTap + Accessibility integration.
        .executableTarget(
            name: "SmartSelectApp",
            dependencies: ["SmartSelectCore"]
        ),
        .testTarget(
            name: "SmartSelectCoreTests",
            dependencies: ["SmartSelectCore"]
        ),
    ]
)
