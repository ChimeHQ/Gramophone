// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gramophone",
	platforms: [.macOS(.v10_12), .iOS(.v10)],
    products: [
        .library(
            name: "Gramophone",
            targets: ["Gramophone"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/Flexer", .branch("main")),
    ],
    targets: [
        .target(
            name: "Gramophone",
            dependencies: ["Flexer"]),
        .testTarget(
            name: "GramophoneTests",
            dependencies: ["Gramophone"]),
    ]
)
