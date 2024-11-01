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

public final class BNFParser {
	public init() {
	}

	/// Parse the input text and return a `Grammar` value.
	public func parseGrammar(_ string: String) throws -> Grammar {
		let rules = try parse(string).get()

		return Grammar(rules: rules)
	}

	/// Parse the input text and return an array of `Rule` values or error.
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

    private func parseReferenceOrUnicodeScalar(_ lexer: BNFLexerReference) throws -> Rule.Kind {
        let name = try lexer.nextName()

		guard name == "U" else {
			return Rule.Kind.reference(name)
		}

		guard lexer.nextIf({ $0.kind == .plus }) != nil else {
			return Rule.Kind.reference(name)
		}

		let numericName = try lexer.nextName()
		let value = UInt32(numericName, radix: 16)!
		let scalar = UnicodeScalar(value)!

		return Rule.Kind.terminalString(String(scalar))
    }

	private func parseBNFReference(_ lexer: BNFLexerReference) throws -> Rule.Kind {
		guard let _ = lexer.nextIf({ $0.kind == .lessThan }) else {
			throw BNFParserError.unexpectedToken
		}

		let name = try lexer.nextName()

		guard let _ = lexer.nextIf({ $0.kind == .greaterThan }) else {
			throw BNFParserError.unexpectedToken
		}

		return Rule.Kind.reference(name)
	}

	private func parseQuotedTerminal(_ lexer: BNFLexerReference) throws -> Rule.Kind {
		guard let expectedQuote = lexer.peek()?.kind else {
			throw BNFParserError.unexpectedToken
		}

		guard let start = lexer.nextIf({ $0.kind == expectedQuote }) else {
			throw BNFParserError.unexpectedToken
		}

		guard let _ = lexer.nextUntil({ $0.kind == expectedQuote }) else {
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
		return try parseQuotedTerminal(lexer)
	}

    private func parseAlternation(_ lexer: BNFLexerReference, leftNode: Rule.Kind) throws -> Rule.Kind {
        precondition(lexer.skipIf({ $0.kind == .pipe }))

        let right = try parsePrimaryExpression(lexer)

        return .alternation(leftNode, right)
    }

    private func parseConcatenation(_ lexer: BNFLexerReference, leftNode: Rule.Kind) throws -> Rule.Kind {
        _ = lexer.skipIf({ $0.kind == .comma })

        let right = try parsePrimaryExpression(lexer)

        return .concatenation(leftNode, right)
    }

	private func parseException(_ lexer: BNFLexerReference, leftNode: Rule.Kind) throws -> Rule.Kind {
		guard lexer.skipIf({ $0.kind == .minus }) else {
			throw BNFParserError.unexpectedToken
		}

		let right = try parsePrimaryExpression(lexer)

		return .exception(leftNode, right)
	}

	private func parseOptional(_ lexer: BNFLexerReference) throws -> Rule.Kind {
		guard let _ = lexer.nextIf({ $0.kind == .openBracket }) else {
			throw BNFParserError.unexpectedToken
		}

		let rule = try parseExpression(lexer)

		guard let _ = lexer.nextIf({ $0.kind == .closeBracket }) else {
			throw BNFParserError.unexpectedToken
		}

		return .optional(rule)
	}

	private func parseRepetition(_ lexer: BNFLexerReference) throws -> Rule.Kind {
		guard let _ = lexer.nextIf({ $0.kind == .openBrace }) else {
			throw BNFParserError.unexpectedToken
		}

		let exp = try parseExpression(lexer)

		guard let _ = lexer.nextIf({ $0.kind == .closeBrace }) else {
			throw BNFParserError.unexpectedToken
		}

		return .repetition(exp)
	}

	private func parseGrouping(_ lexer: BNFLexerReference) throws -> Rule.Kind {
		guard let _ = lexer.nextIf({ $0.kind == .openParen }) else {
			throw BNFParserError.unexpectedToken
		}

		let kind = try parseExpression(lexer)

		guard let _ = lexer.nextIf({ $0.kind == .closeParen }) else {
			throw BNFParserError.unexpectedToken
		}

		return .grouping(kind)
	}

    private func parsePrimaryExpression(_ lexer: BNFLexerReference) throws -> Rule.Kind {
        switch lexer.peek()?.kind {
        case .quote, .doubleQuote:
            return try parseTerminal(lexer)
		case .openBracket:
			return try parseOptional(lexer)
        case .name:
            return try parseReferenceOrUnicodeScalar(lexer)
		case .lessThan:
			return try parseBNFReference(lexer)
		case .openBrace:
			return try parseRepetition(lexer)
		case .openParen:
			return try parseGrouping(lexer)
        default:
            throw BNFParserError.unexpectedToken
        }
    }

    private func parseRuleExpression(_ lexer: BNFLexerReference, leftNode: Rule.Kind) throws -> Rule.Kind? {
        switch lexer.peek()?.kind {
		case .question:
			_ = lexer.next()
			
			return .optional(leftNode)
        case .pipe:
            return try parseAlternation(lexer, leftNode: leftNode)
		case .comma, .name, .quote, .doubleQuote, .openBrace, .openParen:
            return try parseConcatenation(lexer, leftNode: leftNode)
		case .minus:
			return try parseException(lexer, leftNode: leftNode)
		case .closeBrace, .closeParen, .closeBracket:
			return nil
        default:
            throw BNFParserError.unexpectedToken
        }
    }

	private func parseExpression(_ lexer: BNFLexerReference) throws -> Rule.Kind {
		let start = try parsePrimaryExpression(lexer)

		var ending = start

		while true {
			if lexer.skipIf({ $0.kind == .semicolon }) {
				break
			}

			guard let sub = try parseRuleExpression(lexer, leftNode: ending) else {
				break
			}

			ending = sub
		}

		return ending
	}

	func parseAssignmentOperator(_ lexer: BNFLexerReference) throws -> Bool {
		if lexer.skipIf({ $0.kind == .assignment }) {
			return true
		}

		guard lexer.skipIf({ $0.kind == .colon }) else {
			return false
		}

		guard lexer.skipIf({ $0.kind == .colon }) else {
			return false
		}

		return lexer.skipIf({ $0.kind == .assignment })
	}

    private func parseRuleDefinition(_ lexer: BNFLexerReference) throws -> Rule {
        let name = try lexer.nextName()

        guard try parseAssignmentOperator(lexer) else {
            throw BNFParserError.unexpectedToken
        }

        let exp = try parseExpression(lexer)

        return Rule(name: name, kind: exp)
    }
}
