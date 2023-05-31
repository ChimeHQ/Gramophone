import XCTest
import Gramophone

final class GrammarTests: XCTestCase {
	func testFirstsFromSingleTerminal() throws {
		let content = """
a = '1';
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FirstMap = [
			"a": ["1"],
		]

		XCTAssertEqual(grammar.computeFirstMap(), expected)
	}

	func testFirstsFromReference() throws {
		let content = """
a = '1';
b = '2';
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FirstMap = [
			"a": ["1"],
			"b": ["2"],
		]

		XCTAssertEqual(grammar.computeFirstMap(), expected)
	}

	func testFirstsFromDoubleReference() throws {
		let content = """
a = '1';
b = c;
c = a;
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FirstMap = [
			"a": ["1"],
			"b": ["1"],
			"c": ["1"],
		]

		XCTAssertEqual(grammar.computeFirstMap(), expected)
	}
}

extension GrammarTests {
	func testFollowFromSingleTerminal() throws {
		let content = """
a = '1';
"""
		let grammar = try BNFParser().parseGrammar(content)
		let expected: Grammar.FollowMap = [
			"a": [.endOfInput],
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}

	func testFollowFromConcatenation() throws {
		let content = """
a = '1';
b = '2';
c = a b;
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a": ["2"],
			"b": [.endOfInput],
			"c": [.endOfInput],
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}

	func testFollowFromAlternation() throws {
		let content = """
a = '1';
b = a, ('2' | '3');
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a": ["2", "3"],
			"b": [.endOfInput],
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}

	func testFollowFromRepetition() throws {
		let content = """
a = '1';
b = a, {'2'};
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : ["2"],
			"b": [.endOfInput],
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}

	func testFollowFromAlternationInStart() throws {
		let content = """
a = '1';
b = a | (a '2');
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : ["2", .endOfInput],
			"b": [.endOfInput],
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}

	func testFollowFromGroupedConcatenation() throws {
		let content = """
a = '1';
b = (a ',' '2');
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : [","],
			"b": [.endOfInput],
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}

	func testFollowsFromReference() throws {
		let content = """
a = '1';
b = a;
c = b, '3';
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : ["3"],
			"b": ["3"],
			"c": [.endOfInput],
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}

	func testFollowsFromSecondReference() throws {
		let content = """
a = '1';
b = a;
c = b;
d = c, '3';
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : ["3"],
			"b": ["3"],
			"c": ["3"],
			"d": [.endOfInput]
		]

		XCTAssertEqual(grammar.computeFollowMap(), expected)
	}
}
