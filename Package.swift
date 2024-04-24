// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vapor-utils",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VaporUtils",
            targets: ["VaporUtils"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VaporUtils",
            dependencies: [
                .product(name: "Fluent", package: "Fluent"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "VaporUtilsTests",
            dependencies: ["VaporUtils"]
        ),
    ]
)
