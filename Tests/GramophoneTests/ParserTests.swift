import XCTest
@testable import Gramophone

final class ParserTests: XCTestCase {
    func testConcatenation() throws {
        let string = "test = 'a' | 'b';"
        let parser = BNFParser()

        let rules = try parser.parse(string).get()

        XCTAssertEqual(rules.count, 1)

        let expectedRule = Rule(name: "test",
                                kind: .alternation(.terminalString("a"), .terminalString("b")))
        XCTAssertEqual(rules[0], expectedRule)
    }
}
