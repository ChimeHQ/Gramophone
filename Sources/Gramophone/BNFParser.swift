import Foundation

public enum BNFParserError: Error {
    case emptyInput
}

public class BNFParser {
    public func parse(_ string: String) -> Result<[Rule], BNFParserError> {
        if string.isEmpty {
            return .failure(.emptyInput)
        }

        var lexer = BNFLexer(string: string)

        var rules = [Rule]()

        while let token = lexer.next() {
        }

        return .success(rules)
    }
}
