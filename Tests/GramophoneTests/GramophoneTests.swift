import XCTest
@testable import Gramophone

final class GramophoneTests: XCTestCase {
//    func testConcatenationDefinition() throws {
//        let string = "concatenation = 'a', 'b', 'c';"
//        var lexer = BNFLexer(string: string)
//
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .word, range: NSRange(0..<13), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .equals, range: NSRange(14..<15), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(16..<19), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .comma, range: NSRange(19..<20), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(21..<24), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .comma, range: NSRange(24..<25), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(26..<29), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .semicolon, range: NSRange(29..<30), in: string))
//    }
//
//    func testAlternation() throws {
//        let string = "alternation = 'a' | 'b' | 'c';"
//        var lexer = BNFLexer(string: string)
//
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .word, range: NSRange(0..<11), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .equals, range: NSRange(12..<13), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(14..<17), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .pipe, range: NSRange(18..<19), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(20..<23), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .pipe, range: NSRange(24..<25), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .terminalString, range: NSRange(26..<29), in: string))
//        XCTAssertEqual(lexer.next(), BNFToken(kind: .semicolon, range: NSRange(29..<30), in: string))
//    }

    func testPunctuation() throws {
        let string = "=[],|;.→{}()?*'\""
        var lexer = BNFLexer(string: string)

        XCTAssertEqual(lexer.next(), BNFToken(kind: .assignment, range: NSRange(0..<1), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .openBracket, range: NSRange(1..<2), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .closeBracket, range: NSRange(2..<3), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .comma, range: NSRange(3..<4), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .pipe, range: NSRange(4..<5), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .semicolon, range: NSRange(5..<6), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .period, range: NSRange(6..<7), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .assignment, range: NSRange(7..<8), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .openBrace, range: NSRange(8..<9), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .closeBrace, range: NSRange(9..<10), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .openParen, range: NSRange(10..<11), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .closeParen, range: NSRange(11..<12), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .question, range: NSRange(12..<13), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .star, range: NSRange(13..<14), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .quote, range: NSRange(14..<15), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .doubleQuote, range: NSRange(15..<16), in: string))
    }
}
