import XCTest
@testable import Gramophone

final class GramophoneTests: XCTestCase {
    func testExample() throws {
        let string = "concatenation = 'a', 'b', 'c';"
        var lexer = BNFLexer(string: string)

        XCTAssertEqual(lexer.next(), BNFToken(kind: .word, range: NSRange(0..<13), in: string))
    }
}
