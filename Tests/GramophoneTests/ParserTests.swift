import XCTest
@testable import Gramophone

final class ParserTests: XCTestCase {
    func testConcatenation() throws {
        let string = "test = 'a' | 'b' | 'c';"
        let parser = BNFParser()

        let rules = try parser.parse(string).get()

        XCTAssertEqual(rules.count, 1)
    }
}
