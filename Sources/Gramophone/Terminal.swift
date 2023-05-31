import Foundation

public enum Terminal {
	case string(String)
	case characterSet(CharacterSet)
	case endOfInput

	static let all = Terminal.characterSet(
		CharacterSet.whitespacesAndNewlines.union(.illegalCharacters).inverted
	)

	static let epsilon = Terminal.string("")
}

extension Terminal: Hashable {}
extension Terminal: Sendable {}

extension Terminal: CustomStringConvertible {
	public var description: String {
		switch self {
		case .string(""):
			return "ε"
		case let .string(value):
			return "'\(value)'"
		case let .characterSet(set):
			return set.description
		case .endOfInput:
			return "$"
		}
	}
}

extension Terminal: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		if value == "" {
			self = .endOfInput
		} else {
			self = .string(value)
		}
	}
}
