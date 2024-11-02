// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Gramophone",
	platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "Gramophone", targets: ["Gramophone"]),
		.executable(name: "gram", targets: ["CLITool"]),
    ],
    dependencies: [
		.package(url: "https://github.com/ChimeHQ/Flexer", branch: "main"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "Gramophone",
            dependencies: ["Flexer"]),
        .testTarget(
            name: "GramophoneTests",
            dependencies: ["Gramophone"]),
		.executableTarget(
			name: "CLITool",
			dependencies: [
				"Gramophone",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
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
