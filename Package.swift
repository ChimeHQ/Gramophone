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
		.executable(name: "swift-grammar-extract", targets: ["swift-grammar-extract"]),
	],
	dependencies: [
		.package(url: "https://github.com/ChimeHQ/Flexer", branch: "main"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
		.package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.7.3"),
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
		.executableTarget(
			name: "swift-grammar-extract",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Markdown", package: "swift-markdown"),
			]
		),
	]
)
