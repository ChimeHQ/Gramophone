import Foundation

public struct Rule {
    public indirect enum Kind {
        case concatenation(Kind, Kind)
        case termination
        case alternation(Kind, Kind)
        case optional
        case repetition
        case grouping
        case terminalString(String)
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
