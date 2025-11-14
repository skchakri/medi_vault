// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MediVault",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "MediVault",
            targets: ["MediVault"]
        )
    ],
    dependencies: [
        // Hotwire Native dependencies
        .package(url: "https://github.com/hotwired/turbo-ios", from: "7.1.0"),
        .package(url: "https://github.com/hotwired/strada-ios", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MediVault",
            dependencies: [
                .product(name: "Turbo", package: "turbo-ios"),
                .product(name: "Strada", package: "strada-ios")
            ]
        )
    ]
)
