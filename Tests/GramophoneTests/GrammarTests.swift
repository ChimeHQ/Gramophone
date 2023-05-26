import XCTest
import Gramophone

final class GrammarTests: XCTestCase {
	func testFirstsFromSingleTerminal() {
		let rules = [
			Rule(name: "a", kind: .terminalString("a"))
		]

		let grammar = Grammar(rules: rules)
		let expected: Grammar.FirstMap = [
			"a": [.string("a")],
		]

		XCTAssertEqual(grammar.firstMap, expected)
	}

	func testFirstsFromReference() {
		let rules = [
			Rule(name: "a", kind: .terminalString("a")),
			Rule(name: "b", kind: .reference("a"))
		]

		let grammar = Grammar(rules: rules)
		let expected: Grammar.FirstMap = [
			"a": [.string("a")],
			"b": [.string("a")],
		]

		XCTAssertEqual(grammar.firstMap, expected)
	}

	func testFirstsFromDoubleReference() {
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

		XCTAssertEqual(grammar.firstMap, expected)
	}
}

extension GrammarTests {
	func testFollowFromSingleTerminal() {
		let rules = [
			Rule(name: "a", kind: .terminalString("a"))
		]

		let grammar = Grammar(rules: rules)
		let expected: Grammar.FollowMap = [
			"a": [],
		]

		XCTAssertEqual(grammar.followMap, expected)
	}
}
