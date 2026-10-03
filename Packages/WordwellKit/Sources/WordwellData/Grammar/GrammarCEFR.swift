/// Single CEFR step for a lesson. Each step belongs to one of the three display bands (`GrammarLevel`).
public enum GrammarCEFR: Int, Comparable, CaseIterable, Sendable {
    case a1, a2, b1, b2, c1

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    public var label: String {
        switch self {
        case .a1: "A1"
        case .a2: "A2"
        case .b1: "B1"
        case .b2: "B2"
        case .c1: "C1"
        }
    }

    public var band: GrammarLevel {
        switch self {
        case .a1, .a2: .foundation
        case .b1, .b2: .intermediate
        case .c1: .advanced
        }
    }
}
