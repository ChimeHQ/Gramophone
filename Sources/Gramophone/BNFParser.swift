import Foundation
import Flexer

public enum BNFParserError: Error {
    case emptyInput
    case unexpectedToken
    case missingCloseQuote
}

extension BNFLexerReference {
    func nextName() throws -> String {
        guard peek()?.kind == .name else { throw BNFParserError.unexpectedToken }

        guard let token = next() else { throw BNFParserError.unexpectedToken }

        precondition(token.kind == .name)

        let value = String(substring(for: token))

        return value
    }
}

public class BNFParser {
    public func parse(_ string: String) -> Result<[Rule], Error> {
        if string.isEmpty {
            return .failure(BNFParserError.emptyInput)
        }

        let lexer = BNFLexer(string: string).reference

        var rules = [Rule]()

        while let token = lexer.peek() {
            switch token.kind {
            case .name:
                do {
                    let rule = try parseRuleDefinition(lexer)

                    rules.append(rule)
                } catch {
                    return .failure(error)
                }
            default:
                _ = lexer.next()
            }
        }

        return .success(rules)
    }

    private func parseReference(_ lexer: BNFLexerReference) throws -> Rule.Kind {
        let name = try lexer.nextName()

        return Rule.Kind.reference(name)
    }

    private func parseSingleQuoteTerminal(_ lexer: BNFLexerReference) throws -> Rule.Kind {
        guard let start = lexer.nextIf({ $0.kind == .quote }) else {
            throw BNFParserError.unexpectedToken
        }

        guard let _ = lexer.nextUntil({ $0.kind == .quote }) else {
            throw BNFParserError.missingCloseQuote
        }

        guard let end = lexer.next() else {
            throw BNFParserError.unexpectedToken
        }
        
        let contentRange = start.range.upperBound..<end.range.lowerBound

        let name = String(lexer.string[contentRange])

        return .terminalString(name)
    }

    private func parseTerminal(_ lexer: BNFLexerReference) throws -> Rule.Kind {
        return try parseSingleQuoteTerminal(lexer)
    }

    private func parseAlternation(_ lexer: BNFLexerReference, leftNode: Rule.Kind) throws -> Rule.Kind {
        precondition(lexer.skipIf({ $0.kind == .pipe }))

        let right = try parsePrimaryExpression(lexer)

        return .alternation(leftNode, right)
    }

    private func parsePrimaryExpression(_ lexer: BNFLexerReference) throws -> Rule.Kind {
        switch lexer.peek()?.kind {
        case .quote, .doubleQuote:
            return try parseTerminal(lexer)
        case .name:
            return try parseReference(lexer)
        default:
            throw BNFParserError.unexpectedToken
        }
    }

    private func parseRuleExpression(_ lexer: BNFLexerReference, leftNode: Rule.Kind) throws -> Rule.Kind {
        switch lexer.peek()?.kind {
        case .semicolon:
            _ = lexer.next()

            return leftNode
        case .pipe:
            return try parseAlternation(lexer, leftNode: leftNode)
        default:
            throw BNFParserError.unexpectedToken
        }
    }

    private func parseRuleDefinition(_ lexer: BNFLexerReference) throws -> Rule {
        let name = try lexer.nextName()

        guard lexer.skipIf({ $0.kind == .assignment }) else {
            throw BNFParserError.unexpectedToken
        }

        let start = try parsePrimaryExpression(lexer)

        let kind = try parseRuleExpression(lexer, leftNode: start)

        return Rule(name: name, kind: kind)
    }
}
