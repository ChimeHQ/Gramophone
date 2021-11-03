import Foundation

public struct Rule {
    public enum Kind {
        case concatination([Kind])
        case termination
        case alternation([Kind])
        case optional
        case repetition
        case grouping
        case terminalString
        case comment
        case specialSequence
        case exception
    }

    public var name: String
    public var kind: Kind
}

extension Rule.Kind: Hashable {
}

extension Rule: Hashable {
}
