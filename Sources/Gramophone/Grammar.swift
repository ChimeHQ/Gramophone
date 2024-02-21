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

	/// The set of rule names that are not references by any other rule.
	///
	/// For a well-formed grammar, this should contain 1 value.
	public var unreferencedNames: Set<String> {
		var names = Set(rules.keys)

		for rule in rules.values {
			let refs = rule.kind.references

			names.subtract(refs)
		}

		return names
	}
}

extension Grammar {
	private func computeFirsts(of kind: Rule.Kind) -> Set<Terminal> {
		var unused = FirstMap()

		let firsts = computeFirsts(of: kind, map: &unused)

		return firsts
	}

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
		case let .repetition(a):
			return computeFirsts(of: a, map: &map)
		default:
			return []
		}
	}

	/// Compute the map of rule names to FIRST terminal sets.
	public func computeFirstMap() -> FirstMap {
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
	/// Find all of the primary follow patterns (.terminalString and .reference).
	private var primaryFollowKinds: [String: Set<Rule.Kind>] {
		var followKinds = [String: Set<Rule.Kind>]()

		for rule in rules.values {
			let rulePrimaries = rule.kind.followKinds

			followKinds.merge(rulePrimaries, uniquingKeysWith: { $0.union($1) })
		}

		return followKinds
	}

	private func alternativeNames(of kind: Rule.Kind) -> Set<String> {
		var altNames = kind.alternativeNames

		var newNames = altNames

		while newNames.isEmpty == false {
			let start = altNames

			for name in newNames {
				guard let subrule = rules[name] else { continue }
				
				let subnames = subrule.kind.alternativeNames

				altNames.formUnion(subnames)
			}

			newNames = start.subtracting(altNames)
		}

		return altNames
	}

	/// Compute the map of rule names to FOLLOW terminal sets.
	public func computeFollowMap() -> FollowMap {
		var followMap = FollowMap()

		// step 1, initialize all sets empty, except for the starting production
		let startNames = unreferencedNames

		precondition(startNames.count == 1)

		let start = unreferencedNames.first!

		for (name, _) in rules {
			followMap[name] = Set()
		}

		followMap[start] = Set([.endOfInput])
		followMap["all"] = Set()

		// step 2A: A -> αΒβ
		// FIRST(β) (except for ε) added to FOLLOW(B)
		//
		// Find all of the primary follow patterns (.terminalString and .reference), and track any that have a first of epsilon.
		let firsts = computeFirstMap()
		var epsilonFollows = [String: Set<String>]()

		// step 2B, transform those kinds into terminals
		for (name, kindSet) in primaryFollowKinds {
			precondition(followMap[name] != nil)

			for kind in kindSet {
				switch kind {
				case let .terminalString(value):
					followMap[name]!.insert(.string(value))
				case let .reference(refName):
					guard let firstSet = firsts[refName] else {
						preconditionFailure("unbound reference '\(refName)'")
					}

					followMap[name]!.formUnion(firstSet)

					// special-case ε, and track it separately for the next step
					if firstSet.contains(.epsilon) {
						followMap[name]!.remove(.epsilon)

						epsilonFollows[name, default: Set()].insert(refName)
					}
				default:
					preconditionFailure("unsupposed kind")
				}
			}
		}

		// step 3: copy follows
		//  A -> αΒ
		//  A -> αΒβ where FIRST(β) contains ε
		//  FOLLOW(A) added to FOLLOW(B)
		//
		// This is the trickiest part.

		// track down trailing references
		for rule in rules.values {
			let trailingRefs = rule.kind.trailingReferences
			let follows = epsilonFollows[rule.name] ?? Set()

			// This set represents "B"
			let nameSet = trailingRefs.union(follows)

			for name in nameSet {
				followMap[name]!.formUnion(followMap[rule.name]!)
			}
		}

		// with that done, we've covered everything except for equivalent productions.
		for rule in rules.values {
			let altSet = alternativeNames(of: rule.kind)

			print(rule.name, ":", altSet)

			for altName in altSet {
				followMap[altName]!.formUnion(followMap[rule.name]!)
			}
		}

		followMap["all"] = nil

		return followMap
	}
}
