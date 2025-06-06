import Testing
import Gramophone

struct ParserTests {
	@Test
	func assignment() throws {
		let string = "test = 'a';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "a")])
	}

	@Test
	func BNFStyleAssignment() throws {
		let string = "test ::= abc;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: .reference("abc"))])
	}

	@Test
	func backslashTerminal() throws {
		let string = "test = '\\';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "\\")])
	}

	@Test
	func reference() throws {
		let string = "test = something;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: .reference("something"))])
	}

	@Test
	func BNFStyleReference() throws {
		let string = "test = <something>;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: .reference("something"))])
	}

	@Test
	func alternation() throws {
		let string = "test = 'a' | 'b';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			"test",
			kind: .alternation(["a", "b"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func alternationWithThreeElements() throws {
		let string = "test = 'a' | 'b' | 'c';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			"test",
			kind: .alternation(["a", "b", "c"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func alternationOnNewline() throws {
		let string = "test = 'a' |\n 'b';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			"test",
			kind: .alternation(["a", "b"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func concatenation() throws {
		let string = "test = 'a', 'b';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .concatenation(["a", "b"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func concatenationWithThreeElements() throws {
		let string = "test = 'a', 'b', 'c';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .concatenation(["a", "b", "c"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func implicitConcatenation() throws {
		let string = "test = 'a' 'b';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .concatenation(["a", "b"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func implicitConcatenationWithOptional() throws {
		let string = "test = 'a' ['b'];"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .concatenation(["a", .optional("b")])
		)
		#expect(rules == [expectedRule])
	}

	@Test func implicitConcatenationWithAngledQuotes() throws {
		let string = "test = 'a' `b´;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .concatenation(["a", "b"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func implicitConcatenationWithThreeElements() throws {
		let string = "test = 'a' 'b' 'c';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .concatenation(["a", "b", "c"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func optional() throws {
		let string = "test = ['-'], 'a';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .concatenation([.optional("-"), "a"])
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func tailingOptional() throws {
		let string = "a = b?;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .optional(.reference("b"))),
		]

		#expect(rules == expectedRules)
	}

	@Test
	func repetition() throws {
		let string = "test = {'a'};"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .occurrence("a", frequency: .zeroOrMore)
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func starRepetition() throws {
		let string = "test = 'a'*;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .occurrence("a", frequency: .zeroOrMore)
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func plusRepetition() throws {
		let string = "test = 'a'+;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .occurrence("a", frequency: .oneOrMore)
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func grouping() throws {
		let string = "test = ('a');"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .grouping("a")
		)
		#expect(rules == [expectedRule])
	}

	@Test
	func exception() throws {
		let string = "test = a - b;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .exception(.reference("a"), .reference("b"))
		)
		#expect(rules == [expectedRule])
	}
}

extension ParserTests {
	@Test
	func assignmentWithArrow() throws {
		let string = "test → 'a';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "a")])
	}

	@Test
	func assignmentWithSymbols() throws {
		let string = "test = '%';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "%")])
	}

	@Test
	func emptyCodePoint() throws {
		let string = "test = U+0000;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "\u{0000}")])
	}

	@Test
	func fiveDigitCodePoint() throws {
		let string = "test = U+1F34E;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "🍎")])
	}

	@Test
	func newlines() throws {
		let string = """
test = 'a';
"""
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "a")])
	}

	@Test
	func doubleQuoteTerminal() throws {
		let string = "test = \"a\";"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "a")])
	}

	@Test
	func angledQuoteTerminal() throws {
		let string = "test = `a´"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: "a")])
	}

	@Test
	func doubleQuoteSpace() throws {
		let string = "test = \" \""
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		#expect(rules == [Rule("test", kind: " ")])
	}

	@Test
	func multipleAssignments() throws {
		let string = """
a = 'a';
b = 'b';
"""
		let rules = try BNFParser().parse(string).get()

		let expectedRules = [
			Rule("a", kind: "a"),
			Rule("b", kind: "b"),
		]

		#expect(rules == expectedRules)
	}

	@Test
	func multipleNewLineSeparatedAssignments() throws {
		let string = """
a = 'a'

b = 'b'
"""
		let rules = try BNFParser().parse(string).get()

		let expectedRules = [
			Rule("a", kind: "a"),
			Rule("b", kind: "b"),
		]

		#expect(rules == expectedRules)
	}
}

extension ParserTests {
	@Test
	func multipleRules() throws {
		let string = "a = 'a';b = 'b';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: "a"),
			Rule(name: "b", kind: "b"),
		]

		#expect(rules == expectedRules)
	}

	@Test
	func concatenationWithinRepetition() throws {
		let string = "a = {a, b};"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .occurrence(.concatenation([.reference("a"), .reference("b")]), frequency: .zeroOrMore))
		]

		#expect(rules == expectedRules)
	}

	@Test
	func concatenationWithGrouping() throws {
		let string = "a = b (c);"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .concatenation([.reference("b"), .grouping(.reference("c"))])),
		]

		#expect(rules == expectedRules)
	}

	@Test
	func concatenationWithRepetition() throws {
		let string = "a = b {c};"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .concatenation([.reference("b"), .occurrence(.reference("c"), frequency:  .zeroOrMore)])),
		]

		#expect(rules == expectedRules)
	}
}

extension ParserTests {
	@Test
	func concatenationAlternationPrecedence() throws {
		let string = "test = a b | c;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .alternation([.concatenation([.reference("a"), .reference("b")]), .reference("c")])
		)
		#expect(rules == [expectedRule])
	}

	@Test(.disabled())
	func alternationConcatenationPrecedence() throws {
		let string = "test = a | b c;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRule = Rule(
			name: "test",
			kind: .alternation([.reference("a"), .concatenation([.reference("b"), .reference("c")])])
		)
		#expect(rules == [expectedRule])
	}
}
