import Foundation

extension UnicodeScalar {
	var formattedString: String {
		let shortString = String(self.value, radix: 16)
		let padding = String(repeating: "0", count: max(4 - shortString.count, 0))

		return "U+" + padding + shortString
	}
}

public struct Rule {
	public enum Frequency: Sendable, Hashable {
		case zeroOrOne
		case zeroOrMore
		case oneOrMore
	}

	public indirect enum Kind {
        case concatenation([Kind])
        case alternation([Kind])
		case occurrence(Kind, frequency: Frequency)
        case grouping(Kind)
        case terminalString(String)
		case terminalCharacter(UnicodeScalar)
        case comment
        case specialSequence
        case exception(Kind, Kind)
        case reference(String)
		case range(UnicodeScalar, UnicodeScalar)

		public static let epsilon = terminalString("")

		public static func optional(_ kind: Kind) -> Kind {
			.occurrence(kind, frequency: .zeroOrOne)
		}

		public static func terminalCharacter(_ int: Int) -> Kind {
			.terminalCharacter(UnicodeScalar(int)!)
		}

		public static func range(_ a: Int, _ b: Int) -> Kind {
			.range(UnicodeScalar(a)!, UnicodeScalar(b)!)
		}
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
		recursivePrint(grouped: true)
	}

	private func recursivePrint(grouped: Bool = false) -> String {
		switch self {
		case let .concatenation(elements):
			let value = elements.map { $0.recursivePrint() }.joined(separator: ", ")

			return grouped ? value : "(\(value))"
		case let .alternation(elements):
			let value = elements.map { $0.recursivePrint() }.joined(separator: " | ")

			return grouped ? value : "(\(value))"
		case let .terminalString(value):
			return "'\(value)'"
		case let .terminalCharacter(char):
			return char.formattedString
		case let .reference(value):
			return value
		case let .exception(a, b):
			let value = "\(a.recursivePrint()) - \(b.recursivePrint())"

			return grouped ? value : "(\(value))"
		case let .occurrence(value, frequency):
			switch frequency {
			case .zeroOrOne:
				return "[\(value.recursivePrint(grouped: true))]"
			case .zeroOrMore:
				return "{\(value.recursivePrint(grouped: true))}"
			case .oneOrMore:
				return "(\(value.recursivePrint(grouped: true))) +"
			}
		case let .grouping(value):
			return "(\(value.recursivePrint(grouped: true)))"
		case let .range(from, to):
			return "[\(from.formattedString)-\(to.formattedString)]"
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
		case let .occurrence(a, _):
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
		case let .occurrence(a, _):
			return a.trailingKinds
		case let .grouping(a):
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
		case let .occurrence(a, _):
			return a.leadingKinds
		case let .grouping(a):
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
