import Foundation
import Gramophone

let fileURL = URL(fileURLWithPath: CommandLine.arguments[1])
let string = try String(contentsOf: fileURL)

let parser = BNFParser()

let rules = try parser.parse(string).get()

for rule in rules {
	print(rule)
}
