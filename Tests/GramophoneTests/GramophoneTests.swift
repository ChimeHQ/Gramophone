import XCTest
@testable import Gramophone

final class GramophoneTests: XCTestCase {
    func testConcatenationDefinition() throws {
        let string = "concatenation = 'a', 'b', 'c';"
        var lexer = BNFLexer(string: string)

        XCTAssertEqual(lexer.next(), BNFToken(kind: .word, range: NSRange(0..<13), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .equals, range: NSRange(14..<15), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(16..<19), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .comma, range: NSRange(19..<20), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(21..<24), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .comma, range: NSRange(24..<25), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(26..<29), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .semicolon, range: NSRange(29..<30), in: string))
    }

    func testAlternation() throws {
        let string = "alternation = 'a' | 'b' | 'c';"
        var lexer = BNFLexer(string: string)

        XCTAssertEqual(lexer.next(), BNFToken(kind: .word, range: NSRange(0..<11), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .equals, range: NSRange(12..<13), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(14..<17), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .pipe, range: NSRange(18..<19), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(20..<23), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .pipe, range: NSRange(24..<25), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(26..<29), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .semicolon, range: NSRange(29..<30), in: string))
    }
}
