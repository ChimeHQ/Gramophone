import Foundation
import Flexer

public enum BNFParserError: Error {
    case emptyInput
    case unexpectedToken
}

public class BNFParser {
    public func parse(_ string: String) -> Result<[Rule], BNFParserError> {
        if string.isEmpty {
            return .failure(.emptyInput)
        }

        let lexer = BNFLexer(string: string).reference

        var rules = [Rule]()

        while let token = lexer.peek() {
            switch token.kind {
            case .name:
                let result = parseRuleDefinition(lexer)

                switch result {
                case .success(let rule):
                    rules.append(rule)
                case .failure(let error):
                    return .failure(error)
                }

            default:
                _ = lexer.next()
            }
        }

        return .success(rules)
    }

    private func parseRuleDefinition(_ lexer: BNFLexerReference) -> Result<Rule, BNFParserError> {
        guard let nameToken = lexer.next() else { return .failure(.unexpectedToken) }

        guard nameToken.kind == .name else { return .failure(.unexpectedToken) }

        let string = lexer.string

        let name = String(string[nameToken.range])

        return .success(Rule(name: name, kind: .terminalString))
    }
}
