import XCTest
@testable import Gramophone

final class ParserTests: XCTestCase {
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

	func testOptional() throws {
		let string = "test = ['-'], 'a';"
		let parser = BNFParser()

		let rules = try parser.parse(string).get()

		XCTAssertEqual(rules.count, 1)

		let expectedRule = Rule(name: "test",
								kind: .concatenation(.optional(.terminalString("-")), .terminalString("a")))
		XCTAssertEqual(rules[0], expectedRule)
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
}
