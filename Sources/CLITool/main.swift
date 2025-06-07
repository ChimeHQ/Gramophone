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

		let rules = try parser.parse(input).get()

		let grammar = Grammar(rules: rules)

		// this garbage preserves the rule name ordering
		let ruleNames = rules.map { $0.name }

		var printedSet: Set<String> = []

		for ruleName in ruleNames {
			if printedSet.contains(ruleName) {
				continue
			}


			print(grammar.rules[ruleName]!)

			printedSet.insert(ruleName)
		}
	}
}

GramophoneCommand.main()
