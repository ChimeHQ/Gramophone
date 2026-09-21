import Foundation
import ArgumentParser

import Markdown

struct GrammarExtractCommand: ParsableCommand {
	static let configuration = CommandConfiguration(commandName: "swift-grammar-extract")

	@Argument(help: "The path to the input file.")
	var inputPath: String

	func run() throws {
		let input = try String(contentsOfFile: inputPath, encoding: .utf8)

		let document = Document(parsing: input)

		let rules = document.children
			.compactMap { $0 as? BlockQuote }
			.flatMap { $0.children.dropFirst() } // the title is the first element
			.compactMap { $0 as? Paragraph }
			.flatMap {
				$0.plainText.components(separatedBy: "\n")
			}

		for rule in rules {
			print(rule.trimmingCharacters(in: .whitespaces))
		}
	}
}

GrammarExtractCommand.main()

