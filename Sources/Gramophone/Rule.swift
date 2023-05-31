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

		public static let epsilon = terminalString("")
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

extension Rule.Kind {
	func traverse(_ block: (Rule.Kind) -> Void) {
		block(self)

		switch self {
		case let .alternation(a, b):
			a.traverse(block)
			b.traverse(block)
		case let .concatenation(a, b):
			a.traverse(block)
			b.traverse(block)
		case let .grouping(a):
			a.traverse(block)
		case let .exception(a, b):
			a.traverse(block)
			b.traverse(block)
		case let .repetition(a):
			a.traverse(block)
		case let .optional(a):
			a.traverse(block)
		default:
			break
		}
	}
}

extension Rule.Kind {
	var trailingKinds: Set<Rule.Kind> {
		switch self {
		case let .alternation(a, b):
			return a.trailingKinds.union(b.trailingKinds)
		case let .concatenation(_, b):
			return b.trailingKinds
		case let .repetition(a):
			return a.trailingKinds
		case let .grouping(a):
			return a.trailingKinds
		case let .optional(a):
			return a.trailingKinds
		default:
			return [self]
		}
	}

	var leadingKinds: Set<Rule.Kind> {
		switch self {
		case let .alternation(a, b):
			return a.leadingKinds.union(b.leadingKinds)
		case let .concatenation(a, _):
			return a.leadingKinds
		case let .repetition(a):
			return a.leadingKinds
		case let .grouping(a):
			return a.leadingKinds
		case let .optional(a):
			return a.leadingKinds
		default:
			return [self]
		}
	}

	var followKinds: [String: Set<Rule.Kind>] {
		var map = [String: Set<Rule.Kind>]()

		traverse { value in
			switch value {
			case let .concatenation(a, b):
				for trailing in a.trailingKinds {
					if case let .reference(name) = trailing {
						map[name, default: Set()].formUnion(b.leadingKinds)
					}
				}
			default:
				break
			}
		}

		return map
	}

	var references: Set<String> {
		var set = Set<String>()

		traverse { kind in
			if case let .reference(string) = kind {
				set.insert(string)
			}
		}

		return set
	}

	var alternativeNames: Set<String> {
		switch self {
		case let .alternation(a, b):
			return a.alternativeNames.union(b.alternativeNames)
		case let .reference(name):
			return [name]
		case let .grouping(a):
			return a.alternativeNames
		default:
			return []
		}
	}

	var trailingReferences: Set<String> {
		var set = Set<String>()

		for kind in trailingKinds {
			if case let .reference(string) = kind {
				set.insert(string)
			}
		}

		return set
	}
}
