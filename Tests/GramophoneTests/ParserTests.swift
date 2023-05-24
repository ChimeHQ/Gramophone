import XCTest
@testable import Gramophone

final class ParserTests: XCTestCase {
	func testAssignment() throws {
		let string = "test = 'a';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .terminalString("a"))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testBNFStyleAssignment() throws {
		let string = "test ::= abc;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .reference("abc"))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testBackslashTerminal() throws {
		let string = "test = '\\';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .terminalString("\\"))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testReference() throws {
		let string = "test = something;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .reference("something"))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testBNFStyleReference() throws {
		throw XCTSkip()
		
		let string = "test = <something>;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .reference("<something>"))
		XCTAssertEqual(rules[0], expectedRule)
	}

    func testAlternation() throws {
        let string = "test = 'a' | 'b';"
        let parser = BNFParser()

        let rules = try parser.parse(string).get()

        XCTAssertEqual(rules.count, 1)

        let expectedRule = Rule(name: "test",
                                kind: .alternation(.terminalString("a"), .terminalString("b")))
        XCTAssertEqual(rules[0], expectedRule)
    }

    func testConcatenation() throws {
        let string = "test = 'a' , 'b';"
        let parser = BNFParser()

        let rules = try parser.parse(string).get()

        XCTAssertEqual(rules.count, 1)

        let expectedRule = Rule(name: "test",
                                kind: .concatenation(.terminalString("a"), .terminalString("b")))
        XCTAssertEqual(rules[0], expectedRule)
    }

	func testImplicitConcatenation() throws {
		let string = "test = 'a' 'b';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .concatenation(.terminalString("a"), .terminalString("b")))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testOptional() throws {
		let string = "test = ['-'], 'a';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .concatenation(.optional(.terminalString("-")), .terminalString("a")))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testTailingOptional() throws {
		let string = "a = b?;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .optional(.reference("b"))),
		]

		XCTAssertEqual(rules, expectedRules)
	}

	func testRepetition() throws {
		let string = "test = {'a'};"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .repetition(.terminalString("a")))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testGrouping() throws {
		let string = "test = ('a');"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .grouping(.terminalString("a")))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testException() throws {
		let string = "test = a - b;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .exception(.reference("a"), .reference("b")))
		XCTAssertEqual(rules[0], expectedRule)

	}
}

extension ParserTests {
	func testAssignmentWithArrow() throws {
		let string = "test → 'a';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .terminalString("a"))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testEmptyCodePoint() throws {
		let string = "test = U+0000;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .terminalString("\u{0000}"))
		XCTAssertEqual(rules[0], expectedRule)
	}

	func testFiveDigitCodePoint() throws {
		let string = "test = U+1F34E;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .terminalString("🍎"))
		XCTAssertEqual(rules[0], expectedRule)
	}
}

extension ParserTests {
	func testMultipleRules() throws {
		let string = "a = 'a';b = 'b';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .terminalString("a")),
			Rule(name: "b", kind: .terminalString("b")),
		]
		
		XCTAssertEqual(rules, expectedRules)
	}

	func testConcatentionWithinRepetition() throws {
		let string = "a = {a, b};"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .repetition(.concatenation(.reference("a"), .reference("b"))))
		]

		XCTAssertEqual(rules, expectedRules)
	}

	func testConcatentionWithGrouping() throws {
		let string = "a = b {c};"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		let expectedRules = [
			Rule(name: "a", kind: .concatenation(.reference("b"), .repetition(.reference("c")))),
		]

		XCTAssertEqual(rules, expectedRules)
	}
}

extension ParserTests {
	func testConcatenationAlternationPrecedence() throws {
		let string = "test = a b | c;"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .alternation(.concatenation(.reference("a"), .reference("b")), .reference("c")))
		XCTAssertEqual(rules[0], expectedRule)
	}
}
