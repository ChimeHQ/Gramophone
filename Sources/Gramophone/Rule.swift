import Foundation

public struct Rule {
	public indirect enum Kind {
        case concatenation([Kind])
        case alternation([Kind])
        case optional(Kind)
		case repetition(Kind, none: Bool)
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

	public init(_ name: String, kind: Kind) {
		self.name = name
		self.kind = kind
	}
}

extension Rule.Kind: Sendable, Hashable {
}

extension Rule: Sendable, Hashable {
}

extension Rule.Kind: CustomStringConvertible {
	public var description: String {
		recursivePrint(topLevel: true)
	}

	private func recursivePrint(topLevel: Bool = false) -> String {
		switch self {
		case let .concatenation(elements):
			let value = elements.map { $0.recursivePrint() }.joined(separator: ", ")

			return topLevel ? value : "(\(value))"
		case let .alternation(elements):
			let value = elements.map { $0.recursivePrint() }.joined(separator: " | ")

			return topLevel ? value : "(\(value))"
		case let .optional(value):
			return "[\(value.recursivePrint())]"
		case let .terminalString(value):
			return "'\(value)'"
		case let .reference(value):
			return value
		case let .exception(a, b):
			let value = "\(a.recursivePrint()) - \(b.recursivePrint())"

			return topLevel ? value : "(\(value))"
		case let .repetition(value, allowsNone):
			if allowsNone {
				return "{\(value.recursivePrint())}"
			} else {
				return "(\(value.recursivePrint())) +"
			}
		case let .grouping(value):
			return "(\(value.recursivePrint()))"
		default:
			return "<unknown>"
		}
	}
}

extension Rule: CustomStringConvertible {
	public var description: String {
		"\(name) = \(kind);"
	}
}

extension Rule.Kind : ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = .terminalString(value)
	}
}

extension Rule.Kind {
	func traverse(_ block: (Rule.Kind) -> Void) {
		block(self)

		switch self {
		case let .alternation(elements):
			for element in elements {
				element.traverse(block)
			}
		case let .concatenation(elements):
			for element in elements {
				element.traverse(block)
			}
		case let .grouping(a):
			a.traverse(block)
		case let .exception(a, b):
			a.traverse(block)
			b.traverse(block)
		case let .repetition(a, _):
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
		case let .alternation(elements):
			var set = Set<Rule.Kind>()

			for element in elements {
				set.formUnion(element.trailingKinds)
			}

			return set
		case let .concatenation(elements):
			return elements.last!.trailingKinds
		case let .repetition(a, _):
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
		case let .alternation(elements):
			var set = Set<Rule.Kind>()

			for element in elements {
				set.formUnion(element.leadingKinds)
			}

			return set
		case let .concatenation(elements):
			return elements.first!.leadingKinds
		case let .repetition(a, _):
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
			case let .concatenation(elements):
				// this is a tricky calculation
				let pairs = zip(elements, elements.dropFirst())

				for (current, next) in pairs {
					for trailing in current.trailingKinds {
						if case let .reference(name) = trailing {
							map[name, default: Set()].formUnion(next.leadingKinds)
						}
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
		case let .alternation(elements):
			var set = Set<String>()

			for element in elements {
				set.formUnion(element.alternativeNames)
			}

			return set
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
