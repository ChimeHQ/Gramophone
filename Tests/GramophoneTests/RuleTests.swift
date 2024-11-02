import Testing
import Gramophone

struct RuleTests {
    @Test
	func renderingNesting() async throws {
		let ruleA = Rule(
			"test",
			kind: .alternation([.reference("a"), .concatenation([.reference("b"), .reference("c")])])
		)

		#expect(ruleA.description == "test = a | (b, c);")

		let ruleB = Rule(
			"test",
			kind: .concatenation([.alternation([.reference("a"), .reference("b")]), .reference("c")])
		)

		#expect(ruleB.description == "test = (a | b), c;")
    }

	@Test
	func suppressingUnnecessaryGrouping() async throws {
		let rule = Rule(
			"test",
			kind: .repetition(.concatenation(["a", "b"]), none: true)
		)

		#expect(rule.description == "test = {'a', 'b'};")
	}
}
