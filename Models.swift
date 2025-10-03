import Foundation

enum CodeType {
    case gtin
    case sscc
    case tracking
    case unknown
}

struct ParsedCode {
    let rawValue: String
    let type: CodeType
    let gtin: String?
    let serial: String?
    let carrier: String?

    static func parse(_ input: String) -> ParsedCode {
        // Simplified parsing logic
        if input.count == 12 || input.count == 13 {
            return ParsedCode(rawValue: input, type: .gtin, gtin: input, serial: nil, carrier: nil)
        } else if input.count == 18 {
            return ParsedCode(rawValue: input, type: .sscc, gtin: input.prefix(14).description, serial: input.suffix(4).description, carrier: nil)
        } else if input.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            return ParsedCode(rawValue: input, type: .tracking, gtin: nil, serial: nil, carrier: "UPS")
        } else {
            return ParsedCode(rawValue: input, type: .unknown, gtin: nil, serial: nil, carrier: nil)
        }
    }
}
