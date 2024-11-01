import Testing
import Gramophone

struct GrammarTests {
	@Test
	func firstsFromSingleTerminal() throws {
		let content = """
a = '1';
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FirstMap = [
			"a": ["1"],
		]

		#expect(grammar.computeFirstMap() == expected)
	}

	@Test
	func firstsFromReference() throws {
		let content = """
a = '1';
b = '2';
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FirstMap = [
			"a": ["1"],
			"b": ["2"],
		]

		#expect(grammar.computeFirstMap() == expected)
	}

	@Test
	func firstsFromDoubleReference() throws {
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

		#expect(grammar.computeFirstMap() == expected)
	}
}

extension GrammarTests {
	@Test
	func followFromSingleTerminal() throws {
		let content = """
a = '1';
"""
		let grammar = try BNFParser().parseGrammar(content)
		let expected: Grammar.FollowMap = [
			"a": [.endOfInput],
		]

		#expect(grammar.computeFollowMap() == expected)
	}

	@Test
	func followFromConcatenation() throws {
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

		#expect(grammar.computeFollowMap() == expected)
	}

	@Test
	func followFromAlternation() throws {
		let content = """
a = '1';
b = a, ('2' | '3');
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a": ["2", "3"],
			"b": [.endOfInput],
		]

		#expect(grammar.computeFollowMap() == expected)
	}

	@Test
	func followFromRepetition() throws {
		let content = """
a = '1';
b = a, {'2'};
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : ["2"],
			"b": [.endOfInput],
		]

		#expect(grammar.computeFollowMap() == expected)
	}

	@Test
	func followFromAlternationInStart() throws {
		let content = """
a = '1';
b = a | (a '2');
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : ["2", .endOfInput],
			"b": [.endOfInput],
		]

		#expect(grammar.computeFollowMap() == expected)
	}

	@Test
	func followFromGroupedConcatenation() throws {
		let content = """
a = '1';
b = (a ',' '2');
"""
		let grammar = try BNFParser().parseGrammar(content)

		let expected: Grammar.FollowMap = [
			"a" : [","],
			"b": [.endOfInput],
		]

		#expect(grammar.computeFollowMap() == expected)
	}

	@Test
	func followsFromReference() throws {
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

		#expect(grammar.computeFollowMap() == expected)
	}

	@Test
	func followsFromSecondReference() throws {
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

		#expect(grammar.computeFollowMap() == expected)
	}
}
