import Foundation
import Flexer

public enum BNFTokenKind {
    case word
    case terminalString
    case comma
    case equals
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

}

typealias BNFToken = Flexer.Token<BNFTokenKind>

struct BNFTokenSequence: Sequence, IteratorProtocol, StringInitializable {
    public typealias Element = BNFToken

    private var lexer: BasicTextCharacterLexer

    public init(string: String) {
        self.lexer = BasicTextCharacterLexer(string: string)
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
            _ = lexer.nextUntil(in: [.singleQuote])
            let endingToken = lexer.next()

            return BNFToken(kind: .terminalString, start: token, end: endingToken)
        case .doubleQuote:
            _ = lexer.next()
            _ = lexer.nextUntil(in: [.doubleQuote])
            let endingToken = lexer.next()

            return BNFToken(kind: .terminalString, start: token, end: endingToken)
        case .comma:
            _ = lexer.next()

            return BNFToken(kind: .comma, range: token.range)
        case .semicolon:
            _ = lexer.next()

            return BNFToken(kind: .semicolon, range: token.range)
        case .equals:
            _ = lexer.next()
            
            return BNFToken(kind: .equals, range: token.range)
        case .pipe:
            _ = lexer.next()

            return BNFToken(kind: .pipe, range: token.range)
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
