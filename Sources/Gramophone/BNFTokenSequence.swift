import Foundation
import Flexer

public enum BNFTokenKind {
    case name
    case comma
    case period
    case semicolon
    case colon
    case openParen
    case closeParen
    case openBrace
    case closeBrace
    case openBracket
    case closeBracket
    case quote
    case doubleQuote
    case question
    case minus
    case pipe
    case star
    case plus

    case assignment
}

typealias BNFToken = Flexer.Token<BNFTokenKind>

extension BNFToken {
    public init?(kind: Kind, start: BasicTextCharacter, end: BasicTextCharacter?) {
        let endIndex = end?.endIndex ?? start.endIndex

        self.init(kind: kind, range: start.startIndex..<endIndex)
    }
}

struct BNFTokenSequence: Sequence, IteratorProtocol, StringInitializable {
    public typealias Element = BNFToken

    private var lexer: BasicTextCharacterLexer

    public init(string: String) {
        self.lexer = BasicTextCharacterLexer(string: string)
    }

    public var string: String {
        return lexer.string
    }

	private var nameComponents: Set<BasicTextCharacterKind> = [
		.lowercaseLetter,
		.uppercaseLetter,
		.dash,
		.underscore,
		.digit
	]

    public mutating func next() -> Element? {
        _ = lexer.nextUntil(notIn: [.space, .tab, .newline])

        guard let token = lexer.next() else {
            return nil
        }

        switch token.kind {
		case .lowercaseLetter, .uppercaseLetter, .dash, .underscore, .digit:
			// this is because we have advanced instead of peeking, so a single character name will go too far
			if let peek = lexer.peek()?.kind, nameComponents.contains(peek) == false {
				return BNFToken(kind: .name, range: token.range)
			}

            let endingToken = lexer.nextUntil(notIn: nameComponents)

            return BNFToken(kind: .name, start: token, end: endingToken)
        case .singleQuote:
            return BNFToken(kind: .quote, range: token.range)
        case .doubleQuote:
            return BNFToken(kind: .doubleQuote, range: token.range)
        case .comma:
            return BNFToken(kind: .comma, range: token.range)
        case .semicolon:
            return BNFToken(kind: .semicolon, range: token.range)
        case .equals:
            return BNFToken(kind: .assignment, range: token.range)
        case .openBracket:
            return BNFToken(kind: .openBracket, range: token.range)
        case .closeBracket:
            return BNFToken(kind: .closeBracket, range: token.range)
        case .openBrace:
            return BNFToken(kind: .openBrace, range: token.range)
        case .closeBrace:
            return BNFToken(kind: .closeBrace, range: token.range)
        case .openParen:
            return BNFToken(kind: .openParen, range: token.range)
        case .closeParen:
            return BNFToken(kind: .closeParen, range: token.range)
        case .period:
            return BNFToken(kind: .period, range: token.range)
        case .pipe:
            return BNFToken(kind: .pipe, range: token.range)
        case .question:
            return BNFToken(kind: .question, range: token.range)
        case .star:
            return BNFToken(kind: .star, range: token.range)
        case .plus:
            return BNFToken(kind: .plus, range: token.range)
        case .otherCharacter:
            if string[token.range] == "→" {
                return BNFToken(kind: .assignment, range: token.range)
            }

            return nil
        default:
            break
        }

        let endingToken = lexer.nextUntil(in: [.newline,
                                               .tab,
                                               .space,
                                               .lowercaseLetter,
                                               .uppercaseLetter,
                                               .underscore,
                                               .digit])

        return BNFToken(kind: .name, start: token, end: endingToken)
    }
}

typealias BNFLexer = LookAheadSequence<BNFTokenSequence>
typealias BNFLexerReference = LookAheadSequenceReference<BNFTokenSequence>
