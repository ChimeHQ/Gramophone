import Foundation
import ArgumentParser

import Gramophone

struct GramophoneCommand: ParsableCommand {
	static let configuration = CommandConfiguration(commandName: "gramophone")

	@Flag(
		name: .shortAndLong,
		help: "Print the version and exit."
	)
	var version: Bool = false

	@Argument(help: "The path to the input file.")
	var inputPath: String

	func run() throws {
		if version {
			throw CleanExit.message("0.1.0")
		}

		let input = try String(contentsOfFile: inputPath, encoding: .utf8)
		let parser = BNFParser()

		let grammar = try parser.parseGrammar(input)

		for (_, rule) in grammar.rules {
			print(rule)
		}
	}
}

GramophoneCommand.main()
