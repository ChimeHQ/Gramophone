import Foundation

/// Represent a language grammar.
public struct Grammar {
	public typealias RuleMap = [String: Rule]
	public typealias FirstMap = [String: Set<Terminal>]
	public typealias FollowMap = FirstMap

	public let rules: RuleMap

	public init(rules: [Rule]) {
		self.rules = RuleMap(uniqueKeysWithValues: rules.map { ($0.name, $0) })
	}
}

extension Grammar {
	private func computeFirsts(of kind: Rule.Kind, map: inout FirstMap) -> Set<Terminal> {
		switch kind {
		case let .terminalString(value):
			return [.string(value)]
		case let .concatenation(a, _):
			return computeFirsts(of: a, map: &map)
		case let .alternation(a, b):
			let aFirsts = computeFirsts(of: a, map: &map)
			let bFirsts = computeFirsts(of: b, map: &map)

			return aFirsts.union(bFirsts)
		case let .grouping(a):
			return computeFirsts(of: a, map: &map)
		case .reference("all"):
			return [Terminal.all]
		case let .reference(name):
			if let firsts = map[name] {
				return firsts
			}

			guard let production = rules[name] else {
				preconditionFailure("unbound reference '\(name)'")
			}

			let firsts = computeFirsts(of: production.kind, map: &map)

			map[name] = firsts

			return firsts
		case let .exception(a, b):
			let aFirsts = computeFirsts(of: a, map: &map)
			let bFirsts = computeFirsts(of: b, map: &map)

			return aFirsts.subtracting(bFirsts)
		default:
			return []
		}
	}

	/// Compute the map of rule names to FIRST terminal sets.
	public var firstMap: FirstMap {
		var firsts = FirstMap()

		for rule in rules.values {
			if firsts[rule.name]?.isEmpty == false {
				continue
			}

			let ruleFirsts = computeFirsts(of: rule.kind, map: &firsts)

			firsts[rule.name] = ruleFirsts
		}

		return firsts
	}
}

extension Grammar {
	private func computeFollows(of kind: Rule.Kind, map: inout FirstMap) -> Set<Terminal> {
		return []
	}

	/// Compute the map of rule names to FOLLOW terminal sets.
	public var followMap: FollowMap {
		var follows = FollowMap()

		for rule in rules.values {
			if follows[rule.name]?.isEmpty == false {
				continue
			}

			let ruleFollows = computeFollows(of: rule.kind, map: &follows)

			follows[rule.name] = ruleFollows
		}

		return follows
	}
}
