import Foundation
import Testing
@testable import Gramophone

struct LexerTests {
	@Test
	func punctuation() throws {
		let string = "=[],|;.→{}()?*'\"+:-`´<>"
		var lexer = BNFLexer(string: string)

		#expect(lexer.next() == BNFToken(kind: .assignment, range: NSRange(0..<1), in: string))
		#expect(lexer.next() == BNFToken(kind: .openBracket, range: NSRange(1..<2), in: string))
		#expect(lexer.next() == BNFToken(kind: .closeBracket, range: NSRange(2..<3), in: string))
		#expect(lexer.next() == BNFToken(kind: .comma, range: NSRange(3..<4), in: string))
		#expect(lexer.next() == BNFToken(kind: .pipe, range: NSRange(4..<5), in: string))
		#expect(lexer.next() == BNFToken(kind: .semicolon, range: NSRange(5..<6), in: string))
		#expect(lexer.next() == BNFToken(kind: .period, range: NSRange(6..<7), in: string))
		#expect(lexer.next() == BNFToken(kind: .assignment, range: NSRange(7..<8), in: string))
		#expect(lexer.next() == BNFToken(kind: .openBrace, range: NSRange(8..<9), in: string))
		#expect(lexer.next() == BNFToken(kind: .closeBrace, range: NSRange(9..<10), in: string))
		#expect(lexer.next() == BNFToken(kind: .openParen, range: NSRange(10..<11), in: string))
		#expect(lexer.next() == BNFToken(kind: .closeParen, range: NSRange(11..<12), in: string))
		#expect(lexer.next() == BNFToken(kind: .question, range: NSRange(12..<13), in: string))
		#expect(lexer.next() == BNFToken(kind: .star, range: NSRange(13..<14), in: string))
		#expect(lexer.next() == BNFToken(kind: .quote, range: NSRange(14..<15), in: string))
		#expect(lexer.next() == BNFToken(kind: .doubleQuote, range: NSRange(15..<16), in: string))
		#expect(lexer.next() == BNFToken(kind: .plus, range: NSRange(16..<17), in: string))
		#expect(lexer.next() == BNFToken(kind: .colon, range: NSRange(17..<18), in: string))
		#expect(lexer.next() == BNFToken(kind: .minus, range: NSRange(18..<19), in: string))
		#expect(lexer.next() == BNFToken(kind: .quote, range: NSRange(19..<20), in: string))
		#expect(lexer.next() == BNFToken(kind: .quote, range: NSRange(20..<21), in: string))
		#expect(lexer.next() == BNFToken(kind: .lessThan, range: NSRange(21..<22), in: string))
		#expect(lexer.next() == BNFToken(kind: .greaterThan, range: NSRange(22..<23), in: string))
	}

	@Test
	func name() throws {
		let string = "word CapsInWord under_score a b 123 a111"
		var lexer = BNFLexer(string: string)

		#expect(lexer.next() == BNFToken(kind: .name, range: NSRange(0..<4), in: string))
		#expect(lexer.next() == BNFToken(kind: .name, range: NSRange(5..<15), in: string))
		#expect(lexer.next() == BNFToken(kind: .name, range: NSRange(16..<27), in: string))
		#expect(lexer.next() == BNFToken(kind: .name, range: NSRange(28..<29), in: string))
		#expect(lexer.next() == BNFToken(kind: .name, range: NSRange(30..<31), in: string))
		#expect(lexer.next() == BNFToken(kind: .name, range: NSRange(32..<35), in: string))
		#expect(lexer.next() == BNFToken(kind: .name, range: NSRange(36..<40), in: string))
	}
}
