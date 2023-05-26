import Foundation

public struct Rule {
    public indirect enum Kind {
        case concatenation(Kind, Kind)
        case alternation(Kind, Kind)
        case optional(Kind)
        case repetition(Kind)
        case grouping(Kind)
        case terminalString(String)
		case oneOrMore
        case comment
        case specialSequence
        case exception(Kind, Kind)
        case reference(String)
    }

    public var name: String
    public var kind: Kind

	public init(name: String, kind: Kind) {
		self.name = name
		self.kind = kind
	}
}

extension Rule.Kind: Hashable {
}

extension Rule: Hashable {
}

extension Rule.Kind: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .concatenation(a, b):
			return "\(a), \(b)"
		case let .alternation(a, b):
			return "\(a) | \(b)"
		case let .optional(value):
			return "[\(value)]"
		case let .terminalString(value):
			return "'\(value)'"
		case let .reference(value):
			return value
		case let .exception(a, b):
			return "\(a) - \(b)"
		case let .repetition(value):
			return "{\(value)}"
		case let .grouping(value):
			return "(\(value))"
		default:
			return ""
		}
	}
}

extension Rule: CustomStringConvertible {
	public var description: String {
		"\(name) = \(kind);"
	}
}
