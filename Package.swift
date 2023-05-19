// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Gramophone",
	platforms: [.macOS(.v10_12), .iOS(.v10)],
    products: [
        .library(name: "Gramophone", targets: ["Gramophone"]),
		.executable(name: "gramophone", targets: ["CLITool"]),
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
		.executableTarget(name: "CLITool", dependencies: ["Gramophone"]),
    ]
)
