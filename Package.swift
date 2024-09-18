// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Gramophone",
	platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "Gramophone", targets: ["Gramophone"]),
//		.executable(name: "gramophone", targets: ["CLITool"]),
    ],
    dependencies: [
		.package(url: "https://github.com/ChimeHQ/Flexer", branch: "main"),
    ],
    targets: [
        .target(
            name: "Gramophone",
            dependencies: ["Flexer"]),
        .testTarget(
            name: "GramophoneTests",
            dependencies: ["Gramophone"]),
//		.executableTarget(name: "CLITool", dependencies: ["Gramophone"]),
    ]
)

let swiftSettings: [SwiftSetting] = [
	.enableExperimentalFeature("StrictConcurrency")
]

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: swiftSettings)
	target.swiftSettings = settings
}
