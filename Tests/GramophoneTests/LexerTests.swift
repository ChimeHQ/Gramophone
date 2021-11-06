import XCTest
@testable import Gramophone

final class LexerTests: XCTestCase {
    func testPunctuation() throws {
        let string = "=[],|;.→{}()?*'\"+"
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
        XCTAssertEqual(lexer.next(), BNFToken(kind: .plus, range: NSRange(16..<17), in: string))
    }

    func testName() throws {
        let string = "word CapsInWord word-with-dashes under_score"
        var lexer = BNFLexer(string: string)

        XCTAssertEqual(lexer.next(), BNFToken(kind: .name, range: NSRange(0..<4), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .name, range: NSRange(5..<15), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .name, range: NSRange(16..<32), in: string))
        XCTAssertEqual(lexer.next(), BNFToken(kind: .name, range: NSRange(33..<44), in: string))
    }
}
