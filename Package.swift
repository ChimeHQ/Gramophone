// swift-tools-version: 6.1

import PackageDescription

let package = Package(
	name: "Gramophone",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
		.visionOS(.v1),
	],
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
