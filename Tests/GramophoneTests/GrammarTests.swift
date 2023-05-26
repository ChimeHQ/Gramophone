import XCTest
import Gramophone

final class GrammarTests: XCTestCase {
	func testSingleTerminalFirstCalculations() {
		let rules = [
			Rule(name: "a", kind: .terminalString("a"))
		]

		let grammar = Grammar(rules: rules)
		let expected: Grammar.FirstMap = [
			"a": [.string("a")],
		]

		XCTAssertEqual(grammar.firsts, expected)
	}

	func testFollowsSingleReference() {
		let rules = [
			Rule(name: "a", kind: .terminalString("a")),
			Rule(name: "b", kind: .reference("a"))
		]

		let grammar = Grammar(rules: rules)
		let expected: Grammar.FirstMap = [
			"a": [.string("a")],
			"b": [.string("a")],
		]

		XCTAssertEqual(grammar.firsts, expected)
	}

	func testFollowsDoubleReference() {
		let rules = [
			Rule(name: "a", kind: .terminalString("a")),
			Rule(name: "b", kind: .reference("c")),
			Rule(name: "c", kind: .reference("a")),
		]

		let grammar = Grammar(rules: rules)
		let expected: Grammar.FirstMap = [
			"a": [.string("a")],
			"b": [.string("a")],
			"c": [.string("a")],
		]

		XCTAssertEqual(grammar.firsts, expected)
	}
}
