import Foundation

public enum Terminal {
	case string(String)
	case characterSet(CharacterSet)

	static let all = Terminal.characterSet(
		CharacterSet.whitespacesAndNewlines.union(.illegalCharacters).inverted
	)
}

extension Terminal: Hashable {}
extension Terminal: Sendable {}

extension Terminal: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .string(value):
			return "'\(value)'"
		case let .characterSet(set):
			return set.description
		}
	}
}
