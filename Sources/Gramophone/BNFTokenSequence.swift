import Foundation
import Flexer

public enum BNFTokenKind {
    case word
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

    case assignment
}

typealias BNFToken = Flexer.Token<BNFTokenKind>

struct BNFTokenSequence: Sequence, IteratorProtocol, StringInitializable {
    public typealias Element = BNFToken

    private var lexer: BasicTextCharacterLexer

    public init(string: String) {
        self.lexer = BasicTextCharacterLexer(string: string)
    }

    public var string: String {
        return lexer.string
    }

    public mutating func next() -> Element? {
        _ = lexer.nextUntil(notIn: [.space, .tab, .newline])

        guard let token = lexer.peek() else {
            return nil
        }

        switch token.kind {
        case .lowercaseLetter, .uppercaseLetter:
            let endingToken = lexer.nextUntil(notIn: [.lowercaseLetter, .uppercaseLetter, .dash, .underscore])

            return BNFToken(kind: .word, start: token, end: endingToken)
        case .singleQuote:
            _ = lexer.next()

            return BNFToken(kind: .quote, range: token.range)
        case .doubleQuote:
            _ = lexer.next()

            return BNFToken(kind: .doubleQuote, range: token.range)
        case .comma:
            _ = lexer.next()

            return BNFToken(kind: .comma, range: token.range)
        case .semicolon:
            _ = lexer.next()

            return BNFToken(kind: .semicolon, range: token.range)
        case .equals:
            _ = lexer.next()
            
            return BNFToken(kind: .assignment, range: token.range)
        case .openBracket:
            _ = lexer.next()

            return BNFToken(kind: .openBracket, range: token.range)
        case .closeBracket:
            _ = lexer.next()

            return BNFToken(kind: .closeBracket, range: token.range)
        case .openBrace:
            _ = lexer.next()

            return BNFToken(kind: .openBrace, range: token.range)
        case .closeBrace:
            _ = lexer.next()

            return BNFToken(kind: .closeBrace, range: token.range)
        case .openParen:
            _ = lexer.next()

            return BNFToken(kind: .openParen, range: token.range)
        case .closeParen:
            _ = lexer.next()

            return BNFToken(kind: .closeParen, range: token.range)
        case .period:
            _ = lexer.next()

            return BNFToken(kind: .period, range: token.range)
        case .pipe:
            _ = lexer.next()

            return BNFToken(kind: .pipe, range: token.range)
        case .question:
            _ = lexer.next()

            return BNFToken(kind: .question, range: token.range)
        case .star:
            _ = lexer.next()

            return BNFToken(kind: .star, range: token.range)
        case .otherCharacter:
            _ = lexer.next()
            
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

        return BNFToken(kind: .word, start: token, end: endingToken)
    }
}

typealias BNFLexer = LookAheadSequence<BNFTokenSequence>
