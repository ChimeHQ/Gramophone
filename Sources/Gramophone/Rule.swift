import Foundation

public struct Rule {
    public enum Kind {
        case concatenation([Kind])
        case termination
        case alternation([Kind])
        case optional
        case repetition
        case grouping
        case terminalString
        case comment
        case specialSequence
        case exception
        case reference(String)
    }

    public var name: String
    public var kind: Kind
}

extension Rule.Kind: Hashable {
}

extension Rule: Hashable {
}
